import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class MarketerUsersPage extends StatefulWidget {
  const MarketerUsersPage({super.key});

  @override
  State<MarketerUsersPage> createState() => _MarketerUsersPageState();
}

class _MarketerUsersPageState extends State<MarketerUsersPage> {
  List<Map<String, String>> registeredUsers = [];

List<Map<String, String>> approvedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadApprovedUsers();
  }

  Future<void> _loadApprovedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final approvedData = prefs.getStringList('approvedUsers') ?? [];

    setState(() {
      approvedUsers = approvedData
          .map((e) => Map<String, String>.from(jsonDecode(e)))
          .toList();
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
                'Approved User Details',
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
          ),
        ),
      ),
      drawer: const MarketerDrawer(currentPage: "User Details"),
      body: approvedUsers.isEmpty
          ? const Center(child: Text("No approved users yet"))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("Company")),
                  DataColumn(label: Text("Phone")),
                  DataColumn(label: Text("GST")),
                  DataColumn(label: Text("Address")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Username")),
                  DataColumn(label: Text("Password")),
                  DataColumn(label: Text("Type")),
                ],
                rows: approvedUsers.map((user) {
                  return DataRow(cells: [
                    DataCell(Text(user['company'] ?? '')),
                    DataCell(Text(user['phone'] ?? '')),
                    DataCell(Text(user['gst'] ?? '')),
                    DataCell(Text(user['address'] ?? '')),
                    DataCell(Text(user['email'] ?? '')),
                    DataCell(Text(user['username'] ?? '')),
                    DataCell(Text(user['password'] ?? '')),
                    DataCell(Text(user['userType'] ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}