import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    
      final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;
    return Center(
  
      child:  Lottie.asset(
              'assets/json/meow.json',
              width: isTablet ? 500 : 300,
              height: isTablet ? 500 : 300,
              fit: BoxFit.contain,
            ),
    );
  }
}