import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StackedBarChartWidget extends StatelessWidget {
  final String apiData;

  const StackedBarChartWidget({super.key, required this.apiData});

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    List<String> lines = apiData.split('\n');

    for (int i = 1; i < lines.length; i++) {
      List<String> values = lines[i].split(',');
      if (values.length < 3) continue;

      try {
        double? pm25 = double.tryParse(values[1]);
        double? pm10 = double.tryParse(values[2]);

        if (pm25 != null && pm10 != null) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: pm25, color: Colors.blue),
                BarChartRodData(toY: pm10, color: Colors.orange),
              ],
            ),
          );
        }
      } catch (e) {
        continue;
      }
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: const FlTitlesData(show: true),
      ),
    );
  }
}
