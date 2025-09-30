import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationPage2 extends StatelessWidget {
  const AnimationPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 50 : 20),
            child: Lottie.asset(
              'assets/json/cartscreen.json',
              width: isTablet ? 400 : screenWidth * 0.6,
              height: isTablet ? 400 : null,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
