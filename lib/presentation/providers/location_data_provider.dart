import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationDataProvider with ChangeNotifier {
  List<dynamic> _siteData = []; // List of monitoring sites
  String? _selectedSiteId; // Selected site ID
  DateTime? _startDate; // Start date
  DateTime? _endDate; // End date
  String _selectedParams = "pm2.5cnc,pm10cnc"; // Selected parameters
  String _apiData = "Fetching air quality data..."; // API response data
  bool _isLoading = false; // Loading state

  List<dynamic> get siteData => _siteData;
  String? get selectedSiteId => _selectedSiteId;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get selectedParams => _selectedParams;
  String get apiData => _apiData;
  bool get isLoading => _isLoading;

  // Load monitoring sites from JSON
  Future<void> loadSiteData() async {
    _isLoading = true;
    notifyListeners();

    try {
      String jsonString = await rootBundle.loadString('assets/site_ids.json');
      _siteData = json.decode(jsonString);
    } catch (e) {
      _apiData = "Error loading site data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set selected site ID
  void setSelectedSiteId(String? siteId) {
    _selectedSiteId = siteId;
    notifyListeners();
  }

  // Set start date
  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  // Set end date
  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  // Set selected parameters
  void setSelectedParams(String params) {
    _selectedParams = params;
    notifyListeners();
  }

  // Find the nearest site based on user's location
  Future<void> findNearestSite(double userLat, double userLon) async {
    _isLoading = true;
    notifyListeners();

    dynamic nearestSite;
    double minDistance = double.infinity;

    for (var site in _siteData) {
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
      _selectedSiteId = nearestSite['id'];
      _apiData = "Nearest Site ID: ${nearestSite['id']}\nName: ${nearestSite['name']}\nCity: ${nearestSite['city']}";
    } else {
      _apiData = "No site found nearby.";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch air quality data for the selected site and date range
  Future<void> fetchAirQualityData() async {
    if (_selectedSiteId == null || _startDate == null || _endDate == null) {
      _apiData = "Please select a location and date range.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    String startDateStr = _startDate!.toIso8601String();
    String endDateStr = _endDate!.toIso8601String();
    String apiKey = "63h3AckbgtY";

    String apiUrl =
        "http://atmos.urbansciences.in/adp/v4/getDeviceDataParam/imei/$_selectedSiteId/params/$_selectedParams/startdate/$startDateStr/enddate/$endDateStr/ts/hh/avg/1/api/$apiKey?gaps=1&gap_value=NaN";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        _apiData = response.body;
      } else {
        _apiData = "Failed to fetch data. Error code: ${response.statusCode}";
      }
    } catch (e) {
      _apiData = "Error fetching data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}