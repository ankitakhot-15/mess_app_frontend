import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/storage_service.dart';
import '../../repository/customer_repository.dart';
import '../../widgets/app_loader.dart';

class CustomerProfileController extends GetxController {
  final CustomerRepository _repo = Get.find<CustomerRepository>();

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final areaNameController = TextEditingController();
  final pincodeController = TextEditingController();

  String get mobile => StorageService.user?.mobile ?? '';

  @override
  void onInit() {
    super.onInit();
    final u = StorageService.user;
    fullNameController.text = u?.fullName ?? '';
    emailController.text = u?.email ?? '';
    addressController.text = u?.address ?? '';
    areaNameController.text = u?.areaName ?? '';
    pincodeController.text = u?.pincode ?? '';
  }

  Future<void> save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final body = {
      'fullName': fullNameController.text.trim(),
      if (emailController.text.trim().isNotEmpty) 'email': emailController.text.trim(),
      'address': addressController.text.trim(),
      'areaName': areaNameController.text.trim(),
      'pincode': pincodeController.text.trim(),
    };

    AppLoader.show();
    final res = await _repo.updateProfile(body);
    AppLoader.hide();

    if (res.isSuccess) {
      final old = StorageService.user;
      if (old != null) {
        await StorageService.saveUser(old.copyWith(
          fullName: body['fullName'],
          email: body['email'] ?? old.email,
          address: body['address'],
          areaName: body['areaName'],
          pincode: body['pincode'],
        ));
      }
      AppSnackbar.success(res.message);
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }

  Future<void> logout() => AuthService.logout();

  @override
  void onClose() {
    for (final c in [
      fullNameController, emailController, addressController,
      areaNameController, pincodeController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
