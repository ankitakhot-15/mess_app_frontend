import 'package:get/get.dart';

/// Bottom navigation index of the customer dashboard (0 = messes, 1 = orders, 2 = profile).
class CustomerShellController extends GetxController {
  final RxInt tab = 0.obs;
}
