import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/auth_data.dart';
import '../../model/user_model.dart';

/// Saves login token + user (with role) locally.
/// Call `await StorageService.init()` in main().
class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  static String? get token => _prefs.getString(_tokenKey);
  static bool get isLoggedIn => (token ?? '').isNotEmpty;

  static UserModel? get user {
    final s = _prefs.getString(_userKey);
    if (s == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSession(AuthData data) async {
    await _prefs.setString(_tokenKey, data.token);
    await _prefs.setString(_userKey, jsonEncode(data.user.toJson()));
  }

  /// Update the stored user only (e.g. after profile edit).
  static Future<void> saveUser(UserModel user) async =>
      _prefs.setString(_userKey, jsonEncode(user.toJson()));

  static Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
