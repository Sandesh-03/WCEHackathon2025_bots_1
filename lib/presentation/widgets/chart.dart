import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AirQualityChart extends StatelessWidget {
  final String apiData;

  AirQualityChart({required this.apiData});

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
      appBar: AppBar(title: Text("Air Quality Levels")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("PM2.5 Levels", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: LineChartWidget(spots: parseData('pm2.5cnc'))),
            SizedBox(height: 20),

            Text("PM10 Levels", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: LineChartWidget(spots: parseData('pm10cnc'))),
            SizedBox(height: 20),


            Text("PM2.5 Levels", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: BarChartWidget(spots: parseData('pm2.5cnc'))),
            SizedBox(height: 20),

            Text("PM10 Levels", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: BarChartWidget(spots: parseData('pm10cnc'))),
            SizedBox(height: 20),

            Text("Overall PM Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 300, child: PieChartWidget(apiData: apiData)),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;

  LineChartWidget({required this.spots});

  String formatDate(double timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return DateFormat('MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(formatDate(value), style: TextStyle(fontSize: 10));
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

  BarChartWidget({required this.spots});

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
        titlesData: FlTitlesData(show: true),
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final String apiData;

  PieChartWidget({required this.apiData});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, title: "PM2.5", color: Colors.blue),
          PieChartSectionData(value: 60, title: "PM10", color: Colors.yellow),
        ],
      ),
    );
  }
}
