import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

/// Common full-screen loader (blocks touches while an API is running).
///   AppLoader.show();  ...await api...  await AppLoader.hide();
class AppLoader {
  AppLoader._();

  static bool _isShowing = false;

  static void show({String message = 'कृपया थांबा...'}) {
    if (_isShowing) return;
    _isShowing = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                      color: AppColors.primaryOrange),
                  const SizedBox(height: 14),
                  Text(message, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black45,
    ).then((_) => _isShowing = false);
  }

  static Future<void> hide() async {
    if (!_isShowing) return;

    // 1. Wait until the dialog has actually been pushed (fixes the race)
    var tries = 0;
    while (!(Get.isDialogOpen ?? false) && tries < 20) {
      await Future.delayed(const Duration(milliseconds: 50));
      tries++;
    }

    // 2. Get.back() would close a snackbar first, so close it explicitly
    if (Get.isSnackbarOpen) {
      await Get.closeCurrentSnackbar();
    }

    // 3. Now close the loader dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    _isShowing = false;
  }
}

/// Common inline loader (for lists / sections).
class LoaderView extends StatelessWidget {
  const LoaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange)),
    );
  }
}
