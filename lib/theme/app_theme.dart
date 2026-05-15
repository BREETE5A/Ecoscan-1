import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const primary = Color(0xFF27AE60);
  static const primaryLight = Color(0xFF2ECC71);
  static const primaryDark = Color(0xFF1E8449);
  static const teal = Color(0xFF1ABC9C);
  static const mint = Color(0xFFA8E6CF);

  // Accent
  static const accent = Color(0xFFF39C12);
  static const accentLight = Color(0xFFF9CA24);
  static const purple = Color(0xFF9B59B6);

  // Semantic
  static const danger = Color(0xFFE74C3C);
  static const warning = Color(0xFFF39C12);
  static const info = Color(0xFF3498DB);
  static const success = Color(0xFF27AE60);

  // Light theme surfaces
  static const background = Color(0xFFF0FDF4);
  static const surface = Color(0xFFFFFFFF);
  static const cardBg = Color(0xFFFFFFFF);
  static const inputBg = Color(0xFFF1F8F4);
  static const textPrimary = Color(0xFF1A2E1A);
  static const textSecondary = Color(0xFF546E7A);
  static const textLight = Color(0xFF90A4AE);
  static const divider = Color(0xFFE8F5E9);

  // Dark theme surfaces
  static const darkBackground = Color(0xFF0D1F12);
  static const darkSurface = Color(0xFF1A3320);
  static const darkCard = Color(0xFF1F3D26);
  static const darkInput = Color(0xFF243B2A);
  static const darkText = Color(0xFFE8F5E9);
  static const darkTextSecondary = Color(0xFF81C784);

  // Category colors
  static const plastic = Color(0xFF3498DB);
  static const paper = Color(0xFF9B59B6);
  static const organic = Color(0xFF795548);
  static const glass = Color(0xFF00BCD4);
  static const metal = Color(0xFF607D8B);
  static const electronics = Color(0xFFFF5722);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF1ABC9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF1E8449), Color(0xFF117A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D4D1F), Color(0xFF1A7A3C), Color(0xFF27AE60)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF9CA24), Color(0xFFF39C12)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 600);
  static const verySlow = Duration(milliseconds: 900);
}

class AppTheme {
  static ThemeData get theme => lightTheme;

  static ThemeData get lightTheme => _build(false);
  static ThemeData get darkTheme => _build(true);

  static ThemeData _build(bool dark) {
    final bg = dark ? AppColors.darkBackground : AppColors.background;
    final surf = dark ? AppColors.darkSurface : AppColors.surface;
    final inp = dark ? AppColors.darkInput : AppColors.inputBg;
    final textP = dark ? AppColors.darkText : AppColors.textPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.teal,
        surface: surf,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: bg,
      cardColor: dark ? AppColors.darkCard : AppColors.cardBg,
      textTheme: GoogleFonts.poppinsTextTheme(
        dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(
        bodyColor: textP,
        displayColor: textP,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 56),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inp,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textP,
        ),
        iconTheme: IconThemeData(color: textP),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? AppColors.darkCard : AppColors.inputBg,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
      ),
    );
  }
}
