import 'package:flutter/material.dart';

/// Common responsive helper.
/// Call `Responsive.init(context)` once in build() of each screen.
class Responsive {
  Responsive._();

  static late double screenWidth;
  static late double screenHeight;
  static late double _scale;

  static const double _baseWidth = 390; // design width

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    // limit scaling on tablets / web so UI doesn't become huge
    _scale = (screenWidth.clamp(320, 600)) / _baseWidth;
  }

  static bool get isMobile => screenWidth < 600;
  static bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  static bool get isDesktop => screenWidth >= 1024;

  /// width percentage
  static double wp(double percent) => screenWidth * percent / 100;

  /// height percentage
  static double hp(double percent) => screenHeight * percent / 100;

  /// scaled size for padding, icons, radius
  static double w(double value) => value * _scale;

  /// scaled font size
  static double sp(double value) => value * _scale;

  /// max content width for forms on big screens
  static double get contentWidth => isMobile ? screenWidth : 420;
}
