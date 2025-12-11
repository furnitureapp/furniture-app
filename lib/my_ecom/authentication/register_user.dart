import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services_ecom/auth_service.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _validateUsername(String? username) {
    return (username == null || username.trim().isEmpty)
        ? "Username is required!"
        : null;
  }

  //  String? _validateAddress(String? address) {
  //   if (address == null || address.trim().isEmpty) {
  //     return "Address is required!";
  //   }

  //   final addressRegex = RegExp(
  //     r'^\s*\d+\s*,\s*[\w\s]+\s*,\s*[\w\s]+\s*,\s*\d{6}\s*$'
  //   );

  //   if (!addressRegex.hasMatch(address.trim())) {
  //     return "Enter address in format:\nDoor No, Street Name, City, Pincode";
  //   }

  //   return null;
  // }

  String? _validateCity(String? city) {
    if (city == null || city.trim().isEmpty) {
      return "City name is required!";
    }

    final cityRegex = RegExp(r'^[A-Za-z\s]{2,}$');

    if (!cityRegex.hasMatch(city.trim())) {
      return "Enter a valid city name (letters only)";
    }

    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Email is required!";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password is required!";
    }
    final passwordRegex = RegExp(r'^(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{5,}$');
    if (!passwordRegex.hasMatch(password)) {
      return "Password must be 5+ characters with \n a special characters (!@#\$%^&*)";
    }
    return null;
  }

  String? _validatePhoneNumber(String? phoneNo) {
    if (phoneNo == null || phoneNo.trim().isEmpty) {
      return "Phone number is required!";
    }
    final cleaned = phoneNo.trim().replaceAll(RegExp(r'\D'), '');
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return "Enter a valid 10-digit  phone number";
    }

    return null;
  }

  String? _validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return "Confirming your Password is required!";
    }
    return confirmPassword == _passwordController.text
        ? null
        : "Passwords do not match";
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String phoneNo = _phoneNoController.text.trim();
    String address = _addressController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.register(
        email,
        username,
        password,
        confirmPassword,
        phoneNo,
        address,
      );

      log('Response: $response');

      if (response['success'] == true) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Registration Successful!")),
        // );
        showTopSnackBar(context, "Registration Successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        final message = response['message']?.toLowerCase() ?? '';

        if (message.contains("user already exists")) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("User already exists. Please login.")),
          // );
          showTopSnackBar(context, "User already exists. Please login.");

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //       content: Text(response['message'] ?? "Registration failed.")),
          // );
          showTopSnackBar(
            context,
            response['message'] ?? "Registration failed.",
          );
        }
      }
    } catch (e) {
      log('Registration error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("An unexpected error occurred")),
      // );
      showTopSnackBar(context, "An unexpected error occurred");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _formKey.currentState?.reset();
      _emailController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _phoneNoController.clear();
      _addressController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    Widget registerForm = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Enter your Email',
              labelStyle: TextStyle(
                color: tdgreen,
                fontSize: isTablet ? 18 : 14,
              ),
              prefixIcon: const Icon(Icons.email, color: Colors.green),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green.shade800,
                  width: 2.5,
                ),
              ),
              helperText: "e.g., example@gmail.com",
              helperStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 18 : 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            validator: _validateUsername,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Enter your Username',
              labelStyle: TextStyle(
                color: tdgreen,
                fontSize: isTablet ? 18 : 14,
              ),
              prefixIcon: const Icon(Icons.person, color: Colors.green),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green.shade800,
                  width: 2.5,
                ),
              ),
              helperText: "e.g., James robert, Hari Krishnan",
              helperStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 18 : 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Enter your Password',
              labelStyle: TextStyle(
                color: tdgreen,
                fontSize: isTablet ? 18 : 14,
              ),
              prefixIcon: const Icon(Icons.lock, color: Colors.green),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.green,
                ),
                onPressed: _togglePasswordVisibility,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green.shade800,
                  width: 2.5,
                ),
              ),
              helperText:
                  "Min 5 characters, including a special \ncharacter (!@#\$%^&*)",
              helperStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 18 : 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(
                color: tdgreen,
                fontSize: isTablet ? 18 : 14,
              ),
              prefixIcon: const Icon(Icons.lock, color: Colors.green),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.green,
                ),
                onPressed: _toggleConfirmPasswordVisibility,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green.shade800,
                  width: 2.5,
                ),
              ),
              helperText: 'Must match your entered password',
              helperStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 18 : 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _phoneNoController,
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
            decoration: InputDecoration(
              labelText: 'Enter your Phone Number',
              labelStyle: TextStyle(
                color: tdgreen,
                fontSize: isTablet ? 18 : 14,
              ),
              prefixIcon: const Icon(Icons.phone, color: Colors.green),
              prefix: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text("🇮🇳 |", style: TextStyle(fontSize: 16)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green.shade800,
                  width: 2.5,
                ),
              ),
              helperText: "e.g., 9876543210",
              helperStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 18 : 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            validator: _validateCity,
            keyboardType: TextInputType.streetAddress,
            decoration: InputDecoration(
              labelText: 'Enter your City',
              labelStyle: TextStyle(
                color: tdgreen,
                fontSize: isTablet ? 18 : 14,
              ),
              prefixIcon: const Icon(Icons.location_on, color: Colors.green),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.green.shade800,
                  width: 2.5,
                ),
              ),
              helperText: "e.g., Madurai, Chennai",
              helperStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isTablet ? 18 : 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator(color: mythemecolor)
              : ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTablet ? Colors.white : Colors.green,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 30,
                      vertical: isTablet ? 14 : 12,
                    ),
                    textStyle: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor: isTablet
                        ? Colors.green.shade700
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Register"),
                ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Already have an account? ",
                  style: TextStyle(
                    fontSize: isTablet ? 19 : 13,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 99, 103, 99),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Color.fromARGB(255, 13, 95, 30),
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 19 : 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 237, 225),
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mythemecolor1, mythemecolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Register here!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color.fromARGB(255, 22, 97, 33),
                backgroundColor: const Color.fromARGB(255, 253, 252, 253),
                displacement: 50,
                strokeWidth: 2.5,
                child:
                    // SingleChildScrollView(
                    //   physics: AlwaysScrollableScrollPhysics(),
                    //   padding:
                    //       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    //   child: Center(
                    //     child: ConstrainedBox(
                    //       constraints: BoxConstraints(
                    //         maxWidth: isTablet ? 500 : double.infinity,
                    //       ),
                    //       child: Card(
                    //         color: Colors.white.withOpacity(0.85),
                    //         elevation: isTablet ? 10 : 5,
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(20),
                    //           child: registerForm,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: IntrinsicHeight(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: isTablet
                                          ? 500
                                          : double.infinity,
                                    ),
                                    child: Card(
                                      color: Colors.white.withOpacity(0.85),
                                      elevation: isTablet ? 10 : 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: registerForm,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// const SizedBox(height: 20),
          // RichText(
          //   textAlign: TextAlign.left,
          //   text: TextSpan(
          //     children: [
          //       TextSpan(
          //         text: "Note: ",
          //         style: TextStyle(
          //           fontSize: 12,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.redAccent,
          //         ),
          //       ),
          //       TextSpan(
          //         text:
          //             " This Address is for user profile purposes only. Delivery address differ",
          //         style: TextStyle(
          //           fontSize: 12,
          //           color: Colors.grey,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
  // Future<void> _registerUser() async {
  //   String email = _emailController.text.trim();
  //   String username = _usernameController.text.trim();
  //   String password = _passwordController.text;
  //   String confirmPassword = _confirmPasswordController.text;
  //   String phoneNo = _phoneNoController.text.trim();
  //   String address = _addressController.text.trim();

  //   String? emailError = _validateEmail(email);
  //   String? passwordError = _validatePassword(password);
  //   String? confirmPasswordError = _validateConfirmPassword(confirmPassword);
  //   String? phoneError = _validatePhoneNumber(phoneNo);

  //   if (emailError != null ||
  //       passwordError != null ||
  //       confirmPasswordError != null ||
  //       phoneError != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           emailError ?? passwordError ?? confirmPasswordError ?? phoneError!,
  //         ),
  //       ),
  //     );
  //     return;
  //   }

  //   if (username.isEmpty || phoneNo.isEmpty || address.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please fill all the fields")),
  //     );

  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response = await ApiService.register(
  //         email, username, password, confirmPassword, phoneNo, address);
  //     log('Response: $response');

  //     if (response['success'] == true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Registration Successful!")),
  //       );

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const LoginScreen()),
  //       );
  //     } else {
  //       final message = response['message']?.toLowerCase() ?? '';

  //       if (message.contains("user already exists")) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("User already exists. Please login.")),
  //         );

  //         Future.delayed(const Duration(seconds: 1), () {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (context) => const LoginScreen()),
  //           );
  //         });
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //               content: Text(response['message'] ?? "Registration failed.")),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     log('Registration error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("An unexpected error occurred")),
  //     );
  //   }
  // }

// Widget buildTextField({
//   required! BuildContext context,
//   required! String label,
//   required! IconData icon,
//   required! TextEditingController controller,
//   bool obscureText = false,
//   Widget? prefix,
//   String? Function(String)? validator,
//   VoidCallback? toggleVisibility,
// }) {
//   return SizedBox(
//     width: 400,
//     child: TextField(
//       controller: controller,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         label: RichText(
//           text: TextSpan(
//             text: label,
//             style: const TextStyle(color: tdgreen, fontSize: 16),
//             children: [
//               TextSpan(
//                 text: ' *',
//                 style: TextStyle(
//                     color: const Color.fromARGB(255, 152, 4, 4),
//                     fontSize: 16,
//                     decorationThickness: 30),
//               ),
//             ],
//           ),
//         ),
//         labelStyle: const TextStyle(color: tdgreen),
//         prefixIcon: Icon(icon, color: Colors.green),
//         prefix: prefix,
//         suffixIcon: toggleVisibility != null
//             ? IconButton(
//                 icon: Icon(
//                   obscureText ? Icons.visibility_off : Icons.visibility,
//                   color: Colors.green,
//                 ),
//                 onPressed: toggleVisibility,
//               )
//             : null,
//         enabledBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.green, width: 2),
//         ),
//         focusedBorder: const UnderlineInputBorder(
//           borderSide:
//               BorderSide(color: Color.fromARGB(255, 34, 87, 19), width: 2),
//         ),
//         errorBorder: const UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.red, width: 2),
//         ),
//       ),
//       onChanged: (value) {
//         if (validator != null) {
//           final errorMessage = validator(value);
//           if (errorMessage != null) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text(errorMessage)),
            // );
//           }
//         }
//       },
//     ),
//   );
// }
