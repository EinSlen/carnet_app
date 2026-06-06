import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette du design system (voir Design-app-animaux.pdf).
class AppColors {
  static const teal = Color(0xFF15807C);
  static const tealDark = Color(0xFF0B5E59);
  static const tealSoft = Color(0xFFDDF1EF);
  static const teal50 = Color(0xFFF0F8F7);
  static const coral = Color(0xFFF47A57);
  static const coralSoft = Color(0xFFFFE7DD);
  static const green = Color(0xFF33A867);
  static const amber = Color(0xFFE5A33B);
  static const red = Color(0xFFE45B52);
  static const ink = Color(0xFF1B2A29);
  static const muted = Color(0xFF71807F);
  static const line = Color(0xFFE6EDEC);
  static const bg = Color(0xFFF6F9F8);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.coral,
      surface: Colors.white,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.nunito(
            fontWeight: FontWeight.w800, color: AppColors.ink),
        titleMedium: GoogleFonts.nunito(
            fontWeight: FontWeight.w700, color: AppColors.ink),
        headlineSmall: GoogleFonts.nunito(
            fontWeight: FontWeight.w800, color: AppColors.tealDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
      ),
    );
  }
}
