import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services/auth_service.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/forgot_password.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/otp_screen.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/register_user.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final String? redirectRoute;
  final String? productId;

  const LoginScreen({super.key, this.redirectRoute, this.productId});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password is required";
    }
    final passwordRegex = RegExp(r'^(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{5,}$');
    if (!passwordRegex.hasMatch(password)) {
      return "Password must be 5+ characters with \n a special characters (!@#\$%^&*)";
    }
    return null;
  }

  // Future<void> _loginUser() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response = await AuthService.login(
  //       _emailController.text.trim(),
  //       _passwordController.text.trim(),
  //     );

  //     if (response['success'] == true &&
  //         response['message'] == "Login successful") {
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('user_email', _emailController.text.trim());

  //       final fcmToken = await FirebaseMessaging.instance.getToken();
  //       if (fcmToken != null) {
  //         await prefs.setString('fcm_token', fcmToken);
  //       }

  //       String redirectRoute = prefs.getString('redirectRoute') ?? '/';
  //       String? productId = prefs.getString('productId');

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => VerifyOtpScreen(
  //             email: _emailController.text.trim(),
  //             redirectRoute: redirectRoute,
  //             productId: productId,
  //           ),
  //         ),
  //       );
  //     } else {
  //       final errorMessage = response['message'] ?? "Login Failed!";
  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   SnackBar(content: Text(' $errorMessage')),
  //       // );
  //       showTopSnackBar(context, '❌ $errorMessage');
  //     }
  //   } catch (e) {
  //     // ScaffoldMessenger.of(context).showSnackBar(
  //     //   SnackBar(content: Text('❌ Error occurred during login!')),
  //     // );
  //     showTopSnackBar(context, '❌ Error occurred during login!');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

   Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

if (response['success'] == true) {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_email', _emailController.text.trim());

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    await prefs.setString('fcm_token', fcmToken);
  }

  String redirectRoute = prefs.getString('redirectRoute') ?? '/';
  String? productId = prefs.getString('productId');

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => VerifyOtpScreen(
        email: _emailController.text.trim(),
        redirectRoute: redirectRoute,
        productId: productId,
      ),
    ),
  );
} else {
  final errorMessage = response['message'] ?? "Login Failed!";
  showTopSnackBar(context, '❌ $errorMessage');
}
    }
    catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('❌ Error occurred during login!')),
      // );
      showTopSnackBar(context, '❌ Error occurred during login!');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    print("screen width: ${MediaQuery.of(context).size.width}");
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                  mythemecolor1,
               mythemecolor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BottomNavBar()),
                  (route) => false,
                );
              },
            ),
            title: const Text(
              "Login to Fresh Grocery",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/theme.png', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: isTablet ? 60 : 60,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: _formKey,
                child: Center(
                  child: Container(
                    width: isTablet ? 500 : double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: isTablet ? 0 : 20),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: isTablet
                          ? const Color.fromARGB(
                              255,
                              232,
                              239,
                              232,
                            ).withOpacity(0.75)
                          : Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
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
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.green,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade800,
                                width: 2,
                              ),
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
                          controller: _passwordController,
                          obscureText: _obscureText,
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            labelText: 'Enter your Password',
                            labelStyle: TextStyle(
                              color: tdgreen,
                              fontSize: isTablet ? 18 : 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.green,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.green,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade800,
                                width: 2,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green.shade800,
                                width: 2.5,
                              ),
                            ),
                            helperText:
                                "your password must be Min 5 characters, \n including a special character (!@#\$%^&*)",
                            helperStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isTablet ? 18 : 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 101, 101, 101),
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 18 : 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator(color: mythemecolor)
                            : ElevatedButton(
                                onPressed: _loginUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isTablet
                                      ? Colors.white
                                      : Colors.green,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 40 : 30,
                                    vertical: isTablet ? 14 : 12,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: isTablet ? 18 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  foregroundColor: isTablet
                                      ? Colors.green.shade700
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("LOGIN"),
                              ),
                        const SizedBox(height: 30),
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: tdgreen,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Register Now",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 61, 60, 60),
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
