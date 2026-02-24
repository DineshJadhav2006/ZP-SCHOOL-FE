import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_config.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      primaryColor: Color(AppConfig.primaryColor),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(AppConfig.primaryColor),
        brightness: Brightness.light,
        primary: Color(AppConfig.primaryColor),
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Color(AppConfig.primaryColor),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        backgroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppConfig.primaryColor),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(AppConfig.primaryColor), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
