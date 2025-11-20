// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
// import 'package:furniture_ecom_app/marketers/gst_api_service.dart';
// import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';

// class RegisterDealerPage extends StatefulWidget {
//   final String gstNumber;
//   final String tradeName;
//   final String address;

//   const RegisterDealerPage({
//     super.key,
//     required this.gstNumber,
//     required this.tradeName,
//     required this.address,
//   });

//   @override
//   State<RegisterDealerPage> createState() => _RegisterDealerPageState();
// }

// class _RegisterDealerPageState extends State<RegisterDealerPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _gstController = TextEditingController();

//   final _companyNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isLoading = false;
//   bool _hidePassword = true;

//   @override
//   void initState() {
//     super.initState();
//     _gstController.text = widget.gstNumber;

//     _companyNameController.text = widget.tradeName; // autofill
//     _addressController.text = widget.address; // autofill

//     _checkGstTokenValidity();
//   }

//   Future<void> _checkGstTokenValidity() async {
//     final valid = await GSTApiService.isGstTokenValid();
//     if (!valid && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("⚠️ GST token expired. Please verify again."),
//         ),
//       );
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _registerDealer() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final response = await DealerApiService.registerDealer(
//       companyName: _companyNameController.text.trim(),
//       phoneNumber: _phoneController.text.trim(),
//       gstNumber: _gstController.text.trim(),
//       address: _addressController.text.trim(),
//       email: _emailController.text.trim(),
//       username: _usernameController.text.trim(),
//       password: _passwordController.text.trim(),
//     );

//     setState(() => _isLoading = false);

//     if (response["success"]) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("✅ ${response["message"]}")));

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const MarketerHome()),
//         (route) => false,
//       );
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("❌ ${response["message"]}")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(255, 221, 197, 251),
//                 Colors.white,
//                 Color.fromARGB(255, 221, 197, 251),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: mythemecolor),
//             title: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Text(
//                 'Register Dealer',
//                 style: GoogleFonts.poppins(
//                   fontSize: isTablet(context) ? 22 : 12,
//                   fontWeight: FontWeight.w600,
//                   color: mythemecolor,
//                 ),
//               ),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//           ),
//         ),
//       ),

//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool tablet = constraints.maxWidth > 600;

//             return SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(
//                         255,
//                         220,
//                         212,
//                         218,
//                       ).withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(24),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 15,
//                           spreadRadius: 2,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 25),

//                         // ---------- FORM GRID (TABLET: TWO COLUMNS) ----------
//                         GridView(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: tablet
//                                     ? 2
//                                     : 1, // 2-columns on tablet
//                                 crossAxisSpacing: 16,
//                                 mainAxisSpacing: tablet ? 18 : 8,
//                                 childAspectRatio: tablet ? 3.3 : 4.5,
//                               ),

//                           children: [
//                             // Company Name
//                             _buildPremiumField(
//                               controller: _companyNameController,
//                               label: "Company Name",
//                               icon: Icons.business,
//                               readOnly: true,
//                             ),

//                             // GST Number
//                             _buildPremiumField(
//                               controller: _gstController,
//                               label: "Verified GST Number",
//                               icon: Icons.verified,
//                               readOnly: true,
//                             ),

//                             // Address
//                             _buildPremiumField(
//                               controller: _addressController,
//                               label: "Address",
//                               icon: Icons.location_on,
//                               readOnly: true,
//                             ),

//                             // Phone Number
//                             _buildPremiumField(
//                               controller: _phoneController,
//                               label: "Phone Number",
//                               icon: Icons.phone,
//                               validator: (v) =>
//                                   v!.isEmpty ? "Enter phone number" : null,
//                             ),

//                             // Email
//                             _buildPremiumField(
//                               controller: _emailController,
//                               label: "Email",
//                               icon: Icons.email_outlined,
//                               validator: (v) =>
//                                   v!.isEmpty ? "Enter email" : null,
//                             ),

//                             // Username
//                             _buildPremiumField(
//                               controller: _usernameController,
//                               label: "Username",
//                               icon: Icons.person,
//                               validator: (v) =>
//                                   v!.isEmpty ? "Enter username" : null,
//                             ),

//                             // Password
//                             _buildPasswordField(),
//                           ],
//                         ),

//                         const SizedBox(height: 30),

//                         // REGISTER BUTTON
//                         Center(
//                           child: SizedBox(
//                             width: tablet ? 250 : 180,
//                             height: tablet ? 55 : 50,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: mythemecolor,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 elevation: 8,
//                               ),
//                               onPressed: _isLoading ? null : _registerDealer,
//                               child: _isLoading
//                                   ? const CircularProgressIndicator(
//                                       color: Colors.white,
//                                     )
//                                   : Text(
//                                       "Register Dealer",
//                                       style: GoogleFonts.poppins(
//                                         fontSize: tablet ? 20 : 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 40),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildPremiumField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool readOnly = false,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       readOnly: readOnly,
//       validator: validator,
//       style: TextStyle(color: readOnly ? Colors.grey.shade700 : Colors.black),
//       decoration: InputDecoration(
//         labelText: label,
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         prefixIcon: Icon(icon, color: readOnly ? Colors.grey : mythemecolor),
//         filled: true,
//         fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
//         labelStyle: TextStyle(
//           color: readOnly ? Colors.grey : mythemecolor,
//           fontWeight: FontWeight.w500,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: mythemecolor, width: 1.5),
//         ),
//       ),
//     );
//   }

//   Widget _buildPasswordField() {
//     return TextFormField(
//       controller: _passwordController,
//       obscureText: _hidePassword,
//       decoration: InputDecoration(
//         labelText: "Password",
//         prefixIcon: Icon(Icons.lock_outline, color: mythemecolor),
//         suffixIcon: IconButton(
//           icon: Icon(
//             _hidePassword ? Icons.visibility_off : Icons.visibility,
//             color: mythemecolor,
//           ),
//           onPressed: () => setState(() => _hidePassword = !_hidePassword),
//         ),
//         filled: true,
//         fillColor: Colors.white,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: mythemecolor, width: 1.5),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/marketers/models/activity.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterDealerPage extends StatefulWidget {
  final String gstNumber;
  const RegisterDealerPage({super.key, required this.gstNumber});

  @override
  State<RegisterDealerPage> createState() => _RegisterDealerPageState();
}

class _RegisterDealerPageState extends State<RegisterDealerPage> {
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

  Future<void> _registerDealer() async {
    if (!_formKey.currentState!.validate()) return;

    // extra safety: ensure gst present
    final gst = _gstController.text.trim();
    if (gst.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GST number missing. Please verify again.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await DealerApiService.registerDealer(
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ ${response["message"]}")));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MarketerHome()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${response['message'] ?? 'Failed to register dealer.'}")),
      );
    }
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
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: mythemecolor),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Register Dealer',
                style: GoogleFonts.poppins(fontSize: isTablet ? 22 : 12, fontWeight: FontWeight.w600, color: mythemecolor),
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
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // company name (read only)
                      TextFormField(
                        controller: _companyNameController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Company Name',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: const Icon(Icons.business),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // gst readonly
                      TextFormField(
                        controller: _gstController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Verified GST Number',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: const Icon(Icons.verified, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // address
                      TextFormField(
                        controller: _addressController,
                        readOnly: true,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: const Icon(Icons.location_on),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // phone
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone number' : null,
                      ),
                      const SizedBox(height: 12),
                      // email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      // username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 12),
                      // password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _registerDealer,
                          style: ElevatedButton.styleFrom(backgroundColor: mythemecolor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Register Dealer', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
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
