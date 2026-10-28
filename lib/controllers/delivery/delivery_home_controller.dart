import 'dart:async';
import 'package:get/get.dart';
import '../../core/constants/app_enums.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/location_helper.dart';
import '../../core/utils/storage_service.dart';
import '../../model/order_model.dart';
import '../../repository/delivery_repository.dart';
import '../../widgets/app_loader.dart';

/// Delivery boy dashboard: assigned orders, pickup / deliver / traffic,
/// on-duty switch and live GPS (every 20 s while an order is out for delivery).
class DeliveryHomeController extends GetxController {
  final DeliveryRepository _repo = Get.find<DeliveryRepository>();
  final LocationService _location = LocationService();

  /// 'active' | 'history'  (API `type`)
  final RxString type = 'active'.obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnInt errorCode = RxnInt();

  final RxBool isAvailable = (StorageService.user?.isAvailable ?? false).obs;

  Timer? _poll;
  Timer? _gps;
  bool _gpsWarned = false;
  bool _locationSetupAttempted = false;
  bool _sendingLocation = false;

  String get userName => StorageService.user?.fullName ?? '';

  @override
  void onInit() {
    super.onInit();
    load();
    // pick up newly assigned orders
    _poll = Timer.periodic(const Duration(seconds: 45), (_) {
      if (type.value == 'active') load(silent: true);
    });
  }

  void setType(String t) {
    if (type.value == t) return;
    type.value = t;
    load();
  }

  Future<void> load({bool silent = false}) async {
    final requested = type.value;
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = null;
      errorCode.value = null;
    }

    try {
      final res = await _repo.orders(type: requested);
      if (requested != type.value) return; // a newer load handles the state

      if (res.isSuccess) {
        orders.assignAll(res.data!);
        errorMessage.value = null;
      } else if (!silent) {
        orders.clear();
        errorMessage.value = res.message;
        errorCode.value = res.code;
      }
    } catch (e) {
      AppLogger.w('Load failed: $e', tag: 'ORDERS');
      if (!silent && requested == type.value) {
        orders.clear();
        errorMessage.value = 'काहीतरी चूक झाली. पुन्हा प्रयत्न करा.';
      }
    } finally {
      if (requested == type.value) isLoading.value = false; // always reset
    }
    _syncGps();
  }

  // ------------------------------------------------------------------ actions
  /// Runs [action] behind the loader and ALWAYS hides it afterwards.
  Future<T?> _withLoader<T>(Future<T> Function() action) async {
    AppLoader.show();
    try {
      return await action();
    } catch (e) {
      AppLogger.w('Action failed: $e', tag: 'ACTION');
      AppSnackbar.error('काहीतरी चूक झाली. पुन्हा प्रयत्न करा.');
      return null;
    } finally {
      await AppLoader.hide(); // <- await added
    }
  }

  Future<void> toggleAvailability(bool value) async {
    final res = await _withLoader(() => _repo.availability(value));
    if (res == null) return;
    if (res.isSuccess) {
      isAvailable.value = value;
      final u = StorageService.user;
      if (u != null)
        await StorageService.saveUser(u.copyWith(isAvailable: value));
      AppSnackbar.success(
          value ? 'तुम्ही ड्युटीवर आहात' : 'तुम्ही ड्युटी बंद केली');
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }

  Future<void> pickup(OrderModel o) async {
    final res = await _withLoader(() => _repo.pickup(o.id));
    if (res == null) return;
    _after(res.isSuccess, res.message, res.code);
  }

  Future<void> deliver(OrderModel o) async {
    final res = await _withLoader(() => _repo.deliver(o.id));
    if (res == null) return;
    _after(res.isSuccess, res.message, res.code);
  }

  /// level: NORMAL | MODERATE | HEAVY
  Future<void> reportTraffic(OrderModel o, String level, String note) async {
    final res =
        await _withLoader(() => _repo.traffic(o.id, level: level, note: note));
    if (res == null) return;
    _after(res.isSuccess, res.message, res.code, reload: false);
  }

  void _after(bool ok, String message, int? code, {bool reload = true}) {
    if (ok) {
      AppSnackbar.success(message);
      if (reload) load();
    } else {
      AppSnackbar.error(message, code: code);
    }
  }

  // ------------------------------------------------------------------ live GPS
  void _syncGps() {
    final moving = type.value == 'active' &&
        orders.any((o) => o.status == OrderStatus.outForDelivery);
    if (moving && _gps == null) {
      _sendLocation();
      _gps =
          Timer.periodic(const Duration(seconds: 20), (_) => _sendLocation());
    } else if (!moving) {
      _gps?.cancel();
      _gps = null;
    }
  }

  Future<void> _sendLocation() async {
    if (_sendingLocation) return;
    _sendingLocation = true;
    try {
      if (!_locationSetupAttempted) {
        _locationSetupAttempted = true;
        if (!await LocationHelper.ensureLocationOn()) return;
      }

      final loc = await _location
          .current(fallbackArea: StorageService.user?.areaName ?? '')
          .timeout(const Duration(seconds: 15), onTimeout: () => null);
      if (loc == null) {
        if (!_gpsWarned) {
          _gpsWarned = true;
          AppSnackbar.info(
              'लोकेशन चालू करा, म्हणजे ग्राहकाला तुमची जागा दिसेल.');
        }
        return;
      }
      final res = await _repo.location(
          lat: loc.lat, lng: loc.lng, areaName: loc.areaName);
      if (!res.isSuccess)
        AppLogger.w('Location update failed: ${res.message}', tag: 'GPS');
    } catch (e) {
      AppLogger.w('GPS error: $e', tag: 'GPS');
    } finally {
      _sendingLocation = false;
    }
  }

  Future<void> logout() => AuthService.logout();

  @override
  void onClose() {
    _poll?.cancel();
    _gps?.cancel();
    super.onClose();
  }
}
