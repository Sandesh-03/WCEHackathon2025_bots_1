import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import 'notification_service.dart';

class AqiApiService {
  final String baseUrl = 'https://api.waqi.info/feed/';

  Future<Map<String, dynamic>> getAqiData(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$baseUrl/geo:$lat;$lon/?token=${AppConstants.aqiApiKey}'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      int aqi = data['data']['aqi'];

      // Trigger AQI Alert if AQI > 100
      if (aqi > 100) {
        NotificationService().showNotification(
          "⚠️ High AQI Alert",
          "The AQI in your area is $aqi. Avoid outdoor activities!",
        );
      }
      return data;
    } else {
      throw Exception('Failed to load AQI data: ${response.statusCode}');
    }
  }
}
