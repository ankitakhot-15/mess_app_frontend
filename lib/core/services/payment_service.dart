import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../model/order_model.dart';

class PaymentResult {
  final bool success;
  final String? orderId;
  final String? paymentId;
  final String? signature;
  final String message;

  const PaymentResult._(this.success, this.orderId, this.paymentId, this.signature, this.message);

  factory PaymentResult.ok({String? orderId, String? paymentId, String? signature}) =>
      PaymentResult._(true, orderId, paymentId, signature, 'पेमेंट यशस्वी');

  factory PaymentResult.fail(String message) =>
      PaymentResult._(false, null, null, null, message);
}

/// Wraps razorpay_flutter into a single awaitable call.
class PaymentService {
  Future<PaymentResult> checkout({
    required RazorpayInfo info,
    required String name,
    required String contact,
    String email = '',
    String description = 'मायेची चव ऑर्डर',
  }) {
    final completer = Completer<PaymentResult>();
    final razorpay = Razorpay();

    void finish(PaymentResult r) {
      if (completer.isCompleted) return;
      completer.complete(r);
      razorpay.clear();
    }

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      finish(PaymentResult.ok(
          orderId: r.orderId, paymentId: r.paymentId, signature: r.signature));
    });
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      finish(PaymentResult.fail(r.message ?? 'पेमेंट अयशस्वी / रद्द झाले'));
    });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {
      finish(PaymentResult.fail('हा वॉलेट पर्याय सध्या उपलब्ध नाही'));
    });

    try {
      razorpay.open({
        'key': info.keyId,
        'order_id': info.orderId,
        'amount': info.amount, // already in paise, as sent by the backend
        'currency': info.currency,
        'name': 'मायेची चव',
        'description': description,
        'prefill': {'contact': contact, 'email': email, 'name': name},
      });
    } catch (e) {
      finish(PaymentResult.fail('पेमेंट सुरू करता आले नाही'));
    }
    return completer.future;
  }
}
