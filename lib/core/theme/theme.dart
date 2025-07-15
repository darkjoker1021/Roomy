import 'package:roomy/core/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Light Theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: GoogleFonts.poppins().fontFamily,

  scaffoldBackgroundColor: Palette.scaffoldBackgroundColor,
  iconTheme: const IconThemeData(color: Palette.buttonColor),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Palette.primaryColor),
    )
  ),
  
  colorScheme: const ColorScheme.light(
    primary: Palette.primaryColor,
    secondary: Palette.containerColor,
  ),
);

// Dark Theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  splashColor: Colors.transparent,
  fontFamily: GoogleFonts.poppins().fontFamily,

  scaffoldBackgroundColor: const Color(0xFF343434),
  iconTheme: const IconThemeData(color: Palette.buttonColor),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Palette.primaryColor),
    )
  ),

  colorScheme: const ColorScheme.dark(
    primary: Palette.primaryColor,
    secondary: Color(0xFF464646),
    tertiary: Colors.white,
  ),
);