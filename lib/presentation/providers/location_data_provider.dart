import 'dart:convert';
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
  DateTime startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime endDate = DateTime.now();
  String selectedSiteId = "";
  LatLng? selectedLocation;

  String? mostPollutedTime;
  String? leastPollutedTime;
  String? previousTemperature;
  String? previousAqi;
  String? previousWeather;

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
      double distance = Geolocator.distanceBetween(userLat, userLon, siteLat, siteLon);
      if (distance < minDistance) {
        minDistance = distance;
        nearestSite = site;
      }
    }

    if (nearestSite != null) {
      nearestSiteData = "Nearest Site ID: ${nearestSite['id']}\nName: ${nearestSite['name']}\nCity: ${nearestSite['city']}";
      selectedSiteId = nearestSite['id'];
      fetchAirQualityData();
    } else {
      nearestSiteData = "No site found nearby.";
    }
    notifyListeners();
  }

  Future<void> fetchAirQualityData() async {
    if (selectedSiteId.isEmpty) return;
    
    isLoading = true;
    notifyListeners();

    String formattedStartDate = DateFormat("yyyy-MM-dd'T'HH:mm").format(startDate);
    String formattedEndDate = DateFormat("yyyy-MM-dd'T'HH:mm").format(endDate);
    String params = "pm2.5cnc,pm10cnc";
    String interval = "hh";
    String avgHours = "1";
    String apiKey = "63h3AckbgtY";

    String apiUrl =
        "http://atmos.urbansciences.in/adp/v4/getDeviceDataParam/imei/$selectedSiteId/params/$params/startdate/$formattedStartDate/enddate/$formattedEndDate/ts/$interval/avg/$avgHours/api/$apiKey?gaps=1&gap_value=NaN";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        apiData = response.body;
        debugPrint("API Data Fetched: $apiData");
        calculatePollutionTimes();
      } else {
        apiData = "Failed to fetch data. Error code: ${response.statusCode}";
      }
    } catch (e) {
      apiData = "Error fetching data: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void calculatePollutionTimes() {
    if (apiData.isEmpty) {
      debugPrint("API data is empty, cannot calculate pollution times.");
      return;
    }
    
    List<Map<String, dynamic>> aqiData = _parseCsvAqiData(apiData);
    if (aqiData.isEmpty) {
      debugPrint("Parsed AQI data is empty.");
      return;
    }
    
    aqiData.sort((a, b) => (
      (double.tryParse(a["pm2.5cnc"] ?? "0") ?? 0) +
      (double.tryParse(a["pm10cnc"] ?? "0") ?? 0)
    ).compareTo(
      (double.tryParse(b["pm2.5cnc"] ?? "0") ?? 0) +
      (double.tryParse(b["pm10cnc"] ?? "0") ?? 0)
    ));

    var leastPolluted = aqiData.first;
    var mostPolluted = aqiData.last;
    var latestData = aqiData.last;

    debugPrint("Most Polluted Hour Data: $mostPolluted");
    debugPrint("Least Polluted Hour Data: $leastPolluted");

    mostPollutedTime = _formatTime(mostPolluted["time"]);
    leastPollutedTime = _formatTime(leastPolluted["time"]);
    previousAqi = "PM2.5: ${latestData["pm2.5cnc"]}, PM10: ${latestData["pm10cnc"]}";
    previousTemperature = "${latestData["temperature"]}°C";
    previousWeather = latestData["weather"];
    
    notifyListeners();
  }

  List<Map<String, dynamic>> _parseCsvAqiData(String csvData) {
    try {
      List<String> lines = csvData.split("\n");
      if (lines.isEmpty || lines.length < 2) {
        debugPrint("Error: CSV data is empty or malformed.");
        return [];
      }
      
      List<String> headers = lines[0].split(",");
      List<Map<String, dynamic>> parsedData = [];
      
      for (int i = 1; i < lines.length; i++) {
        List<String> values = lines[i].split(",");
        if (values.length != headers.length) continue;
        
        Map<String, dynamic> entry = {};
        for (int j = 0; j < headers.length; j++) {
          entry[headers[j].trim()] = values[j].trim();
        }
        parsedData.add(entry);
      }
      
      return parsedData;
    } catch (e) {
      debugPrint("Error parsing CSV data: $e");
      return [];
    }
  }

  String _formatTime(String time) {
    try {
      DateTime parsedTime = DateFormat("HH:mm").parse(time);
      return DateFormat("h:mm a").format(parsedTime);
    } catch (e) {
      debugPrint("Error formatting time: $e");
      return "-";
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
      fetchAirQualityData();
      notifyListeners();
    }
  }
}
