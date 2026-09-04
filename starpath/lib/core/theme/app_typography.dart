import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const _base = TextStyle(
    fontFamily: 'StarPath',
    color: Colors.white,
    letterSpacing: 0,
  );

  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineSmall => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleSmall => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );


  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
      );

  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get button => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  static TextStyle get xpCounter => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFFFC107), // starGold
      );

  static TextStyle get scoreDisplay => _base.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
      );

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -1,
      fontFamily: 'StarPath',
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: -0.5,
      fontFamily: 'StarPath',
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      fontFamily: 'StarPath',
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      fontFamily: 'StarPath',
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'StarPath',
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'StarPath',
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'StarPath',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontFamily: 'StarPath',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontFamily: 'StarPath',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
      fontFamily: 'StarPath',
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.5,
      fontFamily: 'StarPath',
    ),
  );
}
