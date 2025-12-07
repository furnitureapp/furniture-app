import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/my_ecom/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPreviewM extends StatelessWidget {
  const AppPreviewM({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 221, 197, 251),
                Colors.white,
                Color.fromARGB(255, 221, 197, 251),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: mythemecolor),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'DEALERS APP PREVIEW',
                style: GoogleFonts.poppins(
                  fontSize: isTablet(context)? 22: 12,
                  fontWeight: FontWeight.w600,
                  color: mythemecolor,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      drawer: const ManagerDrawer(currentPage: "App Preview"),
      body: Center(
        child: ElevatedButton(
          onPressed:(){
            //  Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => const SplashScreen(),
            //             ),
            //           );
          } ,
          style: ElevatedButton.styleFrom(
            backgroundColor: mythemecolor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child:  Text(
            "Open App Preview",
            style: TextStyle(fontSize:  isTablet(context) ? 22 : 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}