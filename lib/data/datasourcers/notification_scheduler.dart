import 'dart:async';
import '../../presentation/providers/aqi_weather_provider.dart';
import 'notification_service.dart';

class NotificationScheduler {
  static Timer? _timer;

  static void startBiHourlyUpdates(AqiWeatherProvider provider, double lat, double lon) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(hours: 2), (timer) async {
      await provider.fetchAqiAndWeather(lat, lon); 

      // ignore: unnecessary_null_comparison
      if (provider.aqi != null) {
        NotificationService().showNotification(
          "🌤 AQI Update",
          "Current AQI: ${provider.aqi}",
        );
      }
    });
  }

  static void stopUpdates() {
    _timer?.cancel();
  }
}
