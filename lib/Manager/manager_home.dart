import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/activity_manager.dart';
import 'package:furniture_ecom_app/Manager/app_preview_m.dart';
import 'package:furniture_ecom_app/Manager/approval_pie.dart';
import 'package:furniture_ecom_app/Manager/order_management.dart';
import 'package:furniture_ecom_app/Manager/total_admin.dart';
import 'package:furniture_ecom_app/Manager/total_marketers.dart';
import 'package:furniture_ecom_app/Manager/dealers_list_manager.dart';
import 'package:furniture_ecom_app/core/api/admin_api_service.dart';
import 'package:furniture_ecom_app/core/services/user_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.shortestSide >= 600;
}

class _ManagerHomeState extends State<ManagerHome> {
  int totalOrders = 0;
  int adminCount = 0;
  int marketerCount = 0;
  int dealerCount = 0;
  bool _isLoading = false;

  int? touchedIndex;
  @override
  void initState() {
    super.initState();
    _fetchDashboardCounts();
  }

  Future<void> _fetchDashboardCounts() async {
    setState(() => _isLoading = true);

    final response = await AdminApiService.fetchDashboardCounts();

    setState(() {
      _isLoading = false;

      if (response["success"] == true) {
        totalOrders = response["totalOrders"] ?? 0;
        adminCount = response["adminCount"] ?? 0;
        marketerCount = response["marketerCount"] ?? 0;
        dealerCount = response["dealerCount"] ?? 0;
      } else {
        totalOrders = 0;
        adminCount = 0;
        marketerCount = 0;
        dealerCount = 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Error loading data")),
        );
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
                'MANAGER DASHBOARD',
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

      drawer: const ManagerDrawer(currentPage: "Dashboard"),

      body: _isLoading
          ? const Center(child: AnimationPage1())
          : LayoutBuilder(
              builder: (context, constraints) {
                final bool tablet = constraints.maxWidth >= 600;

                return RefreshIndicator(
                  color: mythemecolor,
                  strokeWidth: 3,

                  onRefresh: () async {
                    if (!_isLoading) {
                      await _fetchDashboardCounts();
                      ();
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
                                        'Total Orders',
                                        '$totalOrders',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const OrdersPageManager(),
                                            ),
                                          );
                                        },
                                        Icons.shopping_cart,
                                        const Color.fromARGB(255, 16, 51, 79),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildKpiCard(
                                        'Total Admin',
                                        '$adminCount',
                                        Icons.admin_panel_settings,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const TotalAdminM(),
                                            ),
                                          );
                                        },
                                        const Color.fromARGB(255, 123, 86, 29),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildKpiCard(
                                        'Total Marketers',
                                        '$marketerCount',
                                        Icons.group,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const TotalMarketersM(),
                                            ),
                                          );
                                        },
                                        const Color.fromARGB(255, 33, 92, 35),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildKpiCard(
                                        'Total Dealers',
                                        '$dealerCount',
                                        Icons.store,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const TotalUsersM(),
                                            ),
                                          );
                                        },
                                        const Color.fromARGB(255, 110, 38, 33),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Orders Overview',
                                  style: GoogleFonts.poppins(
                                    fontSize: tablet ? 22 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const ApprovalPieChartManager(),
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
                                      'Total Orders',
                                      '$totalOrders',
                                      Icons.shopping_cart,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const OrdersPageManager(),
                                          ),
                                        );
                                      },
                                      const Color.fromARGB(255, 16, 51, 79),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildKpiCard(
                                      'Total Admin',
                                      '$adminCount',
                                      Icons.admin_panel_settings,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const TotalAdminM(),
                                          ),
                                        );
                                      },
                                      const Color.fromARGB(255, 123, 86, 29),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildKpiCard(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const TotalMarketersM(),
                                          ),
                                        );
                                      },
                                      'Total Marketers',
                                      '$marketerCount',
                                      Icons.group,
                                      const Color.fromARGB(255, 33, 92, 35),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildKpiCard(
                                      'Total Dealers',
                                      '$dealerCount',
                                      Icons.store,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const TotalUsersM(),
                                          ),
                                        );
                                      },
                                      const Color.fromARGB(255, 110, 38, 33),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Orders Overview',
                                style: GoogleFonts.poppins(
                                  fontSize: tablet ? 22 : 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const ApprovalPieChartManager(),
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

class ManagerDrawer extends StatelessWidget {
  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  final String currentPage;
  const ManagerDrawer({super.key, required this.currentPage});

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
                  "Hello, Manager!",
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
            const ManagerHome(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.app_registration,
            "App Preview",
            const AppPreviewM(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.shopping_basket,
            "Orders Management",
            const OrdersPageManager(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.people,
            "Dealers Management",
            const TotalUsersM(),
          ),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.people,
            "Admin Management",
            const TotalAdminM(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.people,
            "Marketers Management",
            const TotalMarketersM(),
          ),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.history,
            "Activity Log",
            const ManagerActivitylog(),
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
            fontSize: isTablet(context) ? 14 : 12,
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
