import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';

class ApprovalPieChart extends StatefulWidget {
  const ApprovalPieChart({super.key});

  @override
  State<ApprovalPieChart> createState() => _ApprovalPieChartState();
}

class _ApprovalPieChartState extends State<ApprovalPieChart> {
  int approvedCount = 12;
  int rejectedCount = 5;
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chart Container
        Container(
          height: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2),
            ],
          ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$approvedCount Approved Users",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color:  Color.fromARGB(255, 85, 56, 97),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              "$rejectedCount Rejected Users",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: mythemecolor1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Legends
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(Color.fromARGB(255, 85, 56, 97),"Approved"),
            const SizedBox(width: 20),
            _buildLegend(mythemecolor1, "Rejected"),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        value: approvedCount.toDouble(),
        title: "$approvedCount",
        color: Color.fromARGB(255, 85, 56, 97),
        radius: touchedIndex == 0 ? 70 : 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: rejectedCount.toDouble(),
        title: "$rejectedCount",
        color: mythemecolor1,
        radius: touchedIndex == 1 ? 70 : 60,
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
