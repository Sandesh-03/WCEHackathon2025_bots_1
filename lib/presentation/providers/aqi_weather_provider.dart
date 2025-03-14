import 'package:flutter/material.dart';

import '../../data/datasourcers/aqi_api_service.dart';
import '../../data/datasourcers/weather_api_service.dart';
import '../../data/models/aqi_model.dart';
import '../../data/models/weather_model.dart';

class AqiWeatherProvider with ChangeNotifier {
  final AqiApiService _aqiApiService = AqiApiService();
  final WeatherApiService _weatherApiService = WeatherApiService();

  AqiModel? _aqiData;
  WeatherModel? _weatherData;
  bool _isLoading = false;
  String? _error;
  bool _notificationsEnabled = true; // ✅ Add a flag for notifications

  AqiModel? get aqiData => _aqiData;
  WeatherModel? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get aqi => _aqiData?.aqi ?? 0;
  bool get notificationsEnabled => _notificationsEnabled;

  // AqiWeatherProvider() {
  //   _loadNotificationPreference();
  //   _scheduleTestNotifications(); // ✅ Schedule multiple test notifications
  // }

  Future<void> fetchAqiAndWeather(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("Fetching AQI Data...");
      final Map<String, dynamic> aqiResponse =
          await _aqiApiService.getAqiData(lat, lon);
      _aqiData = AqiModel.fromJson(aqiResponse);

      print("Fetching Weather Data...");
      _weatherData = await _weatherApiService.getWeatherData(lat, lon);

      print("Weather Data Loaded: ${_weatherData!.temperature}°C");
    } catch (e) {
      _error = 'Failed to load data: $e';
      print("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    // ✅ Trigger AQI Notification if AQI > 100 and notifications are enabled
    //     if (aqi > 100 && _notificationsEnabled) {
    //       NotificationService().showNotification(
    //         "⚠️ High AQI Alert",
    //         "The AQI in your area is $aqi. Avoid outdoor activities!",
    //       );
    //     }
    //   } catch (e) {
    //     _error = 'Failed to load data: $e';
    //     print("Error: $e");
    //   } finally {
    //     _isLoading = false;
    //     notifyListeners();
    //   }
    // }

    // // ✅ Function to toggle notifications
    // void toggleNotifications(bool enabled) async {
    //   _notificationsEnabled = enabled;
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.setBool('notificationsEnabled', enabled);
    //   notifyListeners();
    // }

    // // ✅ Load user preference for notifications
    // Future<void> _loadNotificationPreference() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    //   notifyListeners();
    // }

    // // ✅ Schedule multiple test notifications at 30 sec and 1 min
    // void _scheduleTestNotifications() {
    //   Timer(const Duration(seconds: 30), () {
    //     if (_notificationsEnabled) {
    //       NotificationService().showNotification(
    //         "🔔 Test Notification 1",
    //         "This is you current AQI levels $aqi & temperature ${_weatherData!.temperature}",
    //       );
    //     }
    //   });

    //   Timer(const Duration(seconds: 60), () {
    //     if (_notificationsEnabled) {
    //       NotificationService().showNotification(
    //         "🔔 Test Notification 2",
    //         "This is you current AQI levels After 1 min $aqi & temperature ${_weatherData!.temperature}",
    //       );
    //     }
    //   });
    // }
  }
}
