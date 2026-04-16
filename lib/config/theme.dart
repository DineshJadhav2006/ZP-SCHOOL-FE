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
      textTheme: GoogleFonts.baloo2TextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Color(AppConfig.primaryColor),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: GoogleFonts.baloo2(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.baloo2(fontWeight: FontWeight.w600, fontSize: 12),
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
          elevation: 4,
          shadowColor: Color(AppConfig.primaryColor).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.baloo2(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.baloo2(color: Colors.grey.shade400, fontSize: 15),
        labelStyle: GoogleFonts.baloo2(color: Colors.grey.shade700, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(AppConfig.primaryColor), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
