import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/admin/admin_app_preveiw.dart';
import 'package:furniture_ecom_app/admin/orders_overview.dart';
import 'package:furniture_ecom_app/admin/total_marketers_admin.dart';
import 'package:furniture_ecom_app/admin/total_users_admin.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_home_page.dart';
import 'package:furniture_ecom_app/marketers/user_barchart.dart';
import 'package:furniture_ecom_app/super_admin/order_pie_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: adminPrimaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Admin Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
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
      drawer: const AdminDrawer(currentPage: "Dashboard"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildKpiCard(
                  'Total Orders',
                  '50',
                  Icons.shopping_cart,
                  const Color.fromARGB(255, 67, 74, 73),
                ),
                const SizedBox(width: 12),
                _buildKpiCard(
                  'Total Users',
                  '12',
                  Icons.people,
                  const Color.fromARGB(255, 127, 138, 146),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildKpiCard(
                  'Total Marketers',
                  '15',
                  Icons.campaign,
                  Colors.deepPurple,
                ),
                const SizedBox(width: 12),
                _buildKpiCard(
                  'Order Statuses',
                  '5',
                  Icons.bar_chart,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              'Order Status Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SuperAdminOrderStatusPieChart(),

            const SizedBox(height: 20),

            Text(
              'Total Users Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            const UserCategoryBarChart(
              approvedCount: 6,
              rejectedCount: 5,
              pendingCount: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: const Color(0xFFF3F6F3),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: adminPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  final String currentPage;
  const AdminDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: adminPrimaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 35,
                    color: adminPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Furniture Hub",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Hello, Admin!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.dashboard, "Dashboard", const AdminHome()),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.list_alt,
            "Orders Overview",
            const AdminOrdersPage(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.chair,
            "App Preview",
            const AppPreviewAdmin(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.category,
            "Maanage Users",
            const TotalUsersAdmin(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.category,
            "Maanage Marketers",
            const TotalMarketersAdmin(),
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
      color: isSelected
          ? adminPrimaryColor.withOpacity(0.1)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? adminPrimaryColor : Colors.black54,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? adminPrimaryColor : Colors.black87,
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
