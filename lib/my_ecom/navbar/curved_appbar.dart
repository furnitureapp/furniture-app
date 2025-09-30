import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onTrailingPressed;
  final List<Color> gradientColors;
  final Color textColor;
  final Color iconColor;

  @override
  final Size preferredSize;

  const CurvedAppBar({
    super.key,
    required this.title,
    this.leadingIcon = Icons.arrow_back,
    this.trailingIcon,
    this.onLeadingPressed,
    this.onTrailingPressed,
    this.textColor = Colors.white,
    this.iconColor = Colors.black, // matched icon color to AppBar
    this.gradientColors = const [
      Color.fromARGB(255, 26, 99, 91),
      Colors.green,
      Color.fromARGB(255, 26, 99, 91),
    ],
  }) : preferredSize = const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomAppBarClipper(),
      child: Container(
        height: preferredSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(
                leadingIcon,
                size: 24,
                color: iconColor,
              ),
              onPressed: onLeadingPressed ??
                  () {
                    Navigator.pushReplacementNamed(context, '/myhome');
                  }),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: textColor, // white
              fontWeight: FontWeight.w500, // matched original
              fontSize: 18, // matched original
              letterSpacing: 1.1,
            ),
          ),
          centerTitle: true,
          actions: [
            if (trailingIcon != null)
              IconButton(
                icon: Icon(trailingIcon, size: 28, color: iconColor),
                onPressed: onTrailingPressed,
              ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 70,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final IconData leadingIcon;
//   final IconData? trailingIcon;
//   final VoidCallback? onLeadingPressed;
//   final VoidCallback? onTrailingPressed;
//   final List<Color> gradientColors;
//   final Color textColor;
//   final Color iconColor;

//   @override
//   final Size preferredSize;

//   const CurvedAppBar({
//     super.key,
//     required this.title,
//     this.leadingIcon = Icons.arrow_back,
//     this.trailingIcon,
//     this.onLeadingPressed,
//     this.onTrailingPressed,
//     this.textColor = Colors.white,
//     this.iconColor = Colors.black,
//     this.gradientColors = const [
//       Color.fromARGB(255, 26, 99, 91),
//       Colors.green,
//       Color.fromARGB(255, 26, 99, 91),
//     ],
//   }) : preferredSize = const Size.fromHeight(120);

//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: CustomAppBarClipper(),
//       child: Container(
//         height: preferredSize.height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradientColors,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//               icon: Icon(
//                 leadingIcon,
//                 size: 30,
//                 color: iconColor,
//               ),
//               onPressed: onLeadingPressed ??
//                   () {
//                     Navigator.pushReplacementNamed(context, '/myhome');
//                   }),
//           title: Text(
//             title,
//             style: GoogleFonts.poppins(
//               color: textColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 18,
//               letterSpacing: 1.2,
//             ),
//           ),
//           centerTitle: true,
//           actions: [
//             if (trailingIcon != null)
//               IconButton(
//                 icon: Icon(trailingIcon, size: 28),
//                 onPressed: onTrailingPressed,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CustomAppBarClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height - 50);
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height + 70,
//       size.width,
//       size.height - 60,
//     );
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
