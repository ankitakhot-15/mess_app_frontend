import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/app_snackbar.dart';
import '../core/utils/storage_service.dart';
import '../repository/auth_repository.dart';
import '../widgets/app_loader.dart';

class LoginController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  /// One login API for every role – the response `user.role` decides the screen.
  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    AppLogger.i('Login started: ${mobileController.text.trim()}', tag: 'LOGIN');
    AppLoader.show();
    final response = await _repo.login(
      mobile: mobileController.text.trim(),
      password: passwordController.text,
    );
    AppLoader.hide();

    if (!response.isSuccess) {
      AppSnackbar.error(response.message, code: response.code);
      return;
    }

    final auth = response.data!;
    if (!auth.hasToken) {
      AppSnackbar.error('सर्व्हरकडून टोकन मिळाले नाही');
      return;
    }
    // ADMIN (or unknown role) has no screen in this app
    if (AuthService.homeRouteFor(auth.user.role) == null) {
      AppSnackbar.info('हे ॲप ग्राहक, मावशी आणि डिलिव्हरी बॉयसाठी आहे. अ‍ॅडमिनने वेब पॅनल वापरावे.');
      return;
    }

    await StorageService.saveSession(auth);
    if (auth.notice != null) {
      AppSnackbar.info(auth.notice!); // pending / rejected mavshi notice
    } else {
      AppSnackbar.success(response.message);
    }
    AuthService.goHome(); // customer / mavshi / delivery dashboard
  }

  @override
  void onClose() {
    mobileController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
