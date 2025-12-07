// UPDATED FILE WITH REFRESH INDICATOR + TABLET UI
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/marketers/models/activity.dart';
import 'package:furniture_ecom_app/my_ecom/userprofile/wait_gst_approval.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/core/api/dealers_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DealerRegistrationPage extends StatefulWidget {
  final String gstNumber;
  const DealerRegistrationPage({super.key, required this.gstNumber});

  @override
  State<DealerRegistrationPage> createState() => _DealerRegistrationPageState();
}

class _DealerRegistrationPageState extends State<DealerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _gstController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _loadingMeta = true;

  @override
  void initState() {
    super.initState();
    _gstController.text = widget.gstNumber;
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString("gst_cache");

    if (cache != null) {
      final json = jsonDecode(cache);
      final model = GstModel.fromJson({'data': json});

      _companyNameController.text = model.tradeName;
      _addressController.text = model.address;
    }

    setState(() => _loadingMeta = false);
  }

  // ✅ RefreshIndicator action
  Future<void> _handleRefresh() async {
    await _loadMetadata();
  }

  Future<void> _registerDealer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("dealer_email", _emailController.text.trim());
    await prefs.setString("dealer_username", _usernameController.text.trim());

    if (!_formKey.currentState!.validate()) return;

    final gst = _gstController.text.trim();
    if (gst.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("GST number missing. Please verify again."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await DealerApiService.selfregisterDealer(
      companyName: _companyNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gstNumber: gst,
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ ${response["message"]}")));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("dealer_pending_approval", true);

      await prefs.setString("dealer_email", _emailController.text.trim());
      await prefs.setString("dealer_username", _usernameController.text.trim());

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WaitForGSTApprovalPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ ${response['message'] ?? 'Failed to register dealer.'}",
          ),
        ),
      );
    }
  }

  // ✅ MOBILE UI (unchanged)
  Widget _buildMobileUI() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: _buildForm(),
    );
  }

  // ✅ PREMIUM TABLET UI
  Widget _buildTabletUI() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: Card(
          elevation: 6,
          shadowColor: mythemecolor.withOpacity(.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Common Form Widget (NOT MODIFIED)
  Widget _buildForm() {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _companyNameController,
              readOnly: true,
              decoration: _readonlyDecoration("Company Name", Icons.business),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gstController,
              readOnly: true,
              decoration: _readonlyDecoration(
                "Verified GST Number",
                Icons.verified,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              readOnly: true,
              maxLines: 2,
              decoration: _readonlyDecoration("Address", Icons.location_on),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _editableDecoration("Phone Number", Icons.phone),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter phone number' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _editableDecoration("Email", Icons.email_outlined),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: _editableDecoration("Username", Icons.person),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter username' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: isTablet ? 260 : 200,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerDealer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mythemecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Register Dealer',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _readonlyDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _editableDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 221, 197, 251),
                Colors.white,
                Color.fromARGB(255, 221, 197, 251),
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
                'REGISTER DEALERS',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 22 : 12,
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
      body: SafeArea(
        child: _loadingMeta
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: isTablet ? _buildTabletUI() : _buildMobileUI(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _gstController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
