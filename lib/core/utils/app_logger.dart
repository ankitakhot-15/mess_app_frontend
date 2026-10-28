import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Common logger – prints only in debug mode.
/// Passwords / tokens are masked automatically.
class AppLogger {
  AppLogger._();

  static const _sensitiveKeys = {'password', 'token', 'authorization'};

  static void d(String message, {String tag = 'DEBUG'}) =>
      _log('🐛', tag, message);
  static void i(String message, {String tag = 'INFO'}) =>
      _log('💡', tag, message);
  static void w(String message, {String tag = 'WARN'}) =>
      _log('⚠️', tag, message);

  static void e(String message,
      {Object? error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    _log('⛔', tag, message);
    if (error != null) _log('⛔', tag, 'cause: $error');
    if (stackTrace != null) _log('⛔', tag, stackTrace.toString());
  }

  static void request(String method, Uri uri,
      {Map<String, String>? headers, Map<String, dynamic>? body}) {
    final b = StringBuffer('➡️  $method $uri');
    if (headers != null) b.write('\nheaders: ${_pretty(headers)}');
    if (body != null) b.write('\nbody: ${_pretty(body)}');
    _log('🌐', 'API REQUEST', b.toString());
  }

  static void response(String method, Uri uri, int statusCode, String body) {
    _log('📩', 'API RESPONSE',
        '⬅️  $method $uri  [$statusCode]\n${_prettyText(body)}');
  }

  // ---------- helpers ----------
  static void _log(String icon, String tag, String message) {
    if (!kDebugMode) return;
    debugPrint('$icon [$tag] $message', wrapWidth: 1024);
  }

  static dynamic _mask(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(
          k,
          _sensitiveKeys.contains(k.toString().toLowerCase())
              ? '***'
              : _mask(v)));
    }
    if (value is List) return value.map(_mask).toList();
    return value;
  }

  static String _pretty(Object value) =>
      const JsonEncoder.withIndent('  ').convert(_mask(value));

  static String _prettyText(String raw) {
    try {
      return _pretty(jsonDecode(raw));
    } catch (_) {
      return raw;
    }
  }
}
