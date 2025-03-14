import 'dart:convert';
import 'package:aqi/presentation/widgets/chart.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/location_data_provider.dart';



class LocationDataTab extends StatefulWidget {
  const LocationDataTab({super.key});

  @override
  _LocationDataTabState createState() => _LocationDataTabState();
}

class _LocationDataTabState extends State<LocationDataTab> {
 String nearestSiteData = "Select a location";
  String apiData = "Select a location and date to fetch air quality data";
  String reportSummary = "Report will be generated here.";
  bool isGeneratingReport = false;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  LatLng? selectedLocation;
  GoogleMapController? mapController;
  String selectedSiteId = "";
  final String geminiApiKey = "AIzaSyDhUtvjS8lgDcsWH85lDC8pnMdeSce9cok";
  late GenerativeModel model;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(model: "gemini-2.0-flash", apiKey: geminiApiKey);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = isStartDate ? startDate : endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });

      // Recalculate air quality data after updating dates
      if (selectedSiteId.isNotEmpty) {
        fetchAirQualityData(selectedSiteId);
      }
    }
  }

  Future<void> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        nearestSiteData = "Location permission denied permanently.";
      });
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setLocation(LatLng(position.latitude, position.longitude));
  }

  void setLocation(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
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
      setState(() {
        nearestSiteData = "Nearest Site ID: ${nearestSite['id']}\nName: ${nearestSite['name']}\nCity: ${nearestSite['city']}";
        selectedSiteId = nearestSite['id']; 
      });
      fetchAirQualityData(nearestSite['id']);
    } else {
      setState(() {
        nearestSiteData = "No site found nearby.";
      });
    }
  }

  Future<void> fetchAirQualityData(String siteId) async {
    String formattedStartDate = DateFormat("yyyy-MM-dd'T'HH:mm").format(startDate);
    String formattedEndDate = DateFormat("yyyy-MM-dd'T'HH:mm").format(endDate);
    String params = "pm2.5cnc,pm10cnc";
    String interval = "hh";
    String avgHours = "1";
    String apiKey = "63h3AckbgtY";

    String apiUrl = "http://atmos.urbansciences.in/adp/v4/getDeviceDataParam/imei/$siteId/params/$params/startdate/$formattedStartDate/enddate/$formattedEndDate/ts/$interval/avg/$avgHours/api/$apiKey?gaps=1&gap_value=NaN";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          apiData = response.body;
        });
      } else {
        setState(() {
          apiData = "Failed to fetch data. Error code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        apiData = "Error fetching data: $e";
      });
    }

  }


  Future<void> generateReport() async {
    setState(() {
      isGeneratingReport = true;
      reportSummary = "Generating Report...";
    });

    try {
      final prompt = "Analyze the following air quality data containing timestamp (dt_time), PM2.5 concentration (pm2.5cnc), PM10 concentration (pm10cnc), and device ID (deviceid). Provide the following insights: General Trends: Identify the overall trend in PM2.5 and PM10 levels over time. Are there significant increases or decreases? Peak Hours: Find the highest and lowest PM2.5 and PM10 values, and specify the corresponding timestamps. Daily Averages: Calculate and report daily average PM2.5 and PM10 concentrations. Hourly Patterns: Determine if there are specific hours of the day where pollution levels are consistently high or low. Anomalies: Detect any unusual spikes in pollution levels and potential reasons for them. Correlation Analysis: Check if there is any correlation between PM2.5 and PM10 levels. Suggestions: Provide recommendations based on air quality trends for residents in this area (do not give code give report): \n\n$apiData";
      final response = await model.generateContent([Content.text(prompt)]);
      setState(() {
        reportSummary = response.text ?? "No report generated.";
      });
    } catch (e) {
      setState(() {
        reportSummary = "Error generating report: $e";
      });
    } finally {
      setState(() {
        isGeneratingReport = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: const Text('Air Quality Monitor'),
          centerTitle: true,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: determinePosition,
                  icon: const Icon(Icons.my_location),
                  label: const Text("Use Current Location"),

                ),
                const SizedBox(height: 15),

                const Text('Tap on the map to select a location:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),

                const SizedBox(height: 10),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 300,
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(20.5937, 78.9629),
                          zoom: 5,
                        ),
                        onMapCreated: (controller) => mapController = controller,
                        onTap: setLocation,
                        markers: selectedLocation == null
                            ? {}
                            : {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: selectedLocation!,
                          )
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text("Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}"),

                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text("End Date: ${DateFormat('yyyy-MM-dd').format(endDate)}"),

                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Text(
                  nearestSiteData,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: generateReport,
                  child: const Text("Generate Report"),

                ),
                const SizedBox(height: 10),

                isGeneratingReport
                    ? const Center(child: CircularProgressIndicator())
                    : Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    
                    child:Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: MarkdownBody(
                          data: reportSummary,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 16),
                            h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            strong: const TextStyle(fontWeight: FontWeight.bold),
                            blockquote: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AirQualityChart(apiData: apiData)),
                    );
                  },
                  child: const Text("View Air Quality Chart"),
                ),






                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(apiData, style: const TextStyle(fontSize: 16)),
                  ),
                ),

              ],
            ),
          ),
        ),
      );
  }
}
