import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services/user_service.dart';
import 'package:furniture_ecom_app/marketers/approve_reject_dealer.dart';
import 'package:furniture_ecom_app/core/api/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/gst_verification_page.dart';
import 'package:furniture_ecom_app/marketers/marketer_activity.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/marketers/approval_piechar.dart';
import 'package:furniture_ecom_app/marketers/marketer_users.dart';
import 'package:furniture_ecom_app/marketers/marketers_app_preview.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketerHome extends StatefulWidget {
  const MarketerHome({super.key});

  @override
  State<MarketerHome> createState() => _MarketerHomeState();
}

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.shortestSide >= 600;
}

class _MarketerHomeState extends State<MarketerHome> {
  int totalUsers = 0;
  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;
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
        totalUsers = dealers.length;
      } else {
        approvedCount = 0;
        rejectedCount = 0;
        pendingCount = 0;
        totalUsers = 0;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'] ?? "Error")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 227, 211, 244),
                Colors.white,
                Color.fromARGB(255, 227, 211, 244),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: mythemecolor),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'MARKETER DASHBOARD',
                style: GoogleFonts.poppins(
                  fontSize: isTablet(context) ? 22 : 12,
                  fontWeight: FontWeight.w600,
                  color: mythemecolor,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),

      drawer: const MarketerDrawer(currentPage: "Dashboard"),

      body: _isLoading
          ? const Center(child: AnimationPage1())
          : LayoutBuilder(
              builder: (context, constraints) {
                final bool tablet = constraints.maxWidth >= 600;

                return RefreshIndicator(
                  color: mythemecolor,
                  strokeWidth: 3,
                  // onRefresh: () async {
                  //   await _fetchDealerStatusCounts();
                  // },
                  onRefresh: () async {
                    if (!_isLoading) {
                      await _fetchDealerStatusCounts();
                    }
                  },

                  child: ListView(
                    padding: EdgeInsets.all(tablet ? 24 : 16),

                    children: [
                      // ───────────────────────────────
                      // KPI CARDS GRID (Responsive)
                      // ───────────────────────────────
                      LayoutBuilder(
                        builder: (context, c) {
                          final bool tablet = c.maxWidth >= 600;

                          if (tablet) {
                            // 🔥 TABLET → 4 Cards in One Row
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildKpiCard(
                                        'Total Dealers',
                                        '$totalUsers',
                                        Icons.people,
                                        const Color.fromARGB(255, 16, 51, 79),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DealersListPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildKpiCard(
                                        'Pending Approvals',
                                        '$pendingCount',
                                        Icons.hourglass_bottom,
                                        const Color.fromARGB(255, 123, 86, 29),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DealerApprovalPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildKpiCard(
                                        'Approvals done',
                                        '$approvedCount',
                                        Icons.verified_user,
                                        const Color.fromARGB(255, 33, 92, 35),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DealerApprovalPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildKpiCard(
                                        'Rejected Users',
                                        '$rejectedCount',
                                        Icons.cancel,
                                        const Color.fromARGB(255, 110, 38, 33),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DealerApprovalPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Approval Overview',
                                  style: GoogleFonts.poppins(
                                    fontSize: tablet ? 22 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const ApprovalPieChart(),
                                const SizedBox(height: 30),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildKpiCard(
                                      'Total Dealers',
                                      '$totalUsers',
                                      Icons.people,
                                      const Color.fromARGB(255, 16, 51, 79),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DealersListPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildKpiCard(
                                      'Pending Approvals',
                                      '$pendingCount',
                                      Icons.hourglass_bottom,
                                      const Color.fromARGB(255, 123, 86, 29),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DealerApprovalPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildKpiCard(
                                      'Approvals done',
                                      '$approvedCount',
                                      Icons.verified_user,
                                      const Color.fromARGB(255, 33, 92, 35),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DealerApprovalPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildKpiCard(
                                      'Rejected Users',
                                      '$rejectedCount',
                                      Icons.cancel,
                                      const Color.fromARGB(255, 110, 38, 33),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DealerApprovalPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Approval Overview',
                                style: GoogleFonts.poppins(
                                  fontSize: tablet ? 22 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const ApprovalPieChart(),
                              const SizedBox(height: 30),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String count,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color.fromARGB(255, 227, 211, 244),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isTablet(context) ? 20 : 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: GoogleFonts.poppins(
                  fontSize: isTablet(context) ? 22 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketerDrawer extends StatelessWidget {
  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  final String currentPage;
  const MarketerDrawer({super.key, required this.currentPage});

 Future<void> _logout(BuildContext context) async {
    final result = await UserService.logout();

    if (result["success"] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyLoginScreen()),
        (route) => false,
      );
    } else {
      showTopSnackBar(context, result["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 227, 211, 244),
                  Colors.white,
                  Color.fromARGB(255, 227, 211, 244),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/woodpecker_logo.png',
                      height: 100,
                      width: 160,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),

                Text(
                  "Hello, Marketer!",
                  style: GoogleFonts.poppins(
                    fontSize: isTablet(context) ? 20 : 12,
                    color: mythemecolor,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.dashboard,
            "Dashboard",
            const MarketerHome(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.app_registration,
            "App Preview",
            const MarketersAppPreview(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.people,
            "Dealers Details",
            const DealersListPage(),
          ),
          const SizedBox(height: 10),

          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.verified,
            "Approve or Reject Dealers",
            const DealerApprovalPage(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.person_add,
            "Register Dealer",
            const GstVerificationPage(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.history,
            "Activity Log",
            const MarketerActivityPage(),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.logout, color: mythemecolor),
            title: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: mythemecolor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) {
                  final bool isTablet =
                      MediaQuery.of(context).size.shortestSide >= 600;

                  return AlertDialog(
                    titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),

                    // Make dialog wider on tablet (NO UI change on phone)
                    insetPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 120 : 40,
                      vertical: isTablet ? 24 : 24,
                    ),

                    title: Text(
                      "Confirm Logout",
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    content: Text(
                      "Are you sure you want to log out?",
                      style: TextStyle(fontSize: isTablet ? 18 : 14),
                    ),

                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.bold,
                            color: mythemecolor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                await _logout(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    final bool isSelected = title == currentPage;
    return Container(
      color: isSelected ? mythemecolor.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? mythemecolor : Colors.black54),
        title: Text(
          title,

          style: GoogleFonts.poppins(
            fontSize: isTablet(context) ? 14 : 12,

            color: isSelected ? mythemecolor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}
