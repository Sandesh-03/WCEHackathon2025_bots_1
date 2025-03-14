import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/weather_model.dart';



class WeatherApiService {
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> getWeatherData(double lat, double lon) async {
    final response = await http.get(Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=${AppConstants.weatherApiKey}&units=metric'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return WeatherModel.fromJson(jsonData); // Convert JSON to WeatherModel
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}