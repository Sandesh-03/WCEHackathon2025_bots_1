import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location_data_provider.dart';



class LocationDataTab extends StatefulWidget {
  const LocationDataTab({super.key});

  @override
  _LocationDataTabState createState() => _LocationDataTabState();
}

class _LocationDataTabState extends State<LocationDataTab> {
  @override
  void initState() {
    super.initState();
    // Load site data when the widget is initialized
    Provider.of<LocationDataProvider>(context, listen: false).loadSiteData();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final provider = Provider.of<LocationDataProvider>(context, listen: false);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? provider.startDate ?? DateTime.now() : provider.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      if (isStartDate) {
        provider.setStartDate(pickedDate);
      } else {
        provider.setEndDate(pickedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocationDataProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Location Selector Dropdown
         DropdownButton<String>(
            value: provider.selectedSiteId,
            hint: const Text('Select Location'),
            items: provider.siteData.map<DropdownMenuItem<String>>((site) {
              return DropdownMenuItem<String>(
                value: site['id'].toString(), // Ensure the value is a String
                child: Text('${site['name']} (${site['city']})'),
              );
            }).toList(),
            onChanged: (value) {
              provider.setSelectedSiteId(value);
            },
          ),
          const SizedBox(height: 20),

          // Date Selectors
          Expanded(
            child: Row(
              children: [
                Text(provider.startDate == null ? 'Start Date: Not Selected' : 'Start Date: ${provider.startDate!.toLocal()}'),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: const Text('Select Start Date'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Text(provider.endDate == null ? 'End Date: Not Selected' : 'End Date: ${provider.endDate!.toLocal()}'),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: const Text('Select End Date'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Parameter Selector
          DropdownButton<String>(
            value: provider.selectedParams,
            items: const [
              DropdownMenuItem(value: 'pm2.5cnc', child: Text('PM2.5')),
              DropdownMenuItem(value: 'pm10cnc', child: Text('PM10')),
              DropdownMenuItem(value: 'pm2.5cnc,pm10cnc', child: Text('Both PM2.5 and PM10')),
            ],
            onChanged: (value) {
              provider.setSelectedParams(value!);
            },
          ),
          const SizedBox(height: 20),

          // Fetch Data Button
          ElevatedButton(
            onPressed: () {
              provider.fetchAirQualityData();
            },
            child: const Text('Fetch Air Quality Data'),
          ),
          const SizedBox(height: 20),

          // Display Air Quality Data
          Expanded(
            child: SingleChildScrollView(
              child: Text(provider.apiData, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}