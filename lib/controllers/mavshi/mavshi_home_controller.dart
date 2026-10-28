import 'package:get/get.dart';
import '../../core/constants/app_enums.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/storage_service.dart';
import '../../model/menu_item.dart';
import '../../model/misc_models.dart';
import '../../model/order_model.dart';
import '../../repository/mavshi_repository.dart';
import '../../widgets/app_loader.dart';

/// Mess owner dashboard: approval status -> orders + menu.
/// Menu / order APIs only work when the mavshi is ACTIVE (approved).
class MavshiHomeController extends GetxController {
  final MavshiRepository _repo = Get.find<MavshiRepository>();

  /// order statuses the mavshi can see (pending / rejected orders are hidden)
  static const orderFilters = <String?>[
    null,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  // approval status
  final Rxn<MavshiStatus> status = Rxn<MavshiStatus>();
  final RxBool statusLoading = true.obs;
  final RxnString statusError = RxnString();
  final RxnInt statusErrorCode = RxnInt();

  final RxInt tab = 0.obs; // 0 = orders, 1 = menu

  // orders
  final RxnString orderFilter = RxnString();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool ordersLoading = false.obs;
  final RxnString ordersError = RxnString();
  final RxnInt ordersErrorCode = RxnInt();

  // menu
  final RxList<MenuItem> menu = <MenuItem>[].obs;
  final RxBool menuLoading = false.obs;
  final RxnString menuError = RxnString();
  final RxnInt menuErrorCode = RxnInt();

  String get messName {
    final n = StorageService.user?.messName ?? '';
    return n.isEmpty ? (StorageService.user?.fullName ?? '') : n;
  }

  @override
  void onInit() {
    super.onInit();
    loadStatus();
  }

  // ------------------------------------------------------------------
  Future<void> loadStatus() async {
    statusLoading.value = true;
    statusError.value = null;
    statusErrorCode.value = null;

    final res = await _repo.status();
    if (res.isSuccess) {
      status.value = res.data;
      if (res.data!.isActive) {
        loadOrders();
        loadMenu();
      }
    } else {
      statusError.value = res.message;
      statusErrorCode.value = res.code;
    }
    statusLoading.value = false;
  }

  /// A REJECTED mavshi edits details -> backend re-submits for review.
  Future<void> resubmitProfile(Map<String, dynamic> body) async {
    AppLoader.show();
    final res = await _repo.updateProfile(body);
    AppLoader.hide();
    if (res.isSuccess) {
      AppSnackbar.success(res.message);
      await loadStatus();
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }

  // ------------------------------------------------------------------ orders
  void setOrderFilter(String? s) {
    if (orderFilter.value == s) return;
    orderFilter.value = s;
    loadOrders();
  }

  Future<void> loadOrders() async {
    final requested = orderFilter.value;
    ordersLoading.value = true;
    ordersError.value = null;
    ordersErrorCode.value = null;

    final res = await _repo.orders(status: requested);
    if (requested != orderFilter.value) return;

    if (res.isSuccess) {
      orders.assignAll(res.data!);
    } else {
      orders.clear();
      ordersError.value = res.message;
      ordersErrorCode.value = res.code;
    }
    ordersLoading.value = false;
  }

  /// ACCEPTED -> PREPARING -> READY
  Future<void> updateOrderStatus(OrderModel o, String newStatus) async {
    AppLoader.show();
    final res = await _repo.updateOrderStatus(o.id, newStatus);
    AppLoader.hide();
    if (res.isSuccess) {
      AppSnackbar.success(res.message);
      loadOrders();
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }

  // ------------------------------------------------------------------ menu
  Future<void> loadMenu() async {
    menuLoading.value = true;
    menuError.value = null;
    menuErrorCode.value = null;

    final res = await _repo.menu();
    if (res.isSuccess) {
      menu.assignAll(res.data!);
    } else {
      menu.clear();
      menuError.value = res.message;
      menuErrorCode.value = res.code;
    }
    menuLoading.value = false;
  }

  /// Returns true on success (the form sheet closes itself then).
  Future<bool> saveMenuItem(Map<String, dynamic> body, {String? editId}) async {
    AppLoader.show();
    final res = editId == null
        ? await _repo.addMenuItem(body)
        : await _repo.updateMenuItem(editId, body);
    AppLoader.hide();
    if (res.isSuccess) {
      AppSnackbar.success(res.message);
      loadMenu();
      return true;
    }
    AppSnackbar.error(res.message, code: res.code);
    return false;
  }

  Future<void> toggleAvailable(MenuItem item, bool value) async {
    final res = await _repo.updateMenuItem(item.id, {'available': value});
    if (res.isSuccess) {
      loadMenu();
    } else {
      AppSnackbar.error(res.message, code: res.code);
      loadMenu(); // reset the switch
    }
  }

  Future<void> deleteMenuItem(MenuItem item) async {
    AppLoader.show();
    final res = await _repo.deleteMenuItem(item.id);
    AppLoader.hide();
    if (res.isSuccess) {
      AppSnackbar.success(res.message);
      loadMenu();
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }

  Future<void> logout() => AuthService.logout();
}
