import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AirQualityChart extends StatelessWidget {
  final String apiData;

  const AirQualityChart({super.key, required this.apiData});

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
    return Scaffold(
      appBar: AppBar(title: const Text("Air Quality Charts")),
      body: SingleChildScrollView(
        child: Column(
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

  Widget _buildPieChartSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(
          height: 300,
          child: PieChartWidget(apiData: apiData),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;

  const LineChartWidget({super.key, required this.spots});

  String formatDate(double timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return DateFormat('MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(formatDate(value), style: const TextStyle(fontSize: 10));
              },
              reservedSize: 40,
              interval: (spots.isNotEmpty) ? (spots.last.x - spots.first.x) / 5 : null,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<FlSpot> spots;

  const BarChartWidget({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: spots.map((spot) {
          return BarChartGroupData(
            x: spot.x.toInt(),
            barRods: [BarChartRodData(toY: spot.y, color: Colors.blue)],
          );
        }).toList(),
        titlesData: const FlTitlesData(show: true),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final String apiData;

  const PieChartWidget({super.key, required this.apiData});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: _generatePieSections(),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections() {
    double pm25Total = 0;
    double pm10Total = 0;
    List<String> lines = apiData.split('\n');

    for (int i = 1; i < lines.length; i++) {
      List<String> values = lines[i].split(',');
      if (values.length < 3) continue;

      try {
        pm25Total += double.parse(values[1]);
        pm10Total += double.parse(values[2]);
      } catch (e) {
        continue;
      }
    }

    double total = pm25Total + pm10Total;
    return [
      PieChartSectionData(value: (pm25Total / total) * 100, title: "PM2.5", color: Colors.blue, radius: 50),
      PieChartSectionData(value: (pm10Total / total) * 100, title: "PM10", color: Colors.yellow, radius: 50),
    ];
  }
}
