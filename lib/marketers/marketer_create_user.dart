import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/marketers/marketer_approval.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MarketerCreateUserPage extends StatefulWidget {
  const MarketerCreateUserPage({super.key});

  @override
  State<MarketerCreateUserPage> createState() => _MarketerCreateUserPageState();
}

class _MarketerCreateUserPageState extends State<MarketerCreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> userData = {};

  Future<void> _registerUser() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = prefs.getStringList('pendingApprovals') ?? [];
    pendingData.add(jsonEncode(userData));
    await prefs.setStringList('pendingApprovals', pendingData);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WaitForApprovalPage(
          onNavigateApproval: () {
           Navigator.pushAndRemoveUntil(context,
             MaterialPageRoute(builder: (_) => const MarketerApprovalPage()),
             (route) => false,
           ); 
          },
        ),
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
            iconTheme: const IconThemeData(color: Colors.white),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Create Users',
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
      drawer: const MarketerDrawer(currentPage: "Create User"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Company Name", "company"),
              _buildTextField(
                "Phone Number",
                "phone",
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                "GST Number",
                "gst",
                validator: (val) {
                  if (val == null || val.isEmpty) return "Required";
                  if (val.length != 15) return "Invalid GST Format";
                  return null;
                },
              ),
              _buildTextField("Address", "address"),
              _buildTextField(
                "Email",
                "email",
                validator: (val) =>
                    val != null && val.contains("@") ? null : "Invalid email",
              ),
              _buildTextField("Username", "username"),
              _buildTextField("Password", "password", obscure: true),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _registerUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    backgroundColor: marketerprimaryColor,
                    elevation: 4,
                  ),
                  child: Text(
                    "Register",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String key, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator ?? (val) => val!.isEmpty ? "Required" : null,
        onSaved: (val) => userData[key] = val ?? '',
      ),
    );
  }
}

class WaitForApprovalPage extends StatelessWidget {
  final VoidCallback onNavigateApproval;

  const WaitForApprovalPage({super.key, required this.onNavigateApproval});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
    
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_top,
                  color: marketerprimaryColor,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  "Kindly wait, once the registration & GST approval is done, you can proceed.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onNavigateApproval,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: marketerprimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      "Go to Approval Page",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
