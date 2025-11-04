import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/models/admin_model.dart';

class TotalAdminM extends StatelessWidget {
  const TotalAdminM({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: managerPrimaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Total User Admin',
                style: AppTextStyles.heading,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      drawer: const ManagerDrawer(currentPage: "Total User Admin"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal, // To handle wide tables
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => managerPrimaryColor.withOpacity(0.2)),
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('Emp ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('DOB')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Alt Phone')),
            DataColumn(label: Text('ID Proof')),
            DataColumn(label: Text('Photo')),
          ],
          rows: dummyAdmins
              .map(
                (admin) => DataRow(cells: [
                  DataCell(Text(admin.employeeId)),
                  DataCell(Text(admin.name)),
                  DataCell(
                      Text('${admin.dob.day}/${admin.dob.month}/${admin.dob.year}')),
                  DataCell(Text(admin.address)),
                  DataCell(Text(admin.phone)),
                  DataCell(Text(admin.altPhone)),
                  DataCell(Text(admin.idProof)),
                  DataCell(Text(admin.photo != null ? 'Attached' : 'N/A')),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/constants/colors.dart';
// import 'package:furniture_ecom_app/models/admin_model.dart'; // Import your admin model & dummy data
// import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';

// class TotalAdmin extends StatelessWidget {
//   const TotalAdmin({super.key});

//   Widget buildAdminCard(Admin admin) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: kPrimaryColor.withOpacity(0.8), width: 2),
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               admin.name,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 4),
//             Text("Employee ID: ${admin.employeeId}"),
//             Text("DOB: ${admin.dob.day}/${admin.dob.month}/${admin.dob.year}"),
//             Text("Address: ${admin.address}"),
//             Text("Phone: ${admin.phone} | Alt: ${admin.altPhone}"),
//             Text("ID Proof: ${admin.idProof}"),
//             if (admin.photo != null) Text("Photo: Attached"),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: kPrimaryColor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             title: Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Text(
//                 'Total User Admin',
//                 style: AppTextStyles.heading,
//               ),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//           ),
//         ),
//       ),
//       drawer: const SuperAdminDrawer(currentPage: "Total User Admin"),
//       body: SafeArea(
//         child: dummyAdmins.isEmpty
//             ? const Center(child: Text('No admins found'))
//             : ListView.builder(
//                 itemCount: dummyAdmins.length,
//                 itemBuilder: (context, index) {
//                   return buildAdminCard(dummyAdmins[index]);
//                 },
//               ),
//       ),
//     );
//   }
// }
