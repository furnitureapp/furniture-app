import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:furniture_ecom_app/models/order_history.dart';

class MinimalOrderAmountLineChart extends StatelessWidget {
  const MinimalOrderAmountLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort orders by date
    final sortedOrders = dummyOrders.toList()..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    // Prepare FlSpot points
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedOrders.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedOrders[i].totalAmount));
    }

    // Labels for X-axis
    final xLabels = sortedOrders.map((e) => "${e.orderDate.day}/${e.orderDate.month}").toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)],
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= xLabels.length) return const SizedBox();
                  return Text(xLabels[index], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // hide Y-axis
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    "${xLabels[spot.x.toInt()]}\n₹${spot.y.toInt()}",
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
