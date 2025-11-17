import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MarketerApprovalPage extends StatefulWidget {
  const MarketerApprovalPage({super.key});

  @override
  State<MarketerApprovalPage> createState() => _MarketerApprovalPageState();
}

class _MarketerApprovalPageState extends State<MarketerApprovalPage> {
  List<Map<String, dynamic>> pendingUsers = [];

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = prefs.getStringList('pendingApprovals') ?? [];
    setState(() {
      pendingUsers = pendingData
          .map((e) => jsonDecode(e) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _approveUser(Map<String, dynamic> user) async {
    String selectedType = 'Type 1';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Select User Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Type 1'),
                value: 'Type 1',
                groupValue: selectedType,
                onChanged: (val) {
                  setStateDialog(() => selectedType = val!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Type 2'),
                value: 'Type 2',
                groupValue: selectedType,
                onChanged: (val) {
                  setStateDialog(() => selectedType = val!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                user['userType'] = selectedType;

                final prefs = await SharedPreferences.getInstance();

                final approved = prefs.getStringList('approvedUsers') ?? [];
                approved.add(jsonEncode(user));
                await prefs.setStringList('approvedUsers', approved);

                final pending = prefs.getStringList('pendingApprovals') ?? [];
                pending.removeWhere(
                  (element) =>
                      jsonDecode(element)['username'] == user['username'],
                );
                await prefs.setStringList('pendingApprovals', pending);

                Navigator.pop(context);
                _loadPendingUsers(); 
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rejectUser(Map<String, dynamic> user) async {
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject User',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter rejection reason',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              final rejected = prefs.getStringList('rejectedUsers') ?? [];
              user['rejectionReason'] = reasonController.text;
              rejected.add(jsonEncode(user));
              await prefs.setStringList('rejectedUsers', rejected);

              final pending = prefs.getStringList('pendingApprovals') ?? [];
              pending.removeWhere(
                (e) => jsonDecode(e)['username'] == user['username'],
              );
              await prefs.setStringList('pendingApprovals', pending);

              Navigator.pop(context);
              _loadPendingUsers(); // refresh list
            },
            child: Text(
              'Reject',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
            leading: IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MarketerHome()),
                );
              },
              icon: const Icon(Icons.home, color: Colors.white),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Pending Approvals',
                style: GoogleFonts.poppins(
                  fontSize: 22,
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

      body: pendingUsers.isEmpty
          ? Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    "No pending approvals",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                final user = pendingUsers[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company Name: ${user['company'] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GST Number   : ${user['gst'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone        : ${user['phone'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Address      : ${user['address'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Email - Id   : ${user['email'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Username     : ${user['username'] ?? ''}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Password     : ${user['password'] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           ElevatedButton(
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color.fromARGB(255, 174, 248, 177),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                             ),
                             onPressed: () => _approveUser(user),
                             child: const Text(
                               "Accept",
                               style: TextStyle(color: Colors.black),
                             ),
                           ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 245, 148, 141),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _rejectUser(user),
                          child: const Text(
                            "Reject",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ],
                       )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


