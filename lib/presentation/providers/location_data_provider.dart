import 'dart:convert';
import 'package:aqi/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LocationDataProvider with ChangeNotifier {
  String nearestSiteData = "Select a location";
  String apiData = "Select a location and date to fetch air quality data";
  bool isLoading = false;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  String selectedSiteId = "";
  LatLng? selectedLocation;
  String mostPollutedHour = "Not available";
  String leastPollutedHour = "Not available";

  void setLocation(BuildContext context, LatLng location) {
    selectedLocation = location;
    notifyListeners();
    findNearestSite(location.latitude, location.longitude);
  }

  Future<void> findNearestSite(double userLat, double userLon) async {
    String jsonString = await rootBundle.loadString('assets/site_ids.json');
    List<dynamic> jsonData = json.decode(jsonString);
    dynamic nearestSite;
    double minDistance = double.infinity;

    for (var site in jsonData) {
      double siteLat = site['lat'];
      double siteLon = site['lon'];
      double distance =
          Geolocator.distanceBetween(userLat, userLon, siteLat, siteLon);
      if (distance < minDistance) {
        minDistance = distance;
        nearestSite = site;
      }
    }

    if (nearestSite != null) {
      nearestSiteData =
          "Nearest Site ID: ${nearestSite['id']}\nName: ${nearestSite['name']}\nCity: ${nearestSite['city']}";
      selectedSiteId = nearestSite['id'];
      await fetchAirQualityData();
    } else {
      nearestSiteData = "No site found nearby.";
    }
    notifyListeners();
  }

  Future<void> fetchAirQualityData() async {
    if (selectedSiteId.isEmpty) return;

    isLoading = true;
    notifyListeners();

    String formattedStartDate =
        DateFormat("yyyy-MM-dd'T'HH:mm").format(startDate);
    String formattedEndDate = DateFormat("yyyy-MM-dd'T'HH:mm").format(endDate);
    String params = "pm2.5cnc,pm10cnc";
    String interval = "hh";
    String avgHours = "1";
    String apiKey = "63h3AckbgtY";

    String apiUrl =
        "http://atmos.urbansciences.in/adp/v4/getDeviceDataParam/imei/$selectedSiteId/params/$params/startdate/$formattedStartDate/enddate/$formattedEndDate/ts/$interval/avg/$avgHours/api/$apiKey?gaps=1&gap_value=NaN";

    try {
      print("Fetching AQI data from API: $apiUrl");
      final response = await http.get(Uri.parse(apiUrl));
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("API response received");
        apiData = response.body;
        List<Map<String, String>> csvData = _parseCsv(response.body);
        await _analyzePollutionData(csvData);
      } else {
        apiData = "Failed to fetch data. Error code: ${response.statusCode}";
        print(apiData);
      }
    } catch (e) {
      apiData = "Error fetching data: $e";
      print(apiData);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? startDate : endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (isStartDate) {
        startDate = picked;
      } else {
        endDate = picked;
      }
      await fetchAirQualityData();
      notifyListeners();
    }
  }

  Future<void> _analyzePollutionData(List<Map<String, String>> data) async {
    String apiUrl =
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${AppConstants.geminiApiKey}";

    String prompt =
        "Analyze this air quality data and return only the most polluted and least polluted hour in two lines only give the hour nothing else: ${jsonEncode(data)}";

    try {
      print("Sending data to Gemini API for analysis...");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      print("Gemini API Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        String responseText =
            result['candidates'][0]['content']['parts'][0]['text'];

        List<String> lines = responseText.split("\n");
        mostPollutedHour = lines.isNotEmpty ? lines[0] : "Not available";
        leastPollutedHour = lines.length > 1 ? lines[1] : "Not available";
      } else {
        print("Error analyzing data: ${response.body}");
      }
    } catch (e) {
      print("Error sending data to Gemini API: $e");
    }
    notifyListeners();
  }
   List<Map<String, String>> _parseCsv(String csvString) {
    List<Map<String, String>> dataList = [];
    List<String> lines = csvString.split("\n");

    if (lines.isNotEmpty) {
      List<String> headers = lines[0].split(",");

      for (int i = 1; i < lines.length; i++) {
        List<String> values = lines[i].split(",");
        if (values.length == headers.length) {
          Map<String, String> row = {};
          for (int j = 0; j < headers.length; j++) {
            row[headers[j]] = values[j];
          }
          dataList.add(row);
        }
      }
    }
    return dataList;
  }
}
