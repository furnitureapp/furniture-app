// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/core/services/user_service.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'user_profile.dart';

// class EditUserDetailsPage extends StatefulWidget {
//   const EditUserDetailsPage({super.key});

//   @override
//   _EditUserDetailsPageState createState() => _EditUserDetailsPageState();
// }

// class _EditUserDetailsPageState extends State<EditUserDetailsPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _usernameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _phoneController = TextEditingController();

//   bool _isLoading = false;
//   String? _userEmail;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('auth_token');
//     final email = prefs.getString('user_email');
//     final username = prefs.getString('username') ?? '';
//     final address = prefs.getString('address') ?? '';
//     final phoneNo = prefs.getString('phoneNo') ?? '';

//     if (token == null || email == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Missing credentials. Please log in again.')),
//       );
//       return;
//     }

//     setState(() {
//       _userEmail = email;
//       _usernameController.text = username;
//       _addressController.text = address;
//       _phoneController.text = phoneNo;
//     });
//   }

//   Future<void> _updateUserDetails() async {
//     if (_formKey.currentState?.validate() != true) return;

//     if (_userEmail == null) return;

//     setState(() => _isLoading = true);

//     final result = await UserService.editUserDetails(
//       email: _userEmail!,
//       username: _usernameController.text.trim(),
//       address: _addressController.text.trim(),
//       phoneNo: _phoneController.text.trim(),
//     );

//     setState(() => _isLoading = false);

//     if (result['success']) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('username', _usernameController.text.trim());
//       await prefs.setString('address', _addressController.text.trim());
//       await prefs.setString('phoneNo', _phoneController.text.trim());

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('✅ ${result['message']}')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const ProfileScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('❌ ${result['message']}')),
//       );
//     }
//   }

//   String? _validateUsername(String? username) {
//     return (username == null || username.trim().isEmpty)
//         ? "Username is required!"
//         : null;
//   }

//   String? _validatePhoneNumber(String? phoneNo) {
//     if (phoneNo == null || phoneNo.trim().isEmpty) {
//       return "Phone number is required!";
//     }
//     final cleaned = phoneNo.trim().replaceAll(RegExp(r'\D'), '');
//     final phoneRegex = RegExp(r'^[6-9]\d{9}$');
//     if (!phoneRegex.hasMatch(cleaned)) {
//       return "Enter a valid 10-digit  phone number";
//     }

//     return null;
//   }

//   String? _validateCity(String? city) {
//     if (city == null || city.trim().isEmpty) {
//       return "City name is required!";
//     }

//     final cityRegex = RegExp(r'^[A-Za-z\s]{2,}$');

//     if (!cityRegex.hasMatch(city.trim())) {
//       return "Enter a valid city name (letters only)";
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     // final screenHeight = MediaQuery.of(context).size.height;
//     final bool isTablet = screenWidth >= 600;

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                   mythemecolor1,
//                mythemecolor,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: Text(
//               "Edit your Profile",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             centerTitle: true,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: mythemecolor))
//           : Stack(
//               children: [
//                 Positioned.fill(
//                   child: Image.asset(
//                     isTablet
//                         ? 'assets/images/theme.png'
//                         : 'assets/images/theme.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 Positioned.fill(
//                   child: RefreshIndicator(
//                     onRefresh: _loadUserData,
//                     color: mythemecolor,
//                     child: SingleChildScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       padding: EdgeInsets.only(
//                         top: isTablet ? 60 : 70,
//                         bottom: MediaQuery.of(context).viewInsets.bottom,
//                       ),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: isTablet ? 500 : double.infinity,
//                               margin:
//                                   const EdgeInsets.symmetric(horizontal: 20),
//                               padding: const EdgeInsets.all(30),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.75),
//                                 borderRadius: BorderRadius.circular(20),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 5),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(bottom: 20),
//                                     child: Image.asset(
//                                       'assets/images/users.png',
//                                       height: 100,
//                                       width: 100,
//                                     ),
//                                   ),
//                                   TextFormField(
//                                     controller: _usernameController,
//                                     validator: _validateUsername,
//                                     keyboardType: TextInputType.emailAddress,
//                                     decoration: InputDecoration(
//                                       labelText: 'Enter your Username',
//                                       labelStyle: TextStyle(
//                                         color: mythemecolor,
//                                         fontSize: isTablet ? 18 : 14,
//                                       ),
//                                       prefixIcon: const Icon(Icons.person,
//                                           color: mythemecolor),
//                                       enabledBorder: UnderlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: Colors.grey.shade400,
//                                             width: 2),
//                                       ),
//                                       focusedBorder: UnderlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: mythemecolor,
//                                             width: 2.5),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   TextFormField(
//                                     controller: _phoneController,
//                                     keyboardType: TextInputType.phone,
//                                     validator: _validatePhoneNumber,
//                                     decoration: InputDecoration(
//                                       labelText: 'Enter your Phone Number',
//                                       labelStyle: TextStyle(
//                                         color: mythemecolor,
//                                         fontSize: isTablet ? 18 : 14,
//                                       ),
//                                       prefixIcon: const Icon(Icons.phone,
//                                           color: mythemecolor),
//                                       prefix: const Padding(
//                                         padding: EdgeInsets.only(right: 8.0),
//                                         child: Text("🇮🇳 |",
//                                             style: TextStyle(fontSize: 16)),
//                                       ),
//                                       enabledBorder: UnderlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: Colors.grey.shade400,
//                                             width: 2),
//                                       ),
//                                       focusedBorder: UnderlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: mythemecolor,
//                                             width: 2.5),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   TextFormField(
//                                     controller: _addressController,
//                                     validator: _validateCity,
//                                     keyboardType: TextInputType.streetAddress,
//                                     decoration: InputDecoration(
//                                       labelText: 'Enter your City',
//                                       labelStyle: TextStyle(
//                                         color: mythemecolor,
//                                         fontSize: isTablet ? 18 : 14,
//                                       ),
//                                       prefixIcon: const Icon(Icons.location_on,
//                                           color: mythemecolor),
//                                       enabledBorder: UnderlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: Colors.grey.shade400,
//                                             width: 2),
//                                       ),
//                                       focusedBorder: UnderlineInputBorder(
//                                         borderSide: BorderSide(
//                                             color: mythemecolor,
//                                             width: 2.5),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 30),
//                                   _isLoading
//                                       ? const CircularProgressIndicator(
//                                           color: mythemecolor)
//                                       : ElevatedButton(
//                                           onPressed: _updateUserDetails,
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: isTablet
//                                                 ? Colors.white
//                                                 : mythemecolor,
//                                             padding: EdgeInsets.symmetric(
//                                               horizontal: isTablet ? 40 : 30,
//                                               vertical: isTablet ? 14 : 12,
//                                             ),
//                                             textStyle: TextStyle(
//                                               fontSize: isTablet ? 18 : 14,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             foregroundColor: isTablet
//                                                 ? mythemecolor
//                                                 : Colors.white,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                           ),
//                                           child: Text("Save Changes"),
//                                         ),
//                                   const SizedBox(height: 30),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                                 height:
//                                     MediaQuery.of(context).viewInsets.bottom > 0
//                                         ? MediaQuery.of(context)
//                                                 .viewInsets
//                                                 .bottom +
//                                             20
//                                         : 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget buildValidatedTextField({
//     required BuildContext context,
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String) validator,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return SizedBox(
//       width: 500,
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(
//               color: Color.fromARGB(255, 26, 82, 10),
//               fontSize: 18,
//               fontWeight: FontWeight.bold),
//           prefixIcon: Icon(icon, color: Colors.red),
//           enabledBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: mythemecolor, width: 2),
//           ),
//           focusedBorder: const UnderlineInputBorder(
//             borderSide:
//                 BorderSide(color: Color.fromARGB(255, 26, 82, 10), width: 2.5),
//           ),
//           errorBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.red, width: 2),
//           ),
//         ),
//         onChanged: (value) {
//           final error = validator(value);
//           if (error != null) {
//             showTopSnackBar(context, '❌ $error');
//             // ScaffoldMessenger.of(context).showSnackBar(
//             //   SnackBar(
//             //     content: Text('❌ $error'),
//             //   ),
//             // );
//           }
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services/user_service.dart';

class EditUserProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditUserProfilePage({super.key, required this.userData});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Autofill all fields
    emailController.text = widget.userData["email"] ?? "";
    companyController.text = widget.userData["companyName"] ?? "";
    usernameController.text = widget.userData["username"] ?? "";
    phoneController.text = widget.userData["phoneNumber"] ?? "";
    addressController.text = widget.userData["address"] ?? "";
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    final result = await UserService.updateDealer(
      dealerId: widget.userData["_id"], // ✔ NEVER NULL NOW
      phoneNumber: phoneController.text.trim(),
      address: addressController.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"] ?? "Update failed"),
        backgroundColor: result["success"] ? Colors.green : Colors.red,
      ),
    );

    if (result["success"]) {
      Navigator.pop(context, true); // Return success
    }
  }

  Widget buildReadOnlyField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget buildEditableField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Read-only fields
            buildReadOnlyField("Email", emailController),
            buildReadOnlyField("Company Name", companyController),
            buildReadOnlyField("Username", usernameController),

            // Editable fields
            buildEditableField("Phone Number", phoneController),
            buildEditableField("Address", addressController, maxLines: 3),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateProfile,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
