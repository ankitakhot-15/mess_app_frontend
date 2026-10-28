import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/app_routes.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants/app_enums.dart';
import '../../core/responsive.dart';
import '../../core/services/payment_service.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/date_helper.dart';
import '../../core/utils/storage_service.dart';
import '../../model/order_model.dart';
import '../../repository/customer_repository.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/common_button.dart';
import 'cart_controller.dart';
import 'customer_orders_controller.dart';
import 'customer_shell_controller.dart';

/// Cart review -> server price preview -> place order -> (Razorpay) -> verify.
class CheckoutController extends GetxController {
  final CustomerRepository _repo = Get.find<CustomerRepository>();
  final PaymentService _payment = Get.find<PaymentService>();
  final CartController cart = Get.find<CartController>();

  final formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final areaNameController = TextEditingController();
  final notesController = TextEditingController();

  final Rx<PaymentMethod> payment = PaymentMethod.cod.obs;
  final Rx<DateTime> startDate = DateTime.now().add(const Duration(days: 1)).obs;

  final Rxn<OrderPreview> preview = Rxn<OrderPreview>();
  final RxBool previewLoading = false.obs;
  final RxnString previewError = RxnString();
  final RxnInt previewErrorCode = RxnInt();

  int _seq = 0; // ignore stale preview responses
  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    final u = StorageService.user;
    addressController.text = u?.address ?? '';
    pincodeController.text = u?.pincode ?? '';
    areaNameController.text = u?.areaName ?? '';

    loadPreview();
    // price changes when the plan or the quantities change
    _worker = everAll([cart.plan, cart.lines], (_) => loadPreview());
  }

  OrderRequest _request() => OrderRequest(
        mavshiId: cart.mess.value?.id ?? '',
        plan: cart.plan.value.value,
        startDate: DateHelper.api(startDate.value),
        items: {for (final e in cart.lines.entries) e.key: e.value.qty},
        address: addressController.text.trim(),
        pincode: pincodeController.text.trim(),
        areaName: areaNameController.text.trim(),
        paymentMethod: payment.value.value,
        notes: notesController.text.trim(),
      );

  Future<void> pickStartDate() async {
    final ctx = Get.context;
    if (ctx == null) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: startDate.value,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) startDate.value = picked;
  }

  Future<void> loadPreview() async {
    if (cart.isEmpty) {
      preview.value = null;
      return;
    }
    final my = ++_seq;
    previewLoading.value = true;
    previewError.value = null;
    previewErrorCode.value = null;

    final res = await _repo.preview(_request());
    if (my != _seq) return;

    if (res.isSuccess) {
      preview.value = res.data;
    } else {
      preview.value = null;
      previewError.value = res.message;
      previewErrorCode.value = res.code;
    }
    previewLoading.value = false;
  }

  Future<void> placeOrder() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (cart.isEmpty) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    AppLogger.i('Placing order (${payment.value.value}, ${cart.plan.value.value})', tag: 'ORDER');
    AppLoader.show();
    final res = await _repo.placeOrder(_request());
    AppLoader.hide();

    if (!res.isSuccess) {
      AppSnackbar.error(res.message, code: res.code);
      return;
    }
    final result = res.data!;

    if (payment.value == PaymentMethod.online && result.razorpay != null) {
      await _payOnline(result);
    } else {
      await _finish(result.order, 'ऑर्डर यशस्वी! 🎉',
          'तुमची ऑर्डर अ‍ॅडमिनकडे गेली आहे. स्वीकारल्यावर तुम्हाला सूचना मिळेल.');
    }
  }

  Future<void> _payOnline(PlaceOrderResult result) async {
    final user = StorageService.user;
    final info = result.razorpay!;
    final pay = await _payment.checkout(
      info: info,
      name: user?.fullName ?? '',
      contact: user?.mobile ?? '',
      email: user?.email ?? '',
    );

    if (!pay.success) {
      // order stays PAYMENT_PENDING; webhook confirms it if money was captured
      AppSnackbar.error(pay.message);
      await _finish(result.order, 'पेमेंट पूर्ण झाले नाही',
          'तुमची ऑर्डर "पेमेंट बाकी" स्थितीत आहे. पैसे कापले गेले असतील तर ती आपोआप कन्फर्म होईल.');
      return;
    }

    AppLoader.show(message: 'पेमेंट तपासत आहोत...');
    final verify = await _repo.verifyPayment(
      orderId: result.order.id,
      razorpayOrderId: pay.orderId ?? info.orderId,
      razorpayPaymentId: pay.paymentId ?? '',
      razorpaySignature: pay.signature ?? '',
    );
    AppLoader.hide();

    if (verify.isSuccess) {
      await _finish(result.order, 'पेमेंट यशस्वी! 🎉',
          'तुमची ऑर्डर अ‍ॅडमिनकडे गेली आहे. स्वीकारल्यावर तुम्हाला सूचना मिळेल.');
    } else {
      AppSnackbar.error(verify.message, code: verify.code);
      await _finish(result.order, 'पेमेंट तपासणी बाकी',
          'पेमेंट मिळाल्यावर ऑर्डर आपोआप कन्फर्म होईल. "माझ्या ऑर्डर" मध्ये स्थिती पहा.');
    }
  }

  /// Clear cart, show a dialog, go back to the dashboard orders tab.
  Future<void> _finish(OrderModel order, String title, String message) async {
    cart.clear();
    await Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.w(20))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.primaryGreen, size: Responsive.w(70)),
            SizedBox(height: Responsive.w(10)),
            Text(title, textAlign: TextAlign.center, style: AppTextStyles.subHeading),
            SizedBox(height: Responsive.w(8)),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyGrey),
            SizedBox(height: Responsive.w(18)),
            CommonButton(text: 'ठीक आहे', onPressed: () => Get.back()),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    Get.until((route) => route.settings.name == AppRoutes.customerHome);
    if (Get.isRegistered<CustomerShellController>()) {
      Get.find<CustomerShellController>().tab.value = 1;
    }
    if (Get.isRegistered<CustomerOrdersController>()) {
      Get.find<CustomerOrdersController>().load();
    }
  }

  @override
  void onClose() {
    _worker?.dispose();
    addressController.dispose();
    pincodeController.dispose();
    areaNameController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
