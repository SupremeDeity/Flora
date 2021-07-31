import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors
const Gunmetal = Color.fromRGBO(35, 41, 47, 1.0);
const Cornflower_Blue = Color.fromRGBO(118, 146, 255, 1.0);
const Charcoal = Color.fromRGBO(52, 61, 70, 1.0);
const Onyx = Color.fromRGBO(47, 50, 54, 1.0);
const MiddleGreenBlue = Color.fromRGBO(138, 208, 199, 1.0);
const Celeste = Color.fromRGBO(201, 251, 255, 1.0);

class DefaultThemes {
  // Default Dark theme
  var defaultDark = ThemeData(
      primaryColor: Cornflower_Blue,
      textTheme: TextTheme(
        bodyText2: GoogleFonts.openSans(
            fontWeight: FontWeight.w100), // ListTile subtitles
        bodyText1:
            GoogleFonts.montserrat(fontWeight: FontWeight.w400), // ListTiles
        subtitle2: TextStyle(color: Onyx),
        headline6: GoogleFonts.openSans(color: Celeste),
        subtitle1: GoogleFonts.notoSans(),
      ),
      scaffoldBackgroundColor: Gunmetal,
      accentColor: MiddleGreenBlue,
      backgroundColor: Charcoal,
      dividerColor: Celeste,
      brightness: Brightness.dark,
      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(backgroundColor: Charcoal));
}
