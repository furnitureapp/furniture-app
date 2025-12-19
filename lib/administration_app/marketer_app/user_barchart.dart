import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UserCategoryBarChart extends StatefulWidget {
  final int approvedCount;
  final int rejectedCount;
  final int pendingCount;
  const UserCategoryBarChart({
    super.key,
    required this.approvedCount,
    required this.rejectedCount,
    required this.pendingCount,
  });

  @override
  State<UserCategoryBarChart> createState() => _UserCategoryBarChartState();
}

class _UserCategoryBarChartState extends State<UserCategoryBarChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final categories = ["Approved", "Rejected", "Pending"];
    final counts = [widget.approvedCount, widget.rejectedCount, widget.pendingCount];

    final colors = [
      [const Color.fromARGB(255, 14, 123, 71), const Color.fromARGB(255, 21, 84, 24)],
      [const Color.fromARGB(255, 124, 38, 38), const Color.fromARGB(255, 67, 15, 14)],
      [const Color.fromARGB(255, 129, 80, 17), const Color.fromARGB(255, 87, 55, 15)],
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          const Text(
            "User Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: (counts.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                barGroups: List.generate(categories.length, (index) {
                  bool isTouched = index == touchedIndex;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: counts[index].toDouble(),
                        width: isTouched ? 30 : 24,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: isTouched ? [colors[index][0], colors[index][1]] : [colors[index][0], colors[index][1]],
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= categories.length) return const SizedBox();
                        return Text(
                          categories[index],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(),
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "${categories[group.x.toInt()]}\n${rod.toY.toInt()} users",
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (response == null || response.spot == null) {
                      setState(() => touchedIndex = -1);
                      return;
                    }
                    setState(() => touchedIndex = response.spot!.touchedBarGroupIndex);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
