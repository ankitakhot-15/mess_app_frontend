import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/api_service.dart';
import '../core/utils/json_helper.dart';
import '../model/menu_item.dart';
import '../model/misc_models.dart';
import '../model/order_model.dart';

/// All MAVSHI (mess owner) role APIs.
class MavshiRepository {
  final ApiService _api;
  MavshiRepository(this._api);

  List<Map<String, dynamic>> _listOf(dynamic d, List<String> keys) {
    if (d is Map) {
      for (final k in keys) {
        if (d[k] is List) return J.list(d[k]);
      }
    }
    return J.list(d);
  }

  Future<ApiResponse<MavshiStatus>> status() => _api.get<MavshiStatus>(
        ApiConstants.mavshiStatus,
        parser: (d) => MavshiStatus.fromJson(J.map(d)),
      );

  /// A REJECTED mavshi who saves is re-submitted for review.
  Future<ApiResponse<bool>> updateProfile(Map<String, dynamic> body) =>
      _api.put<bool>(ApiConstants.mavshiProfile, body: body, parser: (_) => true);

  Future<ApiResponse<List<MenuItem>>> menu() => _api.get<List<MenuItem>>(
        ApiConstants.mavshiMenu,
        parser: (d) => _listOf(d, ['menu', 'items']).map(MenuItem.fromJson).toList(),
      );

  Future<ApiResponse<bool>> addMenuItem(Map<String, dynamic> body) =>
      _api.post<bool>(ApiConstants.mavshiMenu, body: body, parser: (_) => true);

  Future<ApiResponse<bool>> updateMenuItem(String id, Map<String, dynamic> body) =>
      _api.put<bool>(ApiConstants.mavshiMenuItem(id), body: body, parser: (_) => true);

  Future<ApiResponse<bool>> deleteMenuItem(String id) =>
      _api.delete<bool>(ApiConstants.mavshiMenuItem(id), parser: (_) => true);

  Future<ApiResponse<List<OrderModel>>> orders({String? status}) =>
      _api.get<List<OrderModel>>(
        ApiConstants.mavshiOrders,
        query: {'status': status},
        parser: (d) => _listOf(d, ['orders', 'items']).map(OrderModel.fromJson).toList(),
      );

  /// status: PREPARING | READY
  Future<ApiResponse<bool>> updateOrderStatus(String id, String status) => _api.patch<bool>(
        ApiConstants.mavshiOrderStatus(id),
        body: {'status': status},
        parser: (_) => true,
      );
}
