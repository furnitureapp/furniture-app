// import 'package:flutter/material.dart';
// import 'package:model_app/constants/colors.dart';

// void showTopSnackBar(BuildContext context, String message, {Color backgroundColor = tdgreen}) {
//   final overlay = Overlay.of(context);
//   final snackBar = OverlayEntry(
//     builder: (context) => Positioned(
//       top: 70.0, 
//       left: 20.0,
//       right: 20.0, 
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
//           decoration: BoxDecoration(
//             color: backgroundColor,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 offset: const Offset(0, 2),
//                 blurRadius: 6,
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                   overflow: TextOverflow.ellipsis, 
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );

//   overlay.insert(snackBar);

//   Future.delayed(const Duration(seconds: 2), () {
//     snackBar.remove();
//   });
// }


import 'package:flutter/material.dart';

void showTopSnackBar(BuildContext context, String message, {Color backgroundColor = const Color.fromARGB(255, 120, 119, 119)}) {
  final overlay = Overlay.of(context);
  final double screenWidth = MediaQuery.of(context).size.width;

  double snackBarWidth = screenWidth > 600 ? screenWidth * 0.5 : screenWidth * 0.9; 

  final snackBar = OverlayEntry(
    builder: (context) => Positioned(
      top: 90.0,
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
