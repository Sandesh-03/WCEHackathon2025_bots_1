import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/datasourcers/location_service.dart';




class LocationProvider with ChangeNotifier {
  Position? _position;

  Position? get position => _position;

  Future<void> fetchLocation() async {
    final locationService = LocationService();
    _position = await locationService.getCurrentLocation();
    notifyListeners();
  }
}