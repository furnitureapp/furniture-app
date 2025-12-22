import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/administration_app/manager_app/manager_home.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/preveiw_app/preview_state.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPreviewM extends StatelessWidget {
  const AppPreviewM({super.key});

 
void _open(BuildContext context, int type) {
  AppPreviewState.isPreview = true;
  AppPreviewState.typeOfProduct = type;

  Navigator.pushNamed(context, '/myhome');
}

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 221, 197, 251),
                Colors.white,
                Color.fromARGB(255, 221, 197, 251),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: mythemecolor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: mythemecolor),
            title: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                'APP PREVIEW',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 22 : 12,
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Preview Dealer App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => _open(context, 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mythemecolor1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Type 1 Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () => _open(context, 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mythemecolor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Type 2 Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
