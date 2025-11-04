import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kPrimaryColor = Color.fromARGB(255, 93, 64, 37);
const Color adminPrimaryColor = Color.fromARGB(255, 81, 98, 71);
const Color marketerprimaryColor = Color.fromARGB(255, 38, 81, 99);
const Color managerPrimaryColor = Color.fromARGB(255, 83, 64, 87);  

class AppTextStyles {
  static final heading = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final body = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static final kpiValue = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 93, 64, 37),
  );
}
