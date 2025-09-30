import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:furniture_ecom_app/my_ecom/maintenence.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
    _navigateBasedOnStatus();
  }

  void _navigateBasedOnStatus() async {
    await Future.delayed(const Duration(seconds: 4));

    final result = await ApiService.fetchMaintenanceStatus();

    if (!mounted) return;

    if (result['maintenance'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MaintenanceScreen(
            message: result['message'] ?? 'Under maintenance',
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BottomNavBar(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/mine.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with shadow
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Lottie.asset(
                        'assets/json/cart.json',
                        width: isTablet ? 400 : 250,
                        height: isTablet ? 400 : 250,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // App Name
                    Text(
                      'Fresh Grocery',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 42 : 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: const Interval(0.5, 1.0),
                        ),
                      ),
                      child: Text(
                        'Farm Fresh to Your Doorstep',
                        style: GoogleFonts.dancingScript(
                          fontSize: isTablet ? 20 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: isTablet ? 200 : 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/maintenence.dart';
// import 'package:model_app/navbar/bottom_navbar.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.elasticOut,
//       ),
//     );

//     _controller.forward();
//     _navigateBasedOnStatus();
//   }

//   void _navigateBasedOnStatus() async {
//     await Future.delayed(const Duration(seconds: 3));

//     final result = await ApiService.fetchMaintenanceStatus();

//     if (!mounted) return;

//     if (result['maintenance'] == true) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MaintenanceScreen(
//             message: result['message'] ?? 'Under maintenance',
//           ),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const BottomNavBar(),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: RadialGradient(
//             colors: [
//               const Color(0xFF8BC34A).withOpacity(0.9),
//               const Color(0xFF4CAF50).withOpacity(0.9),
//               const Color(0xFF2E7D32),
//             ],
//             center: Alignment.topLeft,
//             radius: 1.5,
//             stops: const [0.1, 0.6, 1.0],
//           ),
//         ),
//         child: Center(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Logo with shadow and better animation
//                   Container(
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 20,
//                           spreadRadius: 5,
//                           offset: const Offset(0, 10),
//                         )
//                       ],
//                     ),
//                     child: Lottie.asset(
//                       'assets/json/cart.json',
//                       width: isTablet ? 400 : 250,
//                       height: isTablet ? 400 : 250,
//                       fit: BoxFit.contain,
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // App Name with better typography
//                   Text(
//                     'Fresh Grocery',
//                     style: GoogleFonts.poppins(
//                       fontSize: isTablet ? 42 : 32,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                       letterSpacing: 1.2,
//                       shadows: [
//                         Shadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 5,
//                           offset: const Offset(0, 2),
//                         )
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // Tagline with subtle animation
//                   FadeTransition(
//                     opacity: Tween<double>(begin: 0, end: 1).animate(
//                       CurvedAnimation(
//                         parent: _controller,
//                         curve: const Interval(0.5, 1.0),
//                       ),
//                     ),
//                     child: Text(
//                       'Farm Fresh to Your Doorstep',
//                       style: GoogleFonts.poppins(
//                         fontSize: isTablet ? 20 : 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white.withOpacity(0.9),
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // Modern loading indicator
//                   SizedBox(
//                     width: isTablet ? 200 : 120,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: LinearProgressIndicator(
//                         backgroundColor: Colors.white.withOpacity(0.3),
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           Colors.white.withOpacity(0.8),
//                         ),
//                         minHeight: 6,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/maintenence.dart';
// import 'package:model_app/navbar/bottom_navbar.dart';
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateBasedOnStatus();
//   }

//   void _navigateBasedOnStatus() async {
//     await Future.delayed(const Duration(seconds: 3)); 

//     final result = await ApiService.fetchMaintenanceStatus();

//     if (!mounted) return;

//     if (result['maintenance'] == true) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MaintenanceScreen(
//             message: result['message'] ?? 'Under maintenance',
//           ),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const BottomNavBar(),
//         ),
//       );
//     }
//   }

//   @override


// @override
// Widget build(BuildContext context) {
//   final screenWidth = MediaQuery.of(context).size.width;
//   final isTablet = screenWidth > 600;

//   return Scaffold(
//     body: Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color.fromARGB(255, 182, 225, 9),
//             Color.fromARGB(255, 250, 251, 250),
//             Color.fromARGB(255, 251, 252, 251),
//             Color.fromARGB(255, 220, 241, 132),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Welcome to Fresh Grocery!',
//               style: GoogleFonts.andika(
//                 fontSize: isTablet ? 36 : 24,
//                 fontWeight: FontWeight.bold,
//                 color: const Color.fromARGB(255, 5, 54, 5),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Lottie.asset(
//               'assets/json/cart.json',
//               width: isTablet ? 500 : 300,
//               height: isTablet ? 500 : 300,
//               fit: BoxFit.contain,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Get fresh groceries delivered fast!',
//               style: GoogleFonts.andika(
//                 fontSize: isTablet ? 24 : 17,
//                 fontWeight: FontWeight.bold,
//                 color: const Color.fromARGB(255, 5, 54, 5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// }




//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//                Color.fromARGB(255, 182, 225, 9),
//               Color.fromARGB(255, 250, 251, 250),
//               Color.fromARGB(255, 251, 252, 251),
//               Color.fromARGB(255, 220, 241, 132),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Welcome to Fresh Grocery!',
//                 style: GoogleFonts.andika(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(255, 5, 54, 5),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Lottie.asset(
//                 'assets/json/cart.json',
//                 width: 300,
//                 height: 300,
//                 fit: BoxFit.contain,
//               ),
//               const SizedBox(height: 20),
           
//                 Text(
//                 'Get fresh groceries delivered fast!',
//                 style: GoogleFonts.andika(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(255, 5, 54, 5),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:model_app/navbar/bottom_navbar.dart';

//   class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container( 
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [const Color.fromARGB(255, 4, 83, 8), const Color.fromARGB(255, 6, 127, 10), const Color.fromARGB(255, 182, 225, 9)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: AnimatedSplashScreen(
//           splash: SizedBox(
//             width: double.infinity,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [

//                 Text(
//                   'Welcome to Fresh Grocery!!',
//                   style: GoogleFonts.alegreyaSansSc(
//                     fontStyle: FontStyle.italic,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: const Color.fromARGB(255, 245, 248, 245),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Lottie.asset(
//                   'assets/json/cart.json',
//                   width: 300,
//                   height: 300,
//                   fit: BoxFit.contain,
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   "Get fresh groceries delivered fast!",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           backgroundColor: Colors.transparent,
//           splashIconSize: 900,
//           nextScreen: BottomNavBar(),
//           splashTransition: SplashTransition.fadeTransition,
//         ),
//       ),
//     );
//   }
// }




























