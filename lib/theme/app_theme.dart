import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  const AppTheme._();

  // Background Colors
  static const Color creamWhite = Color(0xFFFFF9E6);
  static final Color overlayDim = const Color(0xFF2D3436).withValues(alpha: 0.6);

  // Gameplay Zone Colors
  static const Color dogRoomColor = Color(0xFF54A0FF);
  static const Color catRoomColor = Color(0xFFFF6B6B);
  static const Color exitColor = Color(0xFF1DD1A1);

  // UI Colors
  static const Color primaryButton = Color(0xFFFF9F43);
  static const Color secondaryButton = Color(0xFF54A0FF); // Using dogRoomColor as secondary
  static const Color buttonShadow = Color(0xFFE67E22);
  static const Color successGold = Color(0xFFF1C40F);
  static const Color errorDanger = Color(0xFFEE5253);
  static const Color lockedGray = Color(0xFF95A5A6);
  static const Color darkText = Color(0xFF2D3436);
  static const Color white = Color(0xFFFFFFFF);

  // Text Styles
  static TextStyle get _baseStyle => GoogleFonts.sniglet(
        color: darkText,
      );

  static TextStyle get titleStyle => _baseStyle.copyWith(
        fontSize: 48,
        color: white,
        shadows: [
          const Shadow(
            offset: Offset(0, 0),
            blurRadius: 0,
            color: darkText,
          ),
          // Simulating outline with shadows if needed, 
          // but for simple text styles in Flutter, we might use Paint for stroke 
          // or Stack with offset text. For now, simple shadow/color.
          // The design says "White text with 4px dark outline".
          // Standard TextStyle doesn't support stroke well, usually requires Stack or Paint.
          // We will stick to a basic representation for now.
        ],
      );

  static TextStyle get headerStyle => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get timerStyle => _baseStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get buttonTextStyle => _baseStyle.copyWith(
        fontSize: 24,
        color: white,
        fontWeight: FontWeight.w600, // slightly bold
      );

  static TextStyle get levelNumberStyle => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get statisticsValueStyle => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryButton,
      );

  static TextStyle get bodyStyle => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.normal,
      );
      
  static TextStyle get bodyTextStyle => bodyStyle;

  static TextStyle get labelStyle => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: creamWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryButton,
        surface: creamWhite,
        primary: primaryButton,
        secondary: dogRoomColor,
        error: errorDanger,
      ),
      textTheme: TextTheme(
        displayLarge: titleStyle,
        headlineMedium: headerStyle,
        headlineSmall: timerStyle,
        titleLarge: levelNumberStyle,
        bodyLarge: bodyStyle,
        bodyMedium: labelStyle,
        labelLarge: buttonTextStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryButton,
          foregroundColor: white,
          textStyle: buttonTextStyle,
          elevation: 0, // We will implement custom 3D buttons usually
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

