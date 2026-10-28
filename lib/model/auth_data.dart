import '../core/utils/json_helper.dart';
import 'user_model.dart';

/// `data` part of login / register response.
class AuthData {
  final String token;
  final UserModel user;

  /// Message shown to a PENDING / REJECTED mavshi (backend sends it on login).
  final String? notice;

  const AuthData({required this.token, required this.user, this.notice});

  bool get hasToken => token.isNotEmpty;

  factory AuthData.fromJson(Map<String, dynamic> j) {
    final n = j['notice'];
    String? notice;
    if (n is String && n.trim().isNotEmpty) {
      notice = n;
    } else if (n is Map) {
      notice = J.firstStr(J.map(n), ['message', 'reason', 'text']);
      if (notice.isEmpty) notice = null;
    }
    return AuthData(
      token: J.str(j['token']),
      user: UserModel.fromJson(J.map(j['user'])),
      notice: notice,
    );
  }
}
