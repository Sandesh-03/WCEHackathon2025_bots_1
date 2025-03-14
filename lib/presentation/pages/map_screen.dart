import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  void _moveToLocation() {
    _mapController.move(const LatLng(48.8566, 2.3522), 12.0); // Move to Paris
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AQI Map'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToLocation,
        child: const Icon(Icons.location_on),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialZoom: 10.0, 
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'], 
          ),
          const MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(51.509364, -0.128928), 
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}