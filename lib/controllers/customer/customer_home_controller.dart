import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/storage_service.dart';
import '../../model/mess_model.dart';
import '../../repository/customer_repository.dart';

/// "Messes in my area" tab.
class CustomerHomeController extends GetxController {
  final CustomerRepository _repo = Get.find<CustomerRepository>();

  final pincodeController = TextEditingController(text: StorageService.user?.pincode ?? '');
  final RxList<MessModel> messes = <MessModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnInt errorCode = RxnInt();

  String get userName {
    final name = StorageService.user?.fullName ?? '';
    return name.trim().isEmpty ? '' : name.trim().split(' ').first;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final pin = pincodeController.text.trim();
    isLoading.value = true;
    errorMessage.value = null;
    errorCode.value = null;
    AppLogger.i('Loading messes for $pin', tag: 'MESS');

    final res = await _repo.messes(pincode: pin.isEmpty ? null : pin);
    if (res.isSuccess) {
      messes.assignAll(res.data!);
    } else {
      messes.clear();
      errorMessage.value = res.message;
      errorCode.value = res.code;
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    pincodeController.dispose();
    super.onClose();
  }
}
