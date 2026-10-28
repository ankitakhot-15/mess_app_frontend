import 'dart:async';
import 'package:get/get.dart';
import '../../core/constants/app_enums.dart';
import '../../core/utils/app_dialogs.dart';
import '../../core/utils/app_snackbar.dart';
import '../../model/order_model.dart';
import '../../model/tracking_model.dart';
import '../../repository/customer_repository.dart';
import '../../widgets/app_loader.dart';
import 'customer_orders_controller.dart';

/// Order detail + tracking + cancel. Opened with `arguments: orderId (String)`.
class OrderDetailController extends GetxController {
  final CustomerRepository _repo = Get.find<CustomerRepository>();

  late final String orderId = Get.arguments as String;

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final Rxn<TrackingModel> tracking = Rxn<TrackingModel>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnInt errorCode = RxnInt();

  Timer? _timer;

  bool get canCancel => order.value?.status == OrderStatus.placed;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      errorMessage.value = null;
      errorCode.value = null;
    }

    final res = await _repo.order(orderId);
    if (!res.isSuccess) {
      if (!silent) {
        errorMessage.value = res.message;
        errorCode.value = res.code;
        isLoading.value = false;
      }
      return;
    }
    order.value = res.data;

    if (OrderStatus.trackable.contains(res.data!.status)) {
      final t = await _repo.tracking(orderId);
      if (t.isSuccess) tracking.value = t.data;
    } else {
      tracking.value = null;
    }
    isLoading.value = false;
    _syncTimer();
  }

  /// Auto refresh every 30 s while the order is moving.
  void _syncTimer() {
    final s = order.value?.status;
    final live = s == OrderStatus.accepted ||
        s == OrderStatus.preparing ||
        s == OrderStatus.ready ||
        s == OrderStatus.outForDelivery;
    if (live && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => load(silent: true));
    } else if (!live) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> cancel() async {
    final ok = await AppDialogs.confirm(
      title: 'ऑर्डर रद्द करायची?',
      message: 'पेमेंट झाले असेल तर पैसे आपोआप परत केले जातील.',
    );
    if (!ok) return;
    final reason = await AppDialogs.prompt(
        title: 'कारण (ऐच्छिक)', hint: 'उदा. चुकून ऑर्डर केली', confirmText: 'रद्द करा');
    if (reason == null) return;

    AppLoader.show();
    final res = await _repo.cancel(orderId, reason: reason);
    AppLoader.hide();

    if (res.isSuccess) {
      AppSnackbar.success(res.message);
      await load();
      if (Get.isRegistered<CustomerOrdersController>()) {
        Get.find<CustomerOrdersController>().load();
      }
    } else {
      AppSnackbar.error(res.message, code: res.code);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
