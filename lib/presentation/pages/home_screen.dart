import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aqi_weather_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/drawer/custom_drawer.dart';




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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Index'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current AQI'),
            Tab(text: 'Location Data'),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<AqiWeatherProvider>(
            builder: (context, aqiProvider, child) {
              if (Provider.of<LocationProvider>(context).position == null) {
                return const Center(child: Text('Fetching location...'));
              }

              if (aqiProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (aqiProvider.error != null) {
                return Center(child: Text('Error: ${aqiProvider.error}'));
              }

              if (aqiProvider.aqiData == null || aqiProvider.weatherData == null) {
                return const Center(child: Text('No data available'));
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('City: ${aqiProvider.weatherData!.city}'),
                    const SizedBox(height: 20),
                    Text('AQI: ${aqiProvider.aqiData!.aqi}'),
                    const SizedBox(height: 20),
                    Text('Temperature: ${aqiProvider.weatherData!.temperature}°C'),
                    const SizedBox(height: 20),
                    Text('Weather: ${aqiProvider.weatherData!.description}'),
                  ],
                ),
              );
            },
          ),
          const Scaffold(),
        ],
      ),
    );
  }
}
