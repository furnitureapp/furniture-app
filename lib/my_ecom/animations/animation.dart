import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationPage1 extends StatelessWidget {
  const AnimationPage1({super.key});

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
              'assets/json/sofa.json',
              width: isTablet ? 400 : screenWidth * 0.9, // Max 400px for tablets
              height: isTablet ? 400 : null, // Adjust height proportionally
              fit: BoxFit.contain, // Keeps proportions correct
            ),
          ),
        ),
      ),
    );
  }
}
