import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class AqiApiService {
  final String baseUrl = 'https://api.waqi.info/feed/';

  Future<Map<String, dynamic>> getAqiData(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$baseUrl/geo:$lat;$lon/?token=${AppConstants.aqiApiKey}'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      int aqi = data['data']['aqi'];
    }
    
  }
}
