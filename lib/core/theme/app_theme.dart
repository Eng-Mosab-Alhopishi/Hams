import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- COLOR TOKENS (One UI 2026 Standards) ---

  // 1. Common Accents
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentLight = Color(0xFF0077B6); // Deep Cerulean — replaces cyan in light mode
  static const Color successGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF1744);

  // 2. Surface Colors
  static const Color darkBackground = Color(0xFF000000); // True OLED
  static const Color darkSurface = Color(0xFF0D0D0D);
  static const Color lightBackground = Color(0xFFF8F9FA); // Off-white
  static const Color surfaceLight = Color(0xFFF8F9FA);   // One UI surface
  static const Color cardLight = Color(0xFFFFFFFF);      // Card background
  static const Color borderLight = Color(0xFFE2E8F0);    // Subtle border

  // 3. Text Colors (Strict Palette)
  static const Color textPrimaryLight = Color(0xFF1A1A2E); // Deep Charcoal
  static const Color textSecondaryLight = Color(0xFF4A5568); // Slate Gray
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Legacy/Convenience
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color glassColor = Color(0x1AFFFFFF);
  static const Color borderGlass = Color(0x33FFFFFF);

  // 4. Neumorphic Style Colors
  static const Color neuLightBase = Color(0xFFE0E5EC);
  static const Color neuDarkBase = Color(0xFF181818);

  // --- MODERN SHADOW TOKEN (2026) ---

  static List<BoxShadow> getModernShadow(Brightness brightness) {
    final shadowColor = brightness == Brightness.dark 
        ? Colors.black.withValues(alpha: 0.5)
        : const Color(0xFF1A1A2E);

    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.1),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // --- TYPOGRAPHY ---

  static TextTheme _getTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

    // Headline: Cairo (Arabic) / Outfit (English)
    final headlineStyle = GoogleFonts.cairo(
      textStyle: GoogleFonts.outfit(
        color: color,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );

    // Body: Tajawal (Arabic) / Inter (English)
    final bodyStyle = GoogleFonts.tajawal(
      textStyle: GoogleFonts.inter(
        color: color,
        fontSize: 14,
      ),
    );

    return TextTheme(
      headlineLarge: headlineStyle.copyWith(fontSize: 32),
      headlineMedium: headlineStyle.copyWith(fontSize: 24),
      titleLarge: headlineStyle.copyWith(fontSize: 20),
      bodyLarge: bodyStyle.copyWith(fontSize: 16),
      bodyMedium: bodyStyle,
      labelLarge: headlineStyle.copyWith(fontSize: 14, letterSpacing: 2),
    );
  }

  // --- THEME DATA ---

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentPurple,
        surface: darkSurface,
        onSurface: textPrimaryDark,
        error: errorRed,
      ),
      textTheme: _getTextTheme(Brightness.dark),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: accentLight,
        secondary: accentPurple,
        surface: cardLight,
        onSurface: textPrimaryLight,
        error: errorRed,
      ),
      textTheme: _getTextTheme(Brightness.light),
    );
  }

  // Helper for Neumorphic Base Color
  static Color getNeumorphicBase(Brightness brightness) {
    return brightness == Brightness.dark ? neuDarkBase : neuLightBase;
  }
}
