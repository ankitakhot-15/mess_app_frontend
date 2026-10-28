import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/api_service.dart';
import '../core/utils/json_helper.dart';
import '../model/order_model.dart';

/// All DELIVERY role APIs.
class DeliveryRepository {
  final ApiService _api;
  DeliveryRepository(this._api);

  /// type: active | history
  Future<ApiResponse<List<OrderModel>>> orders({required String type}) =>
      _api.get<List<OrderModel>>(
        ApiConstants.deliveryOrders,
        query: {'type': type},
        parser: (d) {
          final raw = d is Map ? (d['orders'] ?? d['items']) : d;
          return J.list(raw).map(OrderModel.fromJson).toList();
        },
      );

  Future<ApiResponse<bool>> pickup(String id) =>
      _api.patch<bool>(ApiConstants.deliveryPickup(id), parser: (_) => true);

  Future<ApiResponse<bool>> deliver(String id) =>
      _api.patch<bool>(ApiConstants.deliveryDeliver(id), parser: (_) => true);

  /// level: NORMAL | MODERATE | HEAVY
  Future<ApiResponse<bool>> traffic(String id, {required String level, String? note}) =>
      _api.patch<bool>(
        ApiConstants.deliveryTraffic(id),
        body: {'level': level, if (note != null && note.isNotEmpty) 'note': note},
        parser: (_) => true,
      );

  Future<ApiResponse<bool>> location({
    required double lat,
    required double lng,
    required String areaName,
  }) =>
      _api.patch<bool>(
        ApiConstants.deliveryLocation,
        body: {'lat': lat, 'lng': lng, 'areaName': areaName},
        parser: (_) => true,
      );

  Future<ApiResponse<bool>> availability(bool isAvailable) => _api.patch<bool>(
        ApiConstants.deliveryAvailability,
        body: {'isAvailable': isAvailable},
        parser: (_) => true,
      );
}
