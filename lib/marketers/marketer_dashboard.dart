import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/marketers/approve_reject_dealer.dart';
import 'package:furniture_ecom_app/marketers/gst_verification_page.dart';
import 'package:furniture_ecom_app/marketers/marketer_activity.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_home_page.dart';
import 'package:furniture_ecom_app/marketers/approval_piechar.dart';
import 'package:furniture_ecom_app/marketers/marketer_users.dart';
import 'package:furniture_ecom_app/marketers/marketers_app_preview.dart';
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
  int pendingApprovals = 0;
  int approvedCount = 12;
  int rejectedCount = 5;
  int? touchedIndex;
  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredData = prefs.getStringList('registeredUsers') ?? [];
    final pendingData = prefs.getStringList('pendingApprovals') ?? [];

    setState(() {
      totalUsers = registeredData.length;
      pendingApprovals = pendingData.length;
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
                'Marketer Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: mythemecolor,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.home, color: mythemecolor),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),

      drawer: const MarketerDrawer(currentPage: "Dashboard"),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool tablet = constraints.maxWidth >= 600;

          return RefreshIndicator(
            color: mythemecolor,
            strokeWidth: 3,
            onRefresh: () async {
              await _loadCounts();
            },

            child: ListView(
              padding: EdgeInsets.all(tablet ? 24 : 16),

              children: [
                Row(
                  children: [
                    Expanded(
                      flex: tablet ? 1 : 1,
                      child: _buildKpiCard(
                        'Total Users',
                        '$totalUsers',
                        Icons.people,
                        const Color.fromARGB(255, 16, 51, 79),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: tablet ? 1 : 1,
                      child: _buildKpiCard(
                        'Pending Approvals',
                        '$pendingApprovals',
                        Icons.hourglass_bottom,
                        const Color.fromARGB(255, 123, 86, 29),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      flex: tablet ? 1 : 1,
                      child: _buildKpiCard(
                        'Approvals done',
                        '${totalUsers - pendingApprovals}',
                        Icons.verified_user,
                        const Color.fromARGB(255, 33, 92, 35),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: tablet ? 1 : 1,
                      child: _buildKpiCard(
                        'Rejected Users',
                        '0',
                        Icons.cancel,
                        const Color.fromARGB(255, 110, 38, 33),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
    return Card(
      color: const Color(0xFFF3F6F3),
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
                fontSize: isTablet(context) ? 20 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: isTablet(context) ? 22 : 12,
                fontWeight: FontWeight.bold,
                color: mythemecolor,
              ),
            ),
          ],
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MyLoginScreen()),
      (route) => false,
    );
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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color.fromARGB(255, 224, 219, 223),
                  child: Icon(Icons.campaign, size: 35, color: mythemecolor),
                ),
                const SizedBox(height: 10),
                Text(
                  "Marketing Hub",
                  style: GoogleFonts.montserrat(
                    fontSize: isTablet(context)? 20: 12,
                    fontWeight: FontWeight.bold,
                    color: mythemecolor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Hello, Marketer!",
                  style: GoogleFonts.poppins(fontSize: isTablet(context)? 20: 12, color: mythemecolor),
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



   //   body: SingleChildScrollView(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Row(
      //           children: [
      //             _buildKpiCard(
      //               'Total Users',
      //               '$totalUsers',
      //               Icons.people,
      //               const Color.fromARGB(255, 16, 51, 79),
      //             ),
      //             const SizedBox(width: 12),
      //             _buildKpiCard(
      //               'Pending Approvals',
      //               '$pendingApprovals',
      //               Icons.hourglass_bottom,
      //               const Color.fromARGB(255, 123, 86, 29),
      //             ),
      //           ],
      //         ),
      //         const SizedBox(height: 20),
      //         Row(
      //           children: [
      //             _buildKpiCard(
      //               'Approvals done',
      //               '${totalUsers - pendingApprovals}',
      //               Icons.verified_user,
      //               const Color.fromARGB(255, 33, 92, 35),
      //             ),
      //             const SizedBox(width: 12),
      //             _buildKpiCard(
      //               'Rejected Users',
      //               '0', // Dummy for now
      //               Icons.cancel,
      //               const Color.fromARGB(255, 110, 38, 33),
      //             ),
      //           ],
      //         ),
      //         const SizedBox(height: 20),
      //         Text(
      //           'Approval Overview',
      //           style: GoogleFonts.poppins(
      //             fontSize: 18,
      //             fontWeight: FontWeight.w600,
      //           ),
      //         ),
      //         const SizedBox(height: 12),
      //         const ApprovalPieChart(),
      //         const SizedBox(height: 30),
      //         // const UserCategoryBarChart(
      //         //   approvedCount: 6,
      //         //   rejectedCount: 5,
      //         //   pendingCount: 1,
      //         // ),
      //       ],
      //     ),
      //   ),
      // );