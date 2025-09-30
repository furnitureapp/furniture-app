import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_home_page.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class SplashScreens extends StatefulWidget {
  const SplashScreens({super.key});

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white, // ✅ White background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             
             
            Lottie.asset(
              'assets/json/liv.json',
              width: isTablet ? 300 : 300,
              height: isTablet ? 300 : 600,
              fit: BoxFit.contain,
            ),
//  Icon(
//   Icons.home,
//   size: 100,
//   color: Colors.blue,
// ),

          
          ],
        ),
      ),
    );
  }
}
