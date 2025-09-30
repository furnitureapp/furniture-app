import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furniture_ecom_app/models/user_model.dart';

class UserApprovalBarChart extends StatefulWidget {
  const UserApprovalBarChart({super.key});

  @override
  State<UserApprovalBarChart> createState() => _UserApprovalBarChartState();
}

class _UserApprovalBarChartState extends State<UserApprovalBarChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final int approvedCount = approvedUsers.length;
    final int notApprovedCount = dummyUsers.length - approvedCount;
    final counts = [approvedCount, notApprovedCount];
    final categories = ['Approved', 'Not Approved'];
    final colors = [Colors.greenAccent, Colors.redAccent];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          const Text(
            'User Approval Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: (counts.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(),
                barGroups: List.generate(counts.length, (index) {
                  bool isTouched = touchedIndex == index;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: counts[index].toDouble(),
                        width: isTouched ? 28 : 22,
                        borderRadius: BorderRadius.circular(6),
                        color: colors[index],
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx < 0 || idx >= categories.length) return const SizedBox();
                        return Text(
                          categories[idx],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (response == null || response.spot == null) {
                      setState(() => touchedIndex = -1);
                      return;
                    }
                    setState(() => touchedIndex = response.spot!.touchedBarGroupIndex);
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "${categories[group.x.toInt()]}\n${rod.toY.toInt()} users",
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
