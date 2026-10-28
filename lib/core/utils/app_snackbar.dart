import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_colors.dart';

/// Common snackbar – shows API success / failure (with error code) to the user.
class AppSnackbar {
  AppSnackbar._();

  static void success(String message) =>
      _show('यशस्वी', message, AppColors.primaryGreen, Icons.check_circle_rounded);

  static void error(String message, {int? code}) => _show(
        'त्रुटी',
        code == null ? message : '$message\nError code: $code',
        AppColors.error,
        Icons.error_rounded,
      );

  static void info(String message) =>
      _show('सूचना', message, AppColors.primaryOrange, Icons.info_rounded);

  static void _show(String title, String message, Color color, IconData icon) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }
}
