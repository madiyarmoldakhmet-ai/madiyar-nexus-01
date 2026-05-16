import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// Nexus Material 3 Theme
/// Dark-first design with gold accents and premium typography.
class MadiTheme {
  MadiTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: MadiColors.bloodRed,
        onPrimary: Colors.white,
        secondary: MadiColors.bloodRed,
        onSecondary: Colors.white,
        surface: MadiColors.surfaceDark,
        onSurface: MadiColors.textPrimary,
        error: MadiColors.rose,
      ),
      textTheme: GoogleFonts.coveredByYourGraceTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.oswald(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: MadiColors.bloodRed,
          letterSpacing: 1,
          shadows: [
            const Shadow(color: MadiColors.bloodRed, blurRadius: 10),
          ],
        ),
        headlineMedium: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: MadiColors.bloodRed,
          letterSpacing: 0.5,
        ),
        headlineSmall: GoogleFonts.oswald(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: MadiColors.textPrimary,
        ),
        titleLarge: GoogleFonts.oswald(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: MadiColors.textPrimary,
        ),
        titleMedium: GoogleFonts.oswald(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: MadiColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.coveredByYourGrace(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: MadiColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.coveredByYourGrace(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: MadiColors.textSecondary,
        ),
        labelLarge: GoogleFonts.oswald(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MadiColors.textPrimary,
        ),
        labelMedium: GoogleFonts.oswald(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MadiColors.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: MadiColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: MadiColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: MadiColors.ghoulDark,
        elevation: 10,
        shadowColor: MadiColors.bloodRed.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: MadiColors.bloodRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MadiColors.bloodRed,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: MadiColors.bloodRed,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white24, width: 1),
          ),
          textStyle: GoogleFonts.oswald(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MadiColors.bloodRed,
          side: const BorderSide(color: MadiColors.bloodRed, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MadiRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: MadiColors.bloodRed,
        unselectedItemColor: MadiColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: MadiColors.divider,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: MadiColors.bloodRed, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: MadiColors.bloodRed, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: MadiColors.bloodRed, width: 2),
        ),
        labelStyle: GoogleFonts.oswald(color: MadiColors.textMuted),
        hintStyle: GoogleFonts.coveredByYourGrace(color: MadiColors.textMuted, fontSize: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MadiColors.ghoulDark,
        contentTextStyle: GoogleFonts.coveredByYourGrace(
          color: MadiColors.textPrimary,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: MadiColors.bloodRed),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
