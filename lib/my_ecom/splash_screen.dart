

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:furniture_ecom_app/core/services_ecom/notif_maitence.dart';
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
