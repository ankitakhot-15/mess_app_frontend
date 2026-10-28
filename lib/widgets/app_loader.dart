import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

/// Common full-screen loader (blocks touches while an API is running).
///   AppLoader.show();  ...await api...  AppLoader.hide();
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
                  const CircularProgressIndicator(color: AppColors.primaryOrange),
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
    );
  }

  static void hide() {
    if (!_isShowing) return;
    _isShowing = false;
    if (Get.isDialogOpen ?? false) Get.back();
  }
}

/// Common inline loader (for lists / sections).
class LoaderView extends StatelessWidget {
  const LoaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator(color: AppColors.primaryOrange)),
    );
  }
}
