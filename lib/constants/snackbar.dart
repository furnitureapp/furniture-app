
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/constants/colors.dart';

void showTopSnackBar(BuildContext context, String message, {Color backgroundColor = mythemecolor}) {
  final overlay = Overlay.of(context);
  final double screenWidth = MediaQuery.of(context).size.width;

  double snackBarWidth = screenWidth > 600 ? screenWidth * 0.5 : screenWidth * 0.9; 

  final snackBar = OverlayEntry(
    builder: (context) => Positioned(
      top: 110.0,
      left: (screenWidth - snackBarWidth) / 2,
      width: snackBarWidth,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 600 ? 30.0 : 20.0, 
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth > 600 ? 18 : 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, 
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(snackBar);

  Future.delayed(const Duration(seconds: 2), () {
    snackBar.remove();
  });
}


