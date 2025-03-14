import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_data_provider.dart';
import '../providers/location_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'chart.dart';

class LocationDataTab extends StatelessWidget {
  const LocationDataTab({super.key});

  @override
  Widget build(BuildContext context) {
    final locationDataProvider = Provider.of<LocationDataProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            await locationProvider.fetchLocation();
            if (locationProvider.position != null) {
              locationDataProvider.setLocation(
                context,
                LatLng(
                  locationProvider.position!.latitude,
                  locationProvider.position!.longitude,
                ),
              );
            }
          },
          icon: const Icon(Icons.my_location),
          label: const Text("Use Current Location"),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 300,
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 5,
            ),
            onTap: (LatLng latLng) {
              locationDataProvider.setLocation(context, latLng);
            },
            markers: locationDataProvider.selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: locationDataProvider.selectedLocation!,
                    )
                  },
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: () => locationDataProvider.selectDate(context, true),
              child: Text(
                  "Start Date: ${DateFormat('yyyy-MM-dd').format(locationDataProvider.startDate)}"),
            ),
            ElevatedButton(
              onPressed: () => locationDataProvider.selectDate(context, false),
              child: Text(
                  "End Date: ${DateFormat('yyyy-MM-dd').format(locationDataProvider.endDate)}"),
            ),
            ElevatedButton(
              onPressed: () => locationDataProvider.fetchAirQualityData(),
              child: const Text("Fetch Data"),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AirQualityChart(apiData: locationDataProvider.apiData),
              ),
            );
          },
          child: const Text("View Air Quality Chart"),
        ),
        const SizedBox(height: 15),
        Text(
          locationDataProvider.nearestSiteData,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
