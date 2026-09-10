import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChurchColors {
  static const primary = Color(0xFF1A365D);
  static const secondary = Color(0xFF8BAFD6);
  static const tertiary = Color(0xFFA5C1E1);
  static const alternate = Color(0xFFEDF2F7);
  static const primaryText = Color(0xFF1A365D);
  static const secondaryText = Color(0xFF4A5568);
  static const background = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xCCFFFFFF);
  static const success = Color(0xFF38A169);
  static const error = Color(0xFFE53E3E);
}

ThemeData buildChurchTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ChurchColors.primary,
      primary: ChurchColors.primary,
      secondary: ChurchColors.secondary,
      surface: ChurchColors.background,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: ChurchColors.background,
    textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: ChurchColors.primaryText,
      displayColor: ChurchColors.primaryText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: ChurchColors.primary,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: ChurchColors.background,
      selectedItemColor: ChurchColors.primary,
      unselectedItemColor: ChurchColors.secondaryText,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
