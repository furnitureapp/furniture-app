import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furniture_ecom_app/core/api_management_service/admin_api_service.dart';

import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/constants/colors.dart';

class ApprovalPieChartManager extends StatefulWidget {
  const ApprovalPieChartManager({super.key});

  @override
  State<ApprovalPieChartManager> createState() =>
      _ApprovalPieChartManagerState();
}

class _ApprovalPieChartManagerState extends State<ApprovalPieChartManager> {
  bool _isLoading = false;
  int? touchedIndex;

  int placed = 0;
  int shipped = 0;
  int delivered = 0;
  int cancelled = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);

    final data = await AdminApiService.fetchDashboardCounts();

    if (data["success"] == true) {
      setState(() {
        placed = data["placed"];
        shipped = data["shipped"];
        delivered = data["delivered"];
        cancelled = data["cancelled"];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Error loading data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    if (_isLoading) {
      return Container(
        height: isTablet ? 350 : 250,
        padding: const EdgeInsets.all(16),
        decoration: _boxDeco(),
        child: const Center(child: AnimationPage1()),
      );
    }

    return isTablet ? _buildTabletUI() : _buildMobileUI();
  }

  // -------------------------------------------------------------
  // 📱 MOBILE UI (same as your original)
  // -------------------------------------------------------------
  Widget _buildMobileUI() {
    return Column(
      children: [
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: _boxDeco(),
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 15,
              sectionsSpace: 3,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    setState(() => touchedIndex = -1);
                    return;
                  }
                  setState(() {
                    touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _buildSections(isTablet: false),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statusText("$placed Placed", const Color(0xFF553861),),
            const SizedBox(width: 15),
            _statusText("$cancelled Cancelled", mythemecolor1),
            const SizedBox(width: 15),
            _statusText(
              "$delivered Delivered",
              const Color.fromARGB(255, 166, 195, 211),
            ),
            const SizedBox(width: 15),

            _statusText("$shipped Shipped", tdlightPink),
          ],
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legend(const Color(0xFF553861), "Placed"),
              _legend(mythemecolor1, "Cancelled"),
              _legend(const Color.fromARGB(255, 166, 195, 211), "Delivered"),
              _legend(tdlightPink, "Shipped"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletUI() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDeco(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// LEFT — PIE CHART
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 300, // reduced height
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 55,
                  sectionsSpace: 8,
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
                  sections: _buildSections(isTablet: true),
                ),
              ),
            ),
          ),

          /// ↓↓↓ THIS IS THE FIX — REDUCE GAP ↓↓↓
          const SizedBox(width: 12),

          /// RIGHT — STAT CARDS
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // ensures tight alignment
              mainAxisAlignment:
                  MainAxisAlignment.center, // vertically centered
              children: [
                _statCard(
                  title: "Placed",
                  count: placed,
                  color: const Color(0xFF553861),
                  icon: Icons.check_circle,
                ),

                const SizedBox(height: 10),

                _statCard(
                  title: " Cancelled",
                  count: cancelled,
                  color: mythemecolor1,
                  icon: Icons.cancel,
                ),

                const SizedBox(height: 10),

                _statCard(
                  title: "Delivered",
                  count: delivered,
                  color: const Color.fromARGB(255, 166, 195, 211),
                  icon: Icons.hourglass_top_rounded,
                ),
                const SizedBox(height: 10),

                _statCard(
                  title: "Shippped",
                  count: shipped,
                  color: tdlightPink,
                  icon: Icons.hourglass_top_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "$count Dealers",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PIE CHART SECTIONS
  // -------------------------------------------------------------
 
  // List<PieChartSectionData> _buildSections({required bool isTablet}) {
  //   final double baseRadius = isTablet ? 85 : 60;
  //   final double touchedRadius = isTablet ? 100 : 70;

  //   return [
  //     PieChartSectionData(
  //       value: placed.toDouble(),
  //       color: const Color(0xFF553861),
  //       title: "$placed",
  //       radius: touchedIndex == 0 ? touchedRadius : baseRadius,
  //       titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
  //     ),
  //     PieChartSectionData(
  //       value: cancelled.toDouble(),
  //       color: mythemecolor1,
  //       title: "$cancelled",
  //       radius: touchedIndex == 1 ? touchedRadius : baseRadius,
  //       titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
  //     ),
  //     PieChartSectionData(
  //       value: delivered.toDouble(),
  //       color: const Color.fromARGB(255, 166, 195, 211),
  //       title: "$delivered",
  //       radius: touchedIndex == 2 ? touchedRadius : baseRadius,
  //       titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
  //     ),
  //     PieChartSectionData(
  //       value: shipped.toDouble(),
  //       color: tdlightPink,
  //       title: "$shipped",
  //       radius: touchedIndex == 2 ? touchedRadius : baseRadius,
  //       titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
  //     ),
  //   ];
  // }


List<PieChartSectionData> _buildSections({required bool isTablet}) {
  final double baseRadius = isTablet ? 85 : 60;
  final double touchedRadius = isTablet ? 100 : 70;

  return [
    PieChartSectionData(
      value: placed.toDouble(),
      color: const Color(0xFF553861),
      title: "$placed",
      radius: touchedIndex == 0 ? touchedRadius : baseRadius,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    PieChartSectionData(
      value: cancelled.toDouble(),
      color: mythemecolor1,
      title: "$cancelled",
      radius: touchedIndex == 1 ? touchedRadius : baseRadius,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    PieChartSectionData(
      value: delivered.toDouble(),
      color: const Color.fromARGB(255, 166, 195, 211),
      title: "$delivered",
      radius: touchedIndex == 2 ? touchedRadius : baseRadius,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
    ),
    PieChartSectionData(
      value: shipped.toDouble(),
      color: tdlightPink,
      title: "$shipped",
      radius: touchedIndex == 3 ? touchedRadius : baseRadius, // FIXED
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
    ),
  ];
}


  BoxDecoration _boxDeco() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2),
      ],
    );
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
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _statusText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:furniture_ecom_app/core/api/admin_api_service.dart';
// import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';

// class ApprovalPieChartManager extends StatefulWidget {
//   const ApprovalPieChartManager({super.key});

//   @override
//   State<ApprovalPieChartManager> createState() =>
//       _ApprovalPieChartManagerState();
// }

// class _ApprovalPieChartManagerState extends State<ApprovalPieChartManager> {
//   bool _isLoading = false;
//   int? touchedIndex;

//   int placed = 0;
//   int shipped = 0;
//   int delivered = 0;
//   int cancelled = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadCounts();
//   }

//   Future<void> _loadCounts() async {
//     setState(() => _isLoading = true);

//     final data = await AdminApiService.fetchDashboardCounts();

//     if (data["success"] == true) {
//       setState(() {
//         placed = data["placed"];
//         shipped = data["shipped"];
//         delivered = data["delivered"];
//         cancelled = data["cancelled"];
//         _isLoading = false;
//       });
//     } else {
//       setState(() => _isLoading = false);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(data["message"] ?? "Error loading data")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isTablet = MediaQuery.of(context).size.width >= 600;

//     if (_isLoading) {
//       return Container(
//         height: isTablet ? 350 : 250,
//         padding: const EdgeInsets.all(16),
//         decoration: _boxDeco(),
//         child: const Center(child: AnimationPage1()),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: _boxDeco(),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             height: isTablet ? 320 : 250,
//             child: PieChart(
//               PieChartData(
//                 centerSpaceRadius: isTablet ? 45 : 28,
//                 sectionsSpace: 4,
//                 pieTouchData: PieTouchData(
//                   touchCallback: (event, response) {
//                     if (!event.isInterestedForInteractions ||
//                         response?.touchedSection == null) {
//                       setState(() => touchedIndex = -1);
//                       return;
//                     }
//                     setState(() {
//                       touchedIndex =
//                           response!.touchedSection!.touchedSectionIndex;
//                     });
//                   },
//                 ),
//                 sections: _sections(isTablet),
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           _legendRow(),
//         ],
//       ),
//     );
//   }

//   // -------------------------------------------------------------
//   // PIE CHART SECTIONS
//   // -------------------------------------------------------------
//   List<PieChartSectionData> _sections(bool isTablet) {
//     final double base = isTablet ? 75 : 55;
//     final double touch = isTablet ? 95 : 70;

//     return [
//       PieChartSectionData(
//         value: placed.toDouble(),
//         color: tdlightPink,
//         title: "$placed",
//         radius: touchedIndex == 0 ? touch : base,
//         titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
//       ),
//       PieChartSectionData(
//         value: shipped.toDouble(),
//         color: mythemecolor1,
//         title: "$shipped",
//         radius: touchedIndex == 1 ? touch : base,
//         titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
//       ),
//       PieChartSectionData(
//         value: delivered.toDouble(),
//         color: mythemecolor,
//         title: "$delivered",
//         radius: touchedIndex == 2 ? touch : base,
//         titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
//       ),
//       PieChartSectionData(
//         value: cancelled.toDouble(),
//         color: tdgGrey,
//         title: "$cancelled",
//         radius: touchedIndex == 3 ? touch : base,
//         titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
//       ),
//     ];
//   }

//   // -------------------------------------------------------------
//   // LEGEND
//   // -------------------------------------------------------------
//   Widget _legendRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _legendItem(tdlightPink, "Placed"),
//         _legendItem(mythemecolor1, "Shipped"),
//         _legendItem(mythemecolor, "Delivered"),
//         _legendItem(tdgGrey, "Cancelled"),
//       ],
//     );
//   }

//   Widget _legendItem(Color color, String label) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 6),
//         Text(label, style: const TextStyle(fontSize: 14)),
//       ],
//     );
//   }

//   BoxDecoration _boxDeco() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       boxShadow: [
//         BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2),
//       ],
//     );
//   }
// }
