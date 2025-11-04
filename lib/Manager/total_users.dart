import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/models/user_model.dart';

class TotalUsersM extends StatelessWidget {
  const TotalUsersM({super.key});

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
              child: Text('Total Users', style: AppTextStyles.heading),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      drawer: const ManagerDrawer(currentPage: "Total User Employees"),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => managerPrimaryColor.withOpacity(0.2)),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Company Name')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('GST Number')),
              DataColumn(label: Text('Address')),
              DataColumn(label: Text('Mail ID')),
              DataColumn(label: Text('Username')),
            ],
            rows: dummyUsers
                .map(
                  (user) => DataRow(cells: [
                    DataCell(Text(user.companyName)),
                    DataCell(Text(user.phone)),
                    DataCell(Text(user.gstNumber)),
                    DataCell(Text(user.address)),
                    DataCell(Text(user.email)),
                    DataCell(Text(user.username)),
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
