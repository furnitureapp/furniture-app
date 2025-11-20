// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';

// class ApprovalPieChart extends StatefulWidget {
//   const ApprovalPieChart({super.key});

//   @override
//   State<ApprovalPieChart> createState() => _ApprovalPieChartState();
// }

// class _ApprovalPieChartState extends State<ApprovalPieChart> {
//   int approvedCount = 12;
//   int rejectedCount = 5;
//   int? touchedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Chart Container
//         Container(
//           height: 260,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2),
//             ],
//           ),
//           child: PieChart(
//             PieChartData(
//               centerSpaceRadius: 50,
//               sectionsSpace: 2,
//               borderData: FlBorderData(show: false),
//               pieTouchData: PieTouchData(
//                 touchCallback: (event, response) {
//                   if (!event.isInterestedForInteractions ||
//                       response == null ||
//                       response.touchedSection == null) {
//                     setState(() => touchedIndex = -1);
//                     return;
//                   }
//                   setState(() {
//                     touchedIndex =
//                         response.touchedSection!.touchedSectionIndex;
//                   });
//                 },
//               ),
//               sections: _buildSections(),
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Always show count summary below
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "$approvedCount Approved Users",
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color:  Color.fromARGB(255, 85, 56, 97),
//               ),
//             ),
//             const SizedBox(width: 20),
//             Text(
//               "$rejectedCount Rejected Users",
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: mythemecolor1,
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 16),

//         // Legends
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildLegend(Color.fromARGB(255, 85, 56, 97),"Approved"),
//             const SizedBox(width: 20),
//             _buildLegend(mythemecolor1, "Rejected"),
//           ],
//         ),
//       ],
//     );
//   }

//   List<PieChartSectionData> _buildSections() {
//     return [
//       PieChartSectionData(
//         value: approvedCount.toDouble(),
//         title: "$approvedCount",
//         color: Color.fromARGB(255, 85, 56, 97),
//         radius: touchedIndex == 0 ? 70 : 60,
//         titleStyle: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//       PieChartSectionData(
//         value: rejectedCount.toDouble(),
//         title: "$rejectedCount",
//         color: mythemecolor1,
//         radius: touchedIndex == 1 ? 70 : 60,
//         titleStyle: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     ];
//   }

//   Widget _buildLegend(Color color, String text) {
//     return Row(
//       children: [
//         Container(
//           width: 14,
//           height: 14,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           text,
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';

class ApprovalPieChart extends StatefulWidget {
  const ApprovalPieChart({super.key});

  @override
  State<ApprovalPieChart> createState() => _ApprovalPieChartState();
}

class _ApprovalPieChartState extends State<ApprovalPieChart> {
  int approvedCount = 0;
  int rejectedCount = 0;
  int pendingCount = 0;

  bool _isLoading = false;
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    _fetchDealerStatusCounts();
  }

  
  Future<void> _fetchDealerStatusCounts() async {
    setState(() => _isLoading = true);

    final response = await DealerApiService.fetchDealers();

    setState(() {
      _isLoading = false;

      if (response['success'] == true) {
        final dealers = response['data'] ?? [];

        int approved = 0;
        int rejected = 0;
        int pending = 0;

        for (var d in dealers) {
          final bool isApproved = d['isApproved'] == true;
          final bool isRejected = d['isRejected'] == true;

          if (isApproved) {
            approved++;
          } else if (isRejected) {
            rejected++;
          } else {
            pending++;
          }
        }

        approvedCount = approved;
        rejectedCount = rejected;
        pendingCount = pending;
      } else {
        approvedCount = 0;
        rejectedCount = 0;
        pendingCount = 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? "Error")),
        );
      }
    });
  }

 
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          height: 250,
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
              centerSpaceRadius: 28,
              sectionsSpace: 4,
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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statusText("$approvedCount Approved", const Color(0xFF553861)),
            const SizedBox(width: 15),
            _statusText("$rejectedCount Rejected", mythemecolor1),
            const SizedBox(width: 15),
            _statusText("$pendingCount Pending", const Color.fromARGB(255, 166, 99, 168)),
          ],
        ),


        const SizedBox(height: 16),

        /// LEGENDS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(const Color(0xFF553861), "Approved"),
            const SizedBox(width: 20),
            _legend(mythemecolor1, "Rejected"),
            const SizedBox(width: 20),
            _legend(const Color.fromARGB(255, 166, 99, 168), "Pending"),
          ],
        )
      ],
    );
  }

  /// -------------------------------------------------------------
  /// PIE SECTIONS
  /// -------------------------------------------------------------
  List<PieChartSectionData> _buildSections() {
    return [
      PieChartSectionData(
        value: approvedCount.toDouble(),
        color: const Color(0xFF553861),
        title: "$approvedCount",
        radius: touchedIndex == 0 ? 70 : 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      PieChartSectionData(
        value: rejectedCount.toDouble(),
        color: mythemecolor1,
        title: "$rejectedCount",
        radius: touchedIndex == 1 ? 70 : 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      PieChartSectionData(
        value: pendingCount.toDouble(),
        color: const Color.fromARGB(255, 166, 99, 168),
        title: "$pendingCount",
        radius: touchedIndex == 2 ? 70 : 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ];
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  Widget _statusText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
