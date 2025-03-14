import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/aqi_weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
   

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Center(
        child: Text("Settings"),
      )
    );
  }
}
