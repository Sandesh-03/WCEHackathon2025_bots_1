import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/aqi_weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final aqiProvider = Provider.of<AqiWeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        
          title: const Text("Settings")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Theme Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Dark Mode"),
              Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notifications Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Enable Notifications"),
              Switch(
                value: aqiProvider.notificationsEnabled, // ✅ Read saved state
                onChanged: (value) {
                  aqiProvider.toggleNotifications(value); // ✅ Save user choice
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
