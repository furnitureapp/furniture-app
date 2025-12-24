import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/admin/admin_home.dart';
import 'package:furniture_ecom_app/core/api_management_service/api_service_auth.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/userprofile/wait_gst_approval.dart';
import 'package:furniture_ecom_app/base/my_login_screen.dart';
import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';
import 'package:video_player/video_player.dart';
import 'package:furniture_ecom_app/core/services_ecom/notif_maitence.dart';
import 'package:furniture_ecom_app/my_ecom/maintenence.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


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



Future<void> _navigateBasedOnStatus() async {
  if (!mounted) return;

  // 0️⃣ Maintenance check (highest priority)
  final maintenanceResult =
      await NotifMaintenanceService.fetchMaintenanceStatus();

  if (!mounted) return;

  if (maintenanceResult['maintenance'] == true) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MaintenanceScreen(
          message:
              maintenanceResult['message'] ?? 'App under maintenance',
        ),
      ),
    );
    return;
  }

  // 1️⃣ Token check
  final token = await ApiAuthService.getStoredToken();

  if (token == null || token.isEmpty) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyLoginScreen()),
    );
    return;
  }

  // 2️⃣ Role check
  final role = await ApiAuthService.getStoredRole();

  // 3️⃣ Dealer-only GST pending check
  if (role == 'dealer') {
    final prefs = await SharedPreferences.getInstance();
    final bool isDealerPending =
        prefs.getBool("dealer_pending_approval") == true;

    if (isDealerPending) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WaitForGSTApprovalPage(),
        ),
      );
      return;
    }
  }

  // 4️⃣ Role-based navigation
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
            : const CircularProgressIndicator(color:  Color(0xFF461066)),
      ),
    );
  }
}



