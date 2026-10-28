import 'package:get/get.dart';
import '../core/network/api_service.dart';
import '../core/network/network_info.dart';
import '../core/services/payment_service.dart';
import '../repository/auth_repository.dart';
import '../repository/common_repository.dart';
import '../repository/customer_repository.dart';
import '../repository/delivery_repository.dart';
import '../repository/mavshi_repository.dart';

/// App-wide singletons.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NetworkInfo>(NetworkInfo(), permanent: true);
    Get.put<ApiService>(ApiService(Get.find<NetworkInfo>()), permanent: true);

    final api = Get.find<ApiService>();
    Get.put<AuthRepository>(AuthRepository(api), permanent: true);
    Get.put<CommonRepository>(CommonRepository(api), permanent: true);
    Get.put<CustomerRepository>(CustomerRepository(api), permanent: true);
    Get.put<MavshiRepository>(MavshiRepository(api), permanent: true);
    Get.put<DeliveryRepository>(DeliveryRepository(api), permanent: true);
    Get.put<PaymentService>(PaymentService(), permanent: true);
  }
}
