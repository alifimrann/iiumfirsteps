import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF009639); // IIUM Green
  static const Color secondaryGreen = Color(0xFFE8F5E9);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textDark),
        bodyMedium: GoogleFonts.inter(color: textLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryGreen),
        titleTextStyle: GoogleFonts.inter(color: textDark, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        backgroundColor: white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
