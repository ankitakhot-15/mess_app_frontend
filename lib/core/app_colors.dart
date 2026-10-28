import 'package:flutter/material.dart';

/// Common colour class – colours picked from the "मायेची चव" logo.
class AppColors {
  AppColors._();

  static const Color primaryGreen = Color(0xFF14591D); // "मायेची" text / saree
  static const Color primaryOrange = Color(0xFFD9560B); // "चव" text
  static const Color accentOrange = Color(0xFFF7941D); // logo ring
  static const Color cream = Color(0xFFFFF6E5); // logo background
  static const Color brown = Color(0xFF5D2E17); // spoon / tagline
  static const Color heartRed = Color(0xFFD32F2F);

  static const Color white = Colors.white;
  static const Color black = Color(0xFF1E1E1E);
  static const Color grey = Color(0xFF8D8D8D);
  static const Color lightGrey = Color(0xFFE6DCCB);
  static const Color error = Color(0xFFC62828);

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.white, cream],
  );
}
