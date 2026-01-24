import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme getTextTheme({String? fontFamily}) {
    final textStyle = fontFamily != null ? TextStyle(fontFamily: fontFamily) : const TextStyle();

    return TextTheme(
      displayLarge: GoogleFonts.sourceSans3(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ).merge(textStyle),
      displayMedium: GoogleFonts.sourceSans3(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ).merge(textStyle),
      headlineMedium: GoogleFonts.sourceSans3(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ).merge(textStyle),
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ).merge(textStyle),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ).merge(textStyle),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ).merge(textStyle),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ).merge(textStyle),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ).merge(textStyle),
    );
  }

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
