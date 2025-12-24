import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientationGate extends StatelessWidget {
  final Widget child;

  const OrientationGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        } else {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        }

        return child;
      },
    );
  }
}
