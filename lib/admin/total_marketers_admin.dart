import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/admin/admin_home.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/models/marketer_model.dart';

class TotalMarketersAdmin extends StatelessWidget {
  const TotalMarketersAdmin({super.key});

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
              padding: const EdgeInsets.only(top: 10),
              child: Text('Total Marketers', style: AppTextStyles.heading),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      drawer: const AdminDrawer(currentPage: "Total User Marketers"),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => adminPrimaryColor.withOpacity(0.2)),
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
              DataColumn(label: Text('Zone')),
            ],
            rows: dummyMarketers
                .map(
                  (m) => DataRow(cells: [
                    DataCell(Text(m.employeeId)),
                    DataCell(Text(m.name)),
                    DataCell(Text('${m.dob.day}/${m.dob.month}/${m.dob.year}')),
                    DataCell(Text(m.address)),
                    DataCell(Text(m.phone)),
                    DataCell(Text(m.altPhone)),
                    DataCell(Text(m.idProof)),
                    DataCell(Text(m.photo != null ? 'Attached' : 'N/A')),
                    DataCell(Text(m.zone)),
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
