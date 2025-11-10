// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/core/services/notif_maitence.dart';
// import 'package:furniture_ecom_app/my_ecom/maintenence.dart';
// import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';

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
//       duration: const Duration(milliseconds: 1800),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

//     _controller.forward();
//     _navigateBasedOnStatus();
//   }

//   void _navigateBasedOnStatus() async {
//     await Future.delayed(const Duration(seconds: 4));

//     final result = await NotifMaintenanceService.fetchMaintenanceStatus();

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
//         MaterialPageRoute(builder: (context) => const BottomNavBar()),
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
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset('assets/images/theme.png', fit: BoxFit.cover),
//           ),

//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.5),
//                     Colors.black.withOpacity(0.5),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Center(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: ScaleTransition(
//                 scale: _scaleAnimation,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Container(
//                         color: Colors
//                             .transparent,
//                         child: Lottie.asset(
//                           'assets/json/sofa.json',
//                           width: isTablet ? 400 : 450,
//                           height: isTablet ? 400 : 350,
//                           fit: BoxFit.contain,
//                         ),
//                       ),

//                     ),

//                     const SizedBox(height: 30),

//                     Text(
//                       'K A I ',
//                       style: GoogleFonts.poppins(
//                         fontSize: isTablet ? 42 : 32,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         letterSpacing: 1.2,
//                         shadows: [
//                           Shadow(
//                             color: Colors.black.withOpacity(0.5),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     FadeTransition(
//                       opacity: Tween<double>(begin: 0, end: 1).animate(
//                         CurvedAnimation(
//                           parent: _controller,
//                           curve: const Interval(0.5, 1.0),
//                         ),
//                       ),
                    //   child: Text(
                    //     'ELITE FURNITURES FOR YOU!',
                    //     style: GoogleFonts.montserrat(
                    //       fontSize: isTablet ? 20 : 16,
                    //       fontWeight: FontWeight.w500,
                    //       color: Colors.white.withOpacity(0.4),
                    //       fontStyle: FontStyle.italic,
                    //     ),
                    //   ),
                    // ),

                    // const SizedBox(height: 40),

                    // SizedBox(
                    //   width: isTablet ? 200 : 130,
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.circular(10),
                    //     child: LinearProgressIndicator(
                    //       backgroundColor: Colors.white.withOpacity(0.3),
                    //       valueColor: AlwaysStoppedAnimation<Color>(
                    //         Colors.white.withOpacity(0.8),
                    //       ),
                    //       minHeight: 6,
                    //     ),
                    //   ),
                    // ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:furniture_ecom_app/core/services/notif_maitence.dart';
import 'package:furniture_ecom_app/my_ecom/maintenence.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('assets/videos/splash_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      })
      ..setLooping(false)
      ..setVolume(1.0); 

    _videoController.addListener(() async {
      if (_videoController.value.position >= _videoController.value.duration) {
        _navigateBasedOnStatus();
      }
    });
  }

  void _navigateBasedOnStatus() async {
    final result = await NotifMaintenanceService.fetchMaintenanceStatus();

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
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF461066),
      body: Center(
        child: _videoController.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: isTablet ? 400 : 550,
                    height: isTablet ? 300 : 450,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: VideoPlayer(_videoController),
                    ),
                  ),

                  const SizedBox(height: 0),

                  Text(
                    'ELITE FURNITURES FOR YOU!',
                    style: GoogleFonts.montserrat(
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: isTablet ? 200 : 130,
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
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
