import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:furniture_ecom_app/core/api_management_service/dealers_api_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/constants/colors.dart';

class ManagerOrderStatusPieChart extends StatefulWidget {
  const ManagerOrderStatusPieChart({super.key});

  @override
  State<ManagerOrderStatusPieChart> createState() => _ManagerOrderStatusPieChartState();
}

class _ManagerOrderStatusPieChartState extends State<ManagerOrderStatusPieChart> {
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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'] ?? "Error")));
      }
    });
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
            _statusText("$approvedCount Approved", const Color(0xFF553861)),
            const SizedBox(width: 15),
            _statusText("$rejectedCount Rejected", mythemecolor1),
            const SizedBox(width: 15),
            _statusText(
              "$pendingCount Pending",
              const Color.fromARGB(255, 166, 99, 168),
            ),
          ],
        ),

        const SizedBox(height: 16),

        /// Legends
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(const Color(0xFF553861), "Approved"),
            const SizedBox(width: 20),
            _legend(mythemecolor1, "Rejected"),
            const SizedBox(width: 20),
            _legend(const Color.fromARGB(255, 166, 99, 168), "Pending"),
          ],
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
                  title: "Approved",
                  count: approvedCount,
                  color: const Color(0xFF553861),
                  icon: Icons.check_circle,
                ),

                const SizedBox(height: 10),

                _statCard(
                  title: "Rejected",
                  count: rejectedCount,
                  color: mythemecolor1,
                  icon: Icons.cancel,
                ),

                const SizedBox(height: 10),

                _statCard(
                  title: "Pending",
                  count: pendingCount,
                  color: const Color.fromARGB(255, 166, 99, 168),
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
                "$count Users",
                style: const TextStyle(
                  fontSize: 20,
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
  List<PieChartSectionData> _buildSections({required bool isTablet}) {
    final double baseRadius = isTablet ? 85 : 60;
    final double touchedRadius = isTablet ? 100 : 70;

    return [
      PieChartSectionData(
        value: approvedCount.toDouble(),
        color: const Color(0xFF553861),
        title: "$approvedCount",
        radius: touchedIndex == 0 ? touchedRadius : baseRadius,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      PieChartSectionData(
        value: rejectedCount.toDouble(),
        color: mythemecolor1,
        title: "$rejectedCount",
        radius: touchedIndex == 1 ? touchedRadius : baseRadius,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      PieChartSectionData(
        value: pendingCount.toDouble(),
        color: const Color.fromARGB(255, 166, 99, 168),
        title: "$pendingCount",
        radius: touchedIndex == 2 ? touchedRadius : baseRadius,
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
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _statusText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
    );
  }
}

