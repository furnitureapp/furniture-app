import 'package:flutter/material.dart';
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  const ResponsiveBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isTablet = width >= 600;
    final bool isLandscape = width > MediaQuery.of(context).size.height;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet
              ? (isLandscape ? 1200 : 840) // 🔥 KEY FIX
              : double.infinity,
        ),
        child: child,
      ),
    );
  }
}

