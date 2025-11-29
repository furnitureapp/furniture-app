import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_home_page.dart';
import 'package:furniture_ecom_app/super_admin/app_preview.dart';
import 'package:furniture_ecom_app/super_admin/order_amount_bar.dart';
import 'package:furniture_ecom_app/super_admin/order_detail.dart';
import 'package:furniture_ecom_app/super_admin/order_pie_chart.dart';
import 'package:furniture_ecom_app/super_admin/total_admin.dart';
import 'package:furniture_ecom_app/super_admin/total_marketers.dart';
import 'package:furniture_ecom_app/super_admin/total_users.dart';
import 'package:google_fonts/google_fonts.dart';

class SuperAdminHome extends StatefulWidget {
  const SuperAdminHome({super.key});

  @override
  State<SuperAdminHome> createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<SuperAdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 93, 64, 37),
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
                'Super Admin Dashboard',
                style: AppTextStyles.heading,
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
      drawer: const SuperAdminDrawer(currentPage: "Dashboard"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildKpiCard(
                  'Total Orders',
                  '152',
                  Icons.shopping_cart,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildKpiCard(
                  'Order Value',
                  '₹1,25,000',
                  Icons.currency_rupee,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildKpiCard(
                  'Admins',
                  '10',
                  Icons.admin_panel_settings,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildKpiCard('Marketers', '25', Icons.campaign, Colors.purple),
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
              'Order Amount Trend',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            MinimalOrderAmountLineChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: const Color(0xFFF8F4F1),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: AppTextStyles.body),
              const SizedBox(height: 4),
              Text(count, style: AppTextStyles.kpiValue),
            ],
          ),
        ),
      ),
    );
  }
}

class SuperAdminDrawer extends StatelessWidget {
  final String currentPage;
  const SuperAdminDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kPrimaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.chair, size: 35, color: kPrimaryColor),
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
                  "Hello, Super Admin!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          _drawerItem(
            context,
            Icons.dashboard,
            "Dashboard",
            const SuperAdminHome(),
          ),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.phone_android,
            "App Preview",
            const AppPreview(),
          ),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.list_alt,
            "Order Details with Amount",
            const OrdersPageSuperAdmin(),
          ),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.people,
            "Total User Employees",
            const TotalUsers(),
          ),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.people,
            "Total User Admin",
            const TotalAdmin(),
          ),
          const SizedBox(height: 10),

          _drawerItem(
            context,
            Icons.groups,
            "Total Marketers",
            const TotalMarketers(),
          ),
          const SizedBox(height: 10),
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
      color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? kPrimaryColor : Colors.black54),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? kPrimaryColor : Colors.black87,
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
