import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/app_routes.dart';
import '../core/constants/app_enums.dart';
import '../core/network/api_response.dart';
import '../core/services/auth_service.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/app_snackbar.dart';
import '../core/utils/storage_service.dart';
import '../model/auth_data.dart';
import '../model/misc_models.dart';
import '../repository/auth_repository.dart';
import '../widgets/app_loader.dart';

/// One register screen for the 3 self-register roles.
class RegisterController extends GetxController {
  final AuthRepository _repo = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();

  /// customer | delivery | mavshi
  final Rx<UserRole> role = UserRole.customer.obs;
  static const roles = [UserRole.customer, UserRole.delivery, UserRole.mavshi];

  // common
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final areaNameController = TextEditingController();
  final pincodeController = TextEditingController();

  // customer
  final emailController = TextEditingController();

  // delivery
  final vehicleType = 'BIKE'.obs; // BIKE | SCOOTER | CYCLE
  final vehicleNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();

  // mavshi
  final messNameController = TextEditingController();
  final experienceController = TextEditingController();
  final startMonthController = TextEditingController();
  final startYearController = TextEditingController();
  final RxList<Map<String, dynamic>> pricing = <Map<String, dynamic>>[].obs;

  // approved service areas (tap to fill pincode + area)
  final RxList<ServiceArea> areas = <ServiceArea>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    final res = await _repo.serviceAreas();
    if (res.isSuccess) areas.assignAll(res.data!);
  }

  void pickArea(ServiceArea a) {
    pincodeController.text = a.pincode;
    if (a.areaName.isNotEmpty) areaNameController.text = a.areaName;
  }

  void addPricing(Map<String, dynamic> item) => pricing.add(item);
  void removePricing(int index) => pricing.removeAt(index);

  Future<void> register() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (role.value == UserRole.mavshi && pricing.isEmpty) {
      AppSnackbar.error('कृपया किमान एक मेनू आयटम जोडा');
      return;
    }

    AppLogger.i('Register started as ${role.value.value}', tag: 'REGISTER');
    AppLoader.show();
    final response = await _call();
    AppLoader.hide();

    if (!response.isSuccess) {
      AppSnackbar.error(response.message, code: response.code);
      return;
    }
    final AuthData auth = response.data!;
    if (auth.hasToken && AuthService.homeRouteFor(auth.user.role) != null) {
      await StorageService.saveSession(auth); // auto login
      AppSnackbar.success(response.message);
      AuthService.goHome();
    } else {
      AppSnackbar.success(response.message);
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<ApiResponse<AuthData>> _call() {
    final name = fullNameController.text.trim();
    final mobile = mobileController.text.trim();
    final password = passwordController.text;
    final address = addressController.text.trim();
    final area = areaNameController.text.trim();
    final pin = pincodeController.text.trim();

    switch (role.value) {
      case UserRole.delivery:
        return _repo.registerDelivery(
          fullName: name,
          mobile: mobile,
          password: password,
          address: address,
          areaName: area,
          pincode: pin,
          vehicleType: vehicleType.value,
          vehicleNumber: vehicleNumberController.text.trim(),
          licenseNumber: licenseNumberController.text.trim(),
        );
      case UserRole.mavshi:
        return _repo.registerMavshi(body: {
          'fullName': name,
          'mobile': mobile,
          'password': password,
          'address': address,
          'areaName': area,
          'pincode': pin,
          'messName': messNameController.text.trim(),
          'cookingExperienceYears': int.parse(experienceController.text.trim()),
          'messStartMonth': int.parse(startMonthController.text.trim()),
          'messStartYear': int.parse(startYearController.text.trim()),
          'pricing': pricing.toList(),
        });
      default:
        return _repo.registerCustomer(
          fullName: name,
          mobile: mobile,
          password: password,
          email: emailController.text.trim(),
          address: address,
          areaName: area,
          pincode: pin,
        );
    }
  }

  @override
  void onClose() {
    for (final c in [
      fullNameController, mobileController, passwordController, addressController,
      areaNameController, pincodeController, emailController, vehicleNumberController,
      licenseNumberController, messNameController, experienceController,
      startMonthController, startYearController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
