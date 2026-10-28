import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/api_service.dart';
import '../core/utils/json_helper.dart';
import '../model/misc_models.dart';
import '../model/user_model.dart';

/// APIs usable by any logged-in user.
class CommonRepository {
  final ApiService _api;
  CommonRepository(this._api);

  Future<ApiResponse<UserModel>> me() => _api.get<UserModel>(
        ApiConstants.me,
        parser: (d) {
          final m = J.map(d);
          return UserModel.fromJson(m['user'] is Map ? J.map(m['user']) : m);
        },
      );

  /// unread count is in `response.meta['unread']`
  Future<ApiResponse<List<NotificationModel>>> notifications() =>
      _api.get<List<NotificationModel>>(
        ApiConstants.notifications,
        parser: (d) {
          final raw = d is Map ? (d['notifications'] ?? d['items']) : d;
          return J.list(raw).map(NotificationModel.fromJson).toList();
        },
      );

  Future<ApiResponse<bool>> markRead(String id) =>
      _api.patch<bool>(ApiConstants.notificationRead(id), parser: (_) => true);

  Future<ApiResponse<bool>> markAllRead() =>
      _api.patch<bool>(ApiConstants.notificationsReadAll, parser: (_) => true);
}
