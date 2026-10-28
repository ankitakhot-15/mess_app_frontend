import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'responsive.dart';

/// Common text styles (Mukta font supports Marathi / Devanagari well).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.black,
    double? height,
  }) =>
      GoogleFonts.mukta(
        fontSize: Responsive.sp(size),
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle get heading =>
      _base(size: 28, weight: FontWeight.w800, color: AppColors.primaryGreen);

  static TextStyle get subHeading =>
      _base(size: 20, weight: FontWeight.w700, color: AppColors.brown);

  static TextStyle get body => _base(size: 16);

  static TextStyle get bodyGrey => _base(size: 14, color: AppColors.grey);

  static TextStyle get label =>
      _base(size: 14, weight: FontWeight.w600, color: AppColors.brown);

  static TextStyle get hint => _base(size: 15, color: AppColors.grey);

  static TextStyle get error => _base(size: 12, color: AppColors.error);

  static TextStyle get button =>
      _base(size: 17, weight: FontWeight.w700, color: AppColors.white);

  static TextStyle get link =>
      _base(size: 14, weight: FontWeight.w700, color: AppColors.primaryOrange);

  static TextStyle get cardTitle =>
      _base(size: 16, weight: FontWeight.w700, color: AppColors.brown);

  static TextStyle get caption => _base(size: 12, color: AppColors.grey);

  static TextStyle get tagline =>
      _base(size: 16, weight: FontWeight.w600, color: AppColors.brown);
}
