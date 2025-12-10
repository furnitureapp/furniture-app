import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/userprofile/dealer_gstverify.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/userprofile/wait_gst_approval.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/core/api/api_service_auth.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/admin/admin_home.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';

class MyLoginScreen extends StatefulWidget {
  const MyLoginScreen({super.key});

  @override
  State<MyLoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> handleLogin() async {
  setState(() => isLoading = true);

  final result = await ApiAuthService.loginUser(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );

  setState(() => isLoading = false);

  // ✅ HANDLE PENDING APPROVAL
  if (result['pending'] == true) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WaitForGSTApprovalPage(
          // email: _emailController.text.trim(),
        ),
      ),
    );
    return;
  }

  // ✅ NORMAL SUCCESS LOGIN
  if (result['success'] == true) {
    final role = result['role'];
    Widget targetScreen;

    switch (role) {
      case 'superadmin':
        targetScreen = const SuperAdminHome();
        break;
      case 'admin':
        targetScreen = const AdminHomes();
        break;
      case 'manager':
        targetScreen = const ManagerHome();
        break;
      case 'marketer':
        targetScreen = const MarketerHome();
        break;
      case 'dealer':
        targetScreen = const BottomNavBar();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown role')),
        );
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
    return;
  }

  // ❌ LOGIN FAILED
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result['message'] ?? 'Login failed')),
  );
}


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final double horizontalPadding = isTablet ? 140 : 24;
    final double logoSize = isTablet ? 130 : 100;
    final double inputFontSize = isTablet ? 15 : 12;
    final double welcomeFont = isTablet ? 24 : 16;

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
                'Login here!',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 26 : 14,
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
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: isTablet ? 40 : 20),
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 25 : 17),
                  decoration: BoxDecoration(
                    color: mythemecolor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/woodpecker_logo.png',
                    height: logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Main body
            Positioned(
              top: screenHeight * (isTablet ? 0.27 : 0.20),
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                      
                        fontSize: welcomeFont,
                        fontWeight: FontWeight.bold,
                        color: mythemecolor,
                      ),
                    ),
                    SizedBox(height: isTablet ? 30 : 20),

                    // Email
                    TextField(
                      cursorHeight: isTablet ? 22 : 18,
                      cursorColor: mythemecolor,
                      controller: _emailController,
                      style: GoogleFonts.poppins(fontSize: inputFontSize),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: mythemecolor,
                        ),
                        hintText: "Email Address",
                        hintStyle: GoogleFonts.poppins(fontSize: inputFontSize),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      cursorHeight: isTablet ? 22 : 18,
                      cursorColor: mythemecolor,
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: GoogleFonts.poppins(fontSize: inputFontSize),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: mythemecolor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: mythemecolor,
                          ),
                          onPressed: () {
                            setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            );
                          },
                        ),
                        hintText: "Password",
                        hintStyle: GoogleFonts.poppins(fontSize: inputFontSize),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: () {},
                    //     child: Text(
                    //       "Forgot Password?",
                    //       style: GoogleFonts.poppins(
                    //         color: mythemecolor,
                    //         fontWeight: FontWeight.w500,
                    //         fontSize: inputFontSize + 1,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 10),

                    // Login Button
                    Center(
                      child: SizedBox(
                        width: isTablet ? 200 : 150,
                        height: isTablet ? 55 : 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mythemecolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: mythemecolor.withOpacity(0.4),
                          ),
                          onPressed: isLoading ? null : handleLogin,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Login",
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 22 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Register Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not Yet created Account?  ",
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 18 : 12,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DealerGstVerificationPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Register Here!",
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 18 : 12,
                              color: mythemecolor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




  // Future<void> handleLogin() async {
  //   if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please enter email and password')),
  //     );
  //     return;
  //   }

  //   setState(() => isLoading = true);

  //   final result = await ApiAuthService.loginUser(
  //     _emailController.text.trim(),
  //     _passwordController.text.trim(),
  //   );

  //   setState(() => isLoading = false);

  //   if (result['success']) {
  //     final role = result['role'];
  //     Widget targetScreen;

  //     switch (role) {
  //       case 'superadmin':
  //         targetScreen = const SuperAdminHome();
  //         break;
  //       case 'admin':
  //         targetScreen = const AdminHomes();
  //         break;
  //       case 'manager':
  //         targetScreen = const ManagerHome();
  //         break;
  //       case 'marketer':
  //         targetScreen = const MarketerHome();
  //         break;
  //       case 'dealer':
  //         targetScreen = const BottomNavBar();
  //         break;
  //       default:
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text('Unknown role: $role')));
  //         return;
  //     }

  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => targetScreen),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(result['message'] ?? 'Login failed')),
  //     );
  //   }
  // }