// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
// import 'package:furniture_ecom_app/marketers/gst_api_service.dart';
// import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';

// class RegisterDealerPage extends StatefulWidget {
//   final String gstNumber;
//   const RegisterDealerPage({super.key, required this.gstNumber});

//   @override
//   State<RegisterDealerPage> createState() => _RegisterDealerPageState();
// }

// class _RegisterDealerPageState extends State<RegisterDealerPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _companyNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isLoading = false;
//   bool _hidePassword = true;

  
// @override
// void initState() {
//   super.initState();
//   _checkGstTokenValidity();
// }

// Future<void> _checkGstTokenValidity() async {
//   final valid = await GSTApiService.isGstTokenValid();
//   if (!valid && mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("⚠️ GST token expired. Please verify again.")),
//     );
//     Navigator.pop(context); // Go back to GST Verification page
//   }
// }


//   Future<void> _registerDealer() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final response = await DealerApiService.registerDealer(
//       companyName: _companyNameController.text.trim(),
//       phoneNumber: _phoneController.text.trim(),
//       gstNumber: widget.gstNumber.trim(),
//       address: _addressController.text.trim(),
//       email: _emailController.text.trim(),
//       username: _usernameController.text.trim(),
//       password: _passwordController.text.trim(),
//     );

//     setState(() => _isLoading = false);
// if (response["success"]) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text("✅ ${response["message"]}")),
//   );

//   Navigator.pushAndRemoveUntil(
//     context,
//     MaterialPageRoute(builder: (_) => const MarketerHome()),
//     (route) => false, 
//   );
// }

//      else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ ${response["message"]}")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Register Dealer")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _companyNameController,
//                 decoration: const InputDecoration(labelText: "Company Name"),
//                 validator: (v) => v!.isEmpty ? "Enter company name" : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(labelText: "Phone Number"),
//                 validator: (v) => v!.isEmpty ? "Enter phone number" : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 enabled: false, // ✅ GST prefilled and locked
//                 initialValue: widget.gstNumber,
//                 decoration: const InputDecoration(
//                   labelText: "Verified GST Number",
//                   suffixIcon: Icon(Icons.verified, color: Colors.green),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(labelText: "Address"),
//                 validator: (v) => v!.isEmpty ? "Enter address" : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//                 validator: (v) => v!.isEmpty ? "Enter email" : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(labelText: "Username"),
//                 validator: (v) => v!.isEmpty ? "Enter username" : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: _hidePassword,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _hidePassword ? Icons.visibility_off : Icons.visibility,
//                     ),
//                     onPressed: () =>
//                         setState(() => _hidePassword = !_hidePassword),
//                   ),
//                 ),
//                 validator: (v) =>
//                     v == null || v.length < 6 ? "Min 6 characters" : null,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 icon: _isLoading
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Icon(Icons.person_add),
//                 label: Text(_isLoading ? "Registering..." : "Register Dealer"),
//                 onPressed: _isLoading ? null : _registerDealer,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/marketers/dealers_api_service.dart';
import 'package:furniture_ecom_app/marketers/gst_api_service.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';

class RegisterDealerPage extends StatefulWidget {
  final String gstNumber;
  const RegisterDealerPage({super.key, required this.gstNumber});

  @override
  State<RegisterDealerPage> createState() => _RegisterDealerPageState();
}

class _RegisterDealerPageState extends State<RegisterDealerPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _checkGstTokenValidity();
  }

  Future<void> _checkGstTokenValidity() async {
    final valid = await GSTApiService.isGstTokenValid();
    if (!valid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ GST token expired. Please verify again.")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _registerDealer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await DealerApiService.registerDealer(
      companyName: _companyNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      gstNumber: widget.gstNumber.trim(),
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${response["message"]}")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MarketerHome()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${response["message"]}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
                'Register Dealer',
                style: GoogleFonts.poppins(
                  fontSize: 20,
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
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.03,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // Company Name
                      _buildTextField(
                        controller: _companyNameController,
                        label: "Company Name",
                        icon: Icons.business,
                        validator: (v) =>
                            v!.isEmpty ? "Enter company name" : null,
                      ),
                      const SizedBox(height: 15),

                      // Phone
                      _buildTextField(
                        controller: _phoneController,
                        label: "Phone Number",
                        icon: Icons.phone,
                        validator: (v) =>
                            v!.isEmpty ? "Enter phone number" : null,
                      ),
                      const SizedBox(height: 15),

                      // GST (disabled)
                      TextFormField(
                        enabled: false,
                        initialValue: widget.gstNumber,
                        decoration: InputDecoration(
                          labelText: "Verified GST Number",
                          prefixIcon: const Icon(Icons.verified, color: Colors.green),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Address
                      _buildTextField(
                        controller: _addressController,
                        label: "Address",
                        icon: Icons.location_on,
                        validator: (v) =>
                            v!.isEmpty ? "Enter address" : null,
                      ),
                      const SizedBox(height: 15),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                        validator: (v) =>
                            v!.isEmpty ? "Enter email" : null,
                      ),
                      const SizedBox(height: 15),

                      // Username
                      _buildTextField(
                        controller: _usernameController,
                        label: "Username",
                        icon: Icons.person,
                        validator: (v) =>
                            v!.isEmpty ? "Enter username" : null,
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        cursorColor: mythemecolor,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock_outline, color: mythemecolor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: mythemecolor,
                            ),
                            onPressed: () => setState(
                                () => _hidePassword = !_hidePassword),
                          ),
                          labelText: "Password",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.length < 6
                                ? "Min 6 characters"
                                : null,
                      ),
                      const SizedBox(height: 25),

                      // Register Button
                      Center(
                        child: SizedBox(
                          width: 180,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.person_add, color: Colors.white),
                            label: Text(
                              _isLoading
                                  ? "Registering..."
                                  : "Register Dealer",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mythemecolor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                            ),
                            onPressed: _isLoading ? null : _registerDealer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: mythemecolor,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: mythemecolor),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
