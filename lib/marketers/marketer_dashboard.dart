
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_home_page.dart';
import 'package:furniture_ecom_app/marketers/approval_piechar.dart';
import 'package:furniture_ecom_app/marketers/marketer_approval.dart';
import 'package:furniture_ecom_app/marketers/marketer_create_user.dart';
import 'package:furniture_ecom_app/marketers/marketer_users.dart';
import 'package:furniture_ecom_app/marketers/marketers_app_preview.dart';
import 'package:furniture_ecom_app/marketers/user_barchart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketerHome extends StatefulWidget {
  const MarketerHome({super.key});

  @override
  State<MarketerHome> createState() => _MarketerHomeState();
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
            color: marketerprimaryColor,
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
                'Marketer Dashboard',
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

      drawer: const MarketerDrawer(currentPage: "Dashboard"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildKpiCard(
                  'Total Users',
                  '$totalUsers',
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildKpiCard(
                  'Pending Approvals',
                  '$pendingApprovals',
                  Icons.hourglass_bottom,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildKpiCard(
                  'Approvals done',
                  '${totalUsers - pendingApprovals}',
                  Icons.verified_user,
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildKpiCard(
                  'Rejected Users',
                  '0', // Dummy for now
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Approval Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const ApprovalPieChart(),
            const SizedBox(height: 30),
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
                  color: marketerprimaryColor,
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
  final String currentPage;
  const MarketerDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: marketerprimaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.campaign,
                    size: 35,
                    color: marketerprimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Marketing Hub",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Hello, Marketer!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
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
            "User Details",
            const MarketerUsersPage(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.person_add,
            "Create User",
            const MarketerCreateUserPage(),
          ),
          const SizedBox(height: 10),
          _drawerItem(
            context,
            Icons.verified,
            "Approval Process",
            const MarketerApprovalPage(),
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
          ? marketerprimaryColor.withOpacity(0.1)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? marketerprimaryColor : Colors.black54,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? marketerprimaryColor : Colors.black87,
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




// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/constants/colors.dart';
// import 'package:furniture_ecom_app/main.dart';
// import 'package:furniture_ecom_app/marketers/marketer_approval.dart';
// import 'package:furniture_ecom_app/marketers/marketer_create_user.dart';
// import 'package:furniture_ecom_app/marketers/marketer_users.dart';
// import 'package:furniture_ecom_app/marketers/marketers_app_preview.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MarketerHome extends StatefulWidget {
//   const MarketerHome({super.key});

//   @override
//   State<MarketerHome> createState() => _MarketerHomeState();
// }

// class _MarketerHomeState extends State<MarketerHome> {
//   int totalUsers = 0;
//   int pendingApprovals = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadCounts();
//   }

//   Future<void> _loadCounts() async {
//     final prefs = await SharedPreferences.getInstance();
//     final registeredData = prefs.getStringList('registeredUsers') ?? [];
//     final pendingData = prefs.getStringList('pendingApprovals') ?? [];

//     setState(() {
//       totalUsers = registeredData.length;
//       pendingApprovals = pendingData.length;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: marketerprimaryColor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             title: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Text(
//                 'Marketer Dashboard',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.home, color: Colors.white),
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HomePage()),
//                   );
//                 },
//               ),
//               const SizedBox(width: 12),
//             ],
//           ),
//         ),
//       ),

//       drawer: const MarketerDrawer(currentPage: "Dashboard"),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 _buildKpiCard(
//                   'Total Users',
//                   '$totalUsers',
//                   Icons.people,
//                   Colors.blue,
//                 ),
//                 const SizedBox(width: 12),
//                 _buildKpiCard(
//                   'Pending Approvals',
//                   '$pendingApprovals',
//                   Icons.hourglass_bottom,
//                   Colors.orange,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 _buildKpiCard(
//                   'Approvals done',
//                   '${totalUsers - pendingApprovals}',
//                   Icons.verified_user,
//                   Colors.green,
//                 ),
//                 const SizedBox(width: 12),
//                 _buildKpiCard(
//                   'Rejected Users',
//                   '0', // Dummy for now
//                   Icons.cancel,
//                   Colors.red,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             Text(
//               'Approval Overview',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: const Center(child: Text("Pie Chart")),
//             ),

//             const SizedBox(height: 20),

//             Text(
//               'Total Users Overview',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: const Center(child: Text("Line Chart")),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
//     return Expanded(
//       child: Card(
//         color: const Color(0xFFF3F6F3),
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Icon(icon, color: color, size: 32),
//               const SizedBox(height: 8),
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 count,
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: marketerprimaryColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MarketerDrawer extends StatelessWidget {
//   final String currentPage;
//   const MarketerDrawer({super.key, required this.currentPage});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: const BoxDecoration(color: marketerprimaryColor),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.campaign,
//                     size: 35,
//                     color: marketerprimaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Marketing Hub",
//                   style: GoogleFonts.montserrat(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   "Hello, Marketer!",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _drawerItem(
//             context,
//             Icons.dashboard,
//             "Dashboard",
//             const MarketerHome(),
//           ),
//           const SizedBox(height: 10),
//           _drawerItem(
//             context,
//             Icons.app_registration,
//             "App Preview",
//             const MarketersAppPreview(),
//           ),
//           const SizedBox(height: 10),
//           _drawerItem(
//             context,
//             Icons.people,
//             "User Details",
//             const MarketerUsersPage(),
//           ),
//           const SizedBox(height: 10),
//           _drawerItem(
//             context,
//             Icons.person_add,
//             "Create User",
//             const MarketerCreateUserPage(),
//           ),
//           const SizedBox(height: 10),
//           _drawerItem(
//             context,
//             Icons.verified,
//             "Approval Process",
//             const MarketerApprovalPage(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _drawerItem(
//     BuildContext context,
//     IconData icon,
//     String title,
//     Widget page,
//   ) {
//     final bool isSelected = title == currentPage;
//     return Container(
//       color: isSelected
//           ? marketerprimaryColor.withOpacity(0.1)
//           : Colors.transparent,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? marketerprimaryColor : Colors.black54,
//         ),
//         title: Text(
//           title,
//           style: GoogleFonts.poppins(
//             color: isSelected ? marketerprimaryColor : Colors.black87,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//           ),
//         ),
//         onTap: () {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => page),
//           );
//         },
//       ),
//     );
//   }
// }
