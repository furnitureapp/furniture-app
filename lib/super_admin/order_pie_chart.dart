import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SuperAdminOrderStatusPieChart extends StatefulWidget {
  const SuperAdminOrderStatusPieChart({super.key});

  @override
  State<SuperAdminOrderStatusPieChart> createState() =>
      _SuperAdminOrderStatusPieChartState();
}

class _SuperAdminOrderStatusPieChartState
    extends State<SuperAdminOrderStatusPieChart> {
  int? touchedIndex;

  final int placedCount = 15;
  final int cancelledCount = 5;
  final int deliveredCount = 10;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Pie Chart container
          SizedBox(
            height: 260,
            width: 260, // Make sure the chart has width and height
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      setState(() => touchedIndex = -1);
                      return;
                    }
                    setState(() {
                      touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sections: _buildSections(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Always show count summary below
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            children: [
              Text(
                "$placedCount Placed",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 46, 63, 92)
                ),
              ),
              Text(
                "$cancelledCount Cancelled",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 108, 55, 55)
                ),
              ),
              Text(
                "$deliveredCount Delivered",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 26, 101, 65),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color.fromARGB(255, 46, 63, 92), "Placed"),
              const SizedBox(width: 16),
              _buildLegend(const Color.fromARGB(255, 108, 55, 55), "Cancelled"),
              const SizedBox(width: 16),
              _buildLegend(const Color.fromARGB(255, 26, 101, 65), "Delivered"),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        value: placedCount.toDouble(),
        title: "$placedCount",
        color: Color.fromARGB(255, 46, 63, 92),
        radius: touchedIndex == 0 ? 70 : 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: cancelledCount.toDouble(),
        title: "$cancelledCount",
        color: Color.fromARGB(255, 108, 55, 55),
        radius: touchedIndex == 1 ? 70 : 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold, 
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: deliveredCount.toDouble(),
        title: "$deliveredCount",
        color: Color.fromARGB(255, 26, 101, 65),
        radius: touchedIndex == 2 ? 70 : 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
