import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aqi_weather_provider.dart';
import '../providers/location_data_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../widgets/home_cards.dart';
import '../widgets/location_data_tab.dart';
import 'chart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final aqiWeatherProvider = Provider.of<AqiWeatherProvider>(context, listen: false);

    await locationProvider.fetchLocation();

    if (locationProvider.position != null) {
      await aqiWeatherProvider.fetchAqiAndWeather(
        locationProvider.position!.latitude,
        locationProvider.position!.longitude,
      );
    }
  }

  void _navigateToChart(BuildContext context, String apiData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirQualityChart(apiData: apiData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Index'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Location Data'),
            Tab(text: 'Current AQI'),
          ],
        ),
      ),
      drawer: const CustomDrawer(apiData: ''),
      body: TabBarView(
        controller: _tabController,
        children: [
          const LocationDataTab(),
          Consumer2<AqiWeatherProvider, LocationDataProvider>(
            builder: (context, aqiProvider, locationProvider, child) {
              if (Provider.of<LocationProvider>(context).position == null) {
                return const Center(child: Text('Fetching location...'));
              }

              if (aqiProvider.isLoading || locationProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (aqiProvider.error != null) {
                return Center(child: Text('Error: ${aqiProvider.error}'));
              }

              if (aqiProvider.aqiData == null || aqiProvider.weatherData == null) {
                return const Center(child: Text('No data available'));
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildInfoCard("City", aqiProvider.weatherData!.city, Icons.location_city),
                    buildInfoCard("AQI", "${aqiProvider.aqiData!.aqi}", Icons.air),
                    buildInfoCard("Temperature", "${aqiProvider.weatherData!.temperature}°C", Icons.thermostat),
                    buildInfoCard("Weather", aqiProvider.weatherData!.description, Icons.wb_sunny),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => _navigateToChart(context, locationProvider.apiData),
                      child: buildPollutionCard("Most Polluted Hour", locationProvider.mostPollutedHour, Colors.redAccent),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _navigateToChart(context, locationProvider.apiData),
                      child: buildPollutionCard("Least Polluted Hour", locationProvider.leastPollutedHour, Colors.blueAccent),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  
}
