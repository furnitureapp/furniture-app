import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/core/api/api_service_auth.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/admin/admin_home.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:furniture_ecom_app/my_ecom/splash_screen.dart';
import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';
// import 'package:furniture_ecom_app/my_register_screen.dart';

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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiAuthService.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result['success']) {
      final role = result['role'];

      // ✅ Navigate based on role
      Widget targetScreen;
      switch (role) {
        case 'superadmin':
          targetScreen = const SuperAdminHome();
          break;
        case 'admin':
          targetScreen = const AdminHome();
          break;
        case 'manager':
          targetScreen = const ManagerHome();
          break;
        case 'marketer':
          targetScreen = const MarketerHome();
          break;
        case 'dealer':
          targetScreen = const SplashScreen();
          break;
        default:
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Unknown role: $role')));
          return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login failed')),
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
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 221, 197, 251),
                Colors.white,
                Color.fromARGB(255, 221, 197, 251),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // color: mythemecolor,
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
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: mythemecolor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/woodpecker_logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  // const Icon(Icons.chair, color: mythemecolor, size: 70),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.20,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: mythemecolor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    TextField(
                      cursorHeight: 20,
                      cursorColor: mythemecolor,
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: mythemecolor,
                        ),
                        hintText: "Email Address",
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextField(
                      cursorHeight: 20,
                      cursorColor: mythemecolor,
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible, // 👈 use state variable
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
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible; // 👈 toggle
                            });
                          },
                        ),
                        hintText: "Password",
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: mythemecolor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Login Button
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 50,
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
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
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
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Register Here!",
                            style: TextStyle(
                              fontSize: 16,
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





// role based login
// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/Manager/manager_home.dart';
// import 'package:furniture_ecom_app/admin/admin_home.dart';
// import 'package:furniture_ecom_app/core/api/api_service_auth.dart';
// import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
// import 'package:furniture_ecom_app/my_ecom/splash_screen.dart';
// import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';


// class MyLoginScreen extends StatefulWidget {
//   const MyLoginScreen({super.key});

//   @override
//   State<MyLoginScreen> createState() => _MyLoginScreenState();
// }

// class _MyLoginScreenState extends State<MyLoginScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool isLoading = false;

//   void handleLogin() async {
//     setState(() => isLoading = true);

//     final result = await ApiAuthService.loginUser(
//       emailController.text.trim(),
//       passwordController.text.trim(),
//     );

//     setState(() => isLoading = false);

//     if (result['success']) {
//       final role = result['role'];

//       // ✅ Navigate based on role
//       if (role == 'superadmin') {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => SuperAdminHome()));
//       } else if (role == 'admin') {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => AdminHome()));
//       } else if (role == 'manager') {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => ManagerHome()));
//       } else if (role == 'marketer') {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => MarketerHome()));
//       } else if (role == 'dealer') {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => SplashScreen()));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Unknown role: $role')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(result['message'] ?? 'Login failed')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isLoading ? null : handleLogin,
//               child: isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/constants/colors.dart';
// import 'package:furniture_ecom_app/my_register_screen.dart';
// import 'package:google_fonts/google_fonts.dart';

// class MyMyLoginScreen extends StatefulWidget {
//   const MyMyLoginScreen({super.key});

//   @override
//   State<MyMyLoginScreen> createState() => _MyMyLoginScreenState();
// }

// class _MyMyLoginScreenState extends State<MyMyLoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     const mythemecolor = Color.fromARGB(255, 38, 81, 99);
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: marketermythemecolor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             title: Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Text(
//                 'Login here!',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
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
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topCenter,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 20),
//                 child: Container(
//                   padding: const EdgeInsets.all(17),
//                   decoration: BoxDecoration(
//                     color: mythemecolor.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.chair, color: mythemecolor, size: 70),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: screenHeight * 0.20, 
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Welcome Back!",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: mythemecolor,
//                       ),
//                     ),
                  
//                     const SizedBox(height: 20),

//                     // Email
//                     TextField(
//                       cursorHeight: 20,
//                       cursorColor:mythemecolor ,
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(
//                           Icons.email_outlined,
//                           color: mythemecolor,
//                         ),
//                         hintText: "Email Address",
//                         hintStyle: const TextStyle(fontSize: 12),
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     TextField(
//                       cursorHeight: 20,
//                       cursorColor:mythemecolor ,
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         prefixIcon: const Icon(
//                           Icons.lock_outline,
//                           color: mythemecolor,
//                         ),
//                         hintStyle: const TextStyle(fontSize: 12),

//                         hintText: "Password",
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 12,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),

//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {},
//                         child: const Text(
//                           "Forgot Password?",
//                           style: TextStyle(
//                             color: mythemecolor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),

//                     // Login button
//                     Center(
//                       child: SizedBox(
//                         width: 120,
//                         height: 50,
                      
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: mythemecolor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             elevation: 6,
//                             shadowColor: mythemecolor.withOpacity(0.4),
//                           ),
//                           onPressed: () {
//                           },
//                           child: const Text(
//                             "Login",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           "Don't have an account? ",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     const RegistrationScreen(),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Register Here!",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: mythemecolor,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 40), // Extra spacing at bottom
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
