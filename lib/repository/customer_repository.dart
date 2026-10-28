import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/api_service.dart';
import '../core/utils/json_helper.dart';
import '../model/mess_model.dart';
import '../model/order_model.dart';
import '../model/tracking_model.dart';
import '../model/user_model.dart';

/// All CUSTOMER role APIs.
class CustomerRepository {
  final ApiService _api;
  CustomerRepository(this._api);

  List<Map<String, dynamic>> _listOf(dynamic d, List<String> keys) {
    if (d is Map) {
      for (final k in keys) {
        if (d[k] is List) return J.list(d[k]);
      }
    }
    return J.list(d);
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> body) =>
      _api.put<UserModel>(
        ApiConstants.customerProfile,
        body: body,
        parser: (d) {
          final m = J.map(d);
          return UserModel.fromJson(m['user'] is Map ? J.map(m['user']) : m);
        },
      );

  Future<ApiResponse<List<MessModel>>> messes({String? pincode}) =>
      _api.get<List<MessModel>>(
        ApiConstants.customerMesses,
        query: {'pincode': pincode},
        parser: (d) => _listOf(d, ['messes', 'items']).map(MessModel.fromJson).toList(),
      );

  Future<ApiResponse<MessDetail>> messDetail(String mavshiId) => _api.get<MessDetail>(
        ApiConstants.customerMess(mavshiId),
        parser: (d) => MessDetail.fromJson(J.map(d)),
      );

  Future<ApiResponse<OrderPreview>> preview(OrderRequest req) => _api.post<OrderPreview>(
        ApiConstants.orderPreview,
        body: req.toJson(),
        parser: (d) => OrderPreview.fromJson(J.map(d)),
      );

  Future<ApiResponse<PlaceOrderResult>> placeOrder(OrderRequest req) =>
      _api.post<PlaceOrderResult>(
        ApiConstants.customerOrders,
        body: req.toJson(),
        parser: (d) => PlaceOrderResult.fromJson(J.map(d)),
      );

  /// Called after Razorpay checkout succeeds – server verifies the signature.
  Future<ApiResponse<bool>> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) =>
      _api.post<bool>(
        ApiConstants.paymentVerify,
        body: {
          'orderId': orderId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
        parser: (_) => true,
      );

  Future<ApiResponse<List<OrderModel>>> orders({String? status}) =>
      _api.get<List<OrderModel>>(
        ApiConstants.customerOrders,
        query: {'status': status},
        parser: (d) => _listOf(d, ['orders', 'items']).map(OrderModel.fromJson).toList(),
      );

  Future<ApiResponse<OrderModel>> order(String id) => _api.get<OrderModel>(
        ApiConstants.customerOrder(id),
        parser: (d) {
          final m = J.map(d);
          return OrderModel.fromJson(m['order'] is Map ? J.map(m['order']) : m);
        },
      );

  Future<ApiResponse<TrackingModel>> tracking(String id) => _api.get<TrackingModel>(
        ApiConstants.customerTracking(id),
        parser: (d) => TrackingModel.fromJson(J.map(d)),
      );

  Future<ApiResponse<bool>> cancel(String id, {String? reason}) => _api.post<bool>(
        ApiConstants.customerCancel(id),
        body: {if (reason != null && reason.isNotEmpty) 'reason': reason},
        parser: (_) => true,
      );
}
