import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
