import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_data_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/aqi_weather_provider.dart';
import '../widgets/drawer/custom_drawer.dart';
import '../widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final aqiProvider = Provider.of<AqiWeatherProvider>(context);
    final locationDataProvider = Provider.of<LocationDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      drawer: CustomDrawer(apiData: locationDataProvider.apiData),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            settingsCard(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              subtitle: "Enable or disable dark theme",
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => themeProvider.toggleTheme(value),
              ),
            ),
            const SizedBox(height: 15),

            settingsCard(
              icon: Icons.notifications_active,
              title: "Enable Notifications",
              subtitle: "Get AQI updates & alerts",
              trailing: Switch(
                value: aqiProvider.notificationsEnabled,
                onChanged: (value) => aqiProvider.toggleNotifications(value),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

 
}
