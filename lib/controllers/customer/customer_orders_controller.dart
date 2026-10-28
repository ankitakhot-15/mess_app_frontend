import 'package:get/get.dart';
import '../../core/constants/app_enums.dart';
import '../../model/order_model.dart';
import '../../repository/customer_repository.dart';

/// "My orders" tab.
class CustomerOrdersController extends GetxController {
  final CustomerRepository _repo = Get.find<CustomerRepository>();

  /// null = all
  static const filters = <String?>[
    null,
    OrderStatus.paymentPending,
    OrderStatus.placed,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
    OrderStatus.rejected,
    OrderStatus.cancelled,
  ];

  final RxnString filter = RxnString();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxnInt errorCode = RxnInt();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void setFilter(String? status) {
    if (filter.value == status) return;
    filter.value = status;
    load();
  }

  Future<void> load() async {
    final requested = filter.value;
    isLoading.value = true;
    errorMessage.value = null;
    errorCode.value = null;

    final res = await _repo.orders(status: requested);
    if (requested != filter.value) return; // filter changed while loading

    if (res.isSuccess) {
      orders.assignAll(res.data!);
    } else {
      orders.clear();
      errorMessage.value = res.message;
      errorCode.value = res.code;
    }
    isLoading.value = false;
  }
}
