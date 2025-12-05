import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/admin/admin_home.dart';
import 'package:furniture_ecom_app/core/api/api_service_auth.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_login_screen.dart';
import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';
import 'package:video_player/video_player.dart';
import 'package:furniture_ecom_app/core/services/notif_maitence.dart';
import 'package:furniture_ecom_app/my_ecom/maintenence.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreenMY extends StatefulWidget {
  const SplashScreenMY({super.key});

  @override
  State<SplashScreenMY> createState() => _SplashScreenMYState();
}

class _SplashScreenMYState extends State<SplashScreenMY> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController =
        VideoPlayerController.asset('assets/videos/splash_video.mp4')
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

  // void _navigateBasedOnStatus() async {
  //   final result = await NotifMaintenanceService.fetchMaintenanceStatus();

  //   if (!mounted) return;

  //   if (result['maintenance'] == true) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => MaintenanceScreen(
  //           message: result['message'] ?? 'Under maintenance',
  //         ),
  //       ),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const MyLoginScreen()),
  //     );
  //   }
  // }

  void _navigateBasedOnStatus() async {
  final result = await NotifMaintenanceService.fetchMaintenanceStatus();

  if (!mounted) return;

  // 1️⃣ Maintenance check
  if (result['maintenance'] == true) {
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MaintenanceScreen(
          message: result['message'] ?? 'Under maintenance',
        ),
      ),
    );
  }

  // 2️⃣ Check JWT token
  final token = await ApiAuthService.getStoredToken();

  if (token == null || token.isEmpty) {
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyLoginScreen()),
    );
  }

  // 3️⃣ Token exists — get role
  final role = await ApiAuthService.getStoredRole();

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
      targetScreen = const MyLoginScreen();
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => targetScreen),
  );
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


// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/my_login_screen.dart';
// import 'package:lottie/lottie.dart';
// import 'dart:async';

// class SplashScreenMYs extends StatefulWidget {
//   const SplashScreenMYs({super.key});

//   @override
//   State<SplashScreenMYs> createState() => _SplashScreenMYsState();
// }

// class _SplashScreenMYsState extends State<SplashScreenMYs> {
//   @override
//   void initState() {
//     super.initState();

//     Timer(const Duration(seconds: 5), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const MyLoginScreen()),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth > 600;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset(
//               'assets/json/liv.json',
//               width: isTablet ? 300 : 300,
//               height: isTablet ? 300 : 600,
//               fit: BoxFit.contain,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

