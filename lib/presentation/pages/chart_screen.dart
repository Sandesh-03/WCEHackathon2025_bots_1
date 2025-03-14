import 'package:aqi/presentation/widgets/drawer/custom_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/location_data_provider.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';

class AirQualityChart extends StatelessWidget {
  final String apiData;

  const AirQualityChart({super.key, required this.apiData, });

  List<FlSpot> parseData(String param) {
    List<FlSpot> spots = [];
    List<String> lines = apiData.split('\n');

    for (int i = 1; i < lines.length; i++) {
      List<String> values = lines[i].split(',');
      if (values.length < 4) continue;

      try {
        DateTime dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(values[0]);
        double x = dateTime.millisecondsSinceEpoch.toDouble();
        double? y = double.tryParse(values[param == 'pm2.5cnc' ? 1 : 2]);

        if (y != null && !y.isNaN) {
          spots.add(FlSpot(x, y));
        }
      } catch (e) {
        continue;
      }
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final locationDataProvider = Provider.of<LocationDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Air Quality Charts")),
      drawer: CustomDrawer(apiData: locationDataProvider.apiData),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildChartSection("PM2.5 Levels", parseData('pm2.5cnc')),
            _buildChartSection("PM10 Levels", parseData('pm10cnc')),
            _buildBarChartSection("PM2.5 Distribution", parseData('pm2.5cnc')),
            _buildBarChartSection("PM10 Distribution", parseData('pm10cnc')),
            _buildPieChartSection("Overall PM Distribution"),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, List<FlSpot> spots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(
          height: 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: 800, child: LineChartWidget(spots: spots)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }



  Widget _buildPieChartSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(height: 413, child: PieChartWidget(apiData: apiData)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBarChartSection(String title, List<FlSpot> spots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(
          height: 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: 800, child: BarChartWidget(spots: spots)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
