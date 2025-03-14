import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final String apiData;

  const PieChartWidget({super.key, required this.apiData});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = _generatePieSections();

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Air Quality Distribution",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50, // Creates a donut-like chart
              sectionsSpace: 2, // Space between slices
            ),
          ),
        ),
        _buildLegend(),
      ],
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
        double? pm25 = double.tryParse(values[1]);
        double? pm10 = double.tryParse(values[2]);

        if (pm25 != null && pm10 != null && pm25.isFinite && pm10.isFinite) {
          pm25Total += pm25;
          pm10Total += pm10;
        }
      } catch (e) {
        continue;
      }
    }

    double total = pm25Total + pm10Total;
    if (total == 0) {
      return [
        PieChartSectionData(value: 1, title: "No Data", color: Colors.grey),
      ];
    }

    return [
      PieChartSectionData(
        value: (pm25Total / total) * 100,
        title: "PM2.5 (${(pm25Total / total * 100).toStringAsFixed(1)}%)",
        color: Colors.blue,
        radius: 50,
      ),
      PieChartSectionData(
        value: (pm10Total / total) * 100,
        title: "PM10 (${(pm10Total / total * 100).toStringAsFixed(1)}%)",
        color: Colors.orange,
        radius: 50,
      ),
    ];
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.blue, "PM2.5"),
          const SizedBox(width: 10),
          _legendItem(Colors.orange, "PM10"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
