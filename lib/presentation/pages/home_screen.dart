import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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

  double getCigaretteEquivalence(int aqi) {
    if (aqi <= 50) return 0;
    if (aqi <= 100) return 0.5;
    if (aqi <= 150) return 1;
    if (aqi <= 200) return 2;
    if (aqi <= 300) return 3.5;
    return 5; // 301-500 (Hazardous) → 5+ cigarettes
  }

  void _showCigaretteEquivalence(int aqi) {
    double perDay = getCigaretteEquivalence(aqi);
    double perWeek = perDay * 7;
    double perMonth = perDay * 30;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cigarette Equivalence'),
          content: Text(
            "Based on AQI $aqi:\n"
            "🚬 ${perDay.toStringAsFixed(1)} cigarettes per day\n"
            "📆 ${perWeek.toStringAsFixed(1)} cigarettes per week\n"
            "📅 ${perMonth.toStringAsFixed(1)} cigarettes per month",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _shareAQIInfo(AqiWeatherProvider aqiProvider) {
    int aqi = aqiProvider.aqiData!.aqi;
    double cigarettes = getCigaretteEquivalence(aqi);

    String message = "🌍 Air Quality Report 🌿\n"
        "📍 City: ${aqiProvider.weatherData!.city}\n"
        "💨 AQI: $aqi\n"
        "🌡 Temperature: ${aqiProvider.weatherData!.temperature}°C\n"
        "⛅ Weather: ${aqiProvider.weatherData!.description}\n\n"
        "⚠️ Health Impact: Breathing this air is equivalent to smoking "
        "${cigarettes.toStringAsFixed(1)} cigarettes per day! 🚬\n\n"
        "Stay safe! 🏡💚";

    Share.share(message);
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

                    GestureDetector(
                      onTap: () => _showCigaretteEquivalence(aqiProvider.aqiData!.aqi),
                      child: buildInfoCard("AQI", "${aqiProvider.aqiData!.aqi}", Icons.air),
                    ),

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

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _shareAQIInfo(aqiProvider),
                      icon: const Icon(Icons.share),
                      label: const Text("Share AQI Report"),
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
