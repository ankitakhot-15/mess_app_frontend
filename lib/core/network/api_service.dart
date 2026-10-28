import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/app_routes.dart';
import '../constants/api_constants.dart';
import '../utils/app_logger.dart';
import '../utils/storage_service.dart';
import 'api_exception.dart';
import 'api_response.dart';
import 'network_info.dart';

/// The ONLY class that talks to the backend (generic – no business endpoints here).
/// Endpoint-specific calls live in `lib/repository/*`.
///
/// Every method:
///   1. checks internet  (NetworkInfo)  BEFORE calling the API
///   2. adds `Authorization: Bearer <token>` when [requiresAuth]
///   3. returns an [ApiResponse] and NEVER throws
class ApiService {
  final NetworkInfo _networkInfo;
  final http.Client _client;

  ApiService(this._networkInfo, {http.Client? client})
      : _client = client ?? http.Client();

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) parser,
    bool requiresAuth = true,
  }) =>
      _request<T>('GET', endpoint,
          query: query, parser: parser, requiresAuth: requiresAuth);

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(dynamic data) parser,
    bool requiresAuth = true,
  }) =>
      _request<T>('POST', endpoint,
          body: body, parser: parser, requiresAuth: requiresAuth);

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(dynamic data) parser,
  }) =>
      _request<T>('PUT', endpoint, body: body, parser: parser);

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(dynamic data) parser,
  }) =>
      _request<T>('PATCH', endpoint, body: body, parser: parser);

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    required T Function(dynamic data) parser,
  }) =>
      _request<T>('DELETE', endpoint, parser: parser);

  // =====================================================================
  //  COMMON REQUEST HANDLER
  // =====================================================================

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    required T Function(dynamic data) parser,
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    try {
      // 1) network check BEFORE calling the API
      if (!await _networkInfo.isConnected) throw NoInternetException();

      // 2) build request
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final q = <String, String>{
        for (final e in (query ?? {}).entries)
          if (e.value != null && e.value.toString().isNotEmpty)
            e.key: e.value.toString(),
      };
      if (q.isNotEmpty) uri = uri.replace(queryParameters: q);

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (requiresAuth) {
        final token = StorageService.token;
        if (token != null) headers['Authorization'] = 'Bearer $token';
      }
      AppLogger.request(method, uri, headers: headers, body: body);

      // 3) call
      final encoded = body == null ? null : jsonEncode(body);
      final http.Response response;
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(ApiConstants.timeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encoded ?? '{}')
              .timeout(ApiConstants.timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encoded ?? '{}')
              .timeout(ApiConstants.timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: encoded ?? '{}')
              .timeout(ApiConstants.timeout);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers).timeout(ApiConstants.timeout);
          break;
        default:
          throw UnknownException('Unsupported method: $method');
      }

      // 4) handle response
      final text = utf8.decode(response.bodyBytes);
      AppLogger.response(method, uri, response.statusCode, text);
      return _handleResponse<T>(response.statusCode, text, parser);
    } catch (e, st) {
      final ex = _toApiException(e);
      AppLogger.e('API failed: $method $endpoint',
          error: ex, stackTrace: ex is UnknownException ? st : null);
      if (ex is UnauthorizedException && requiresAuth) await _onSessionExpired();
      return ApiResponse<T>.error(ex.message, code: ex.code);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    int status,
    String body,
    T Function(dynamic data) parser,
  ) {
    dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      json = null;
    }
    final message = _extractMessage(json);

    if (status >= 200 && status < 300) {
      if (json is! Map || json['success'] != true) throw DataParseException();
      return ApiResponse<T>.success(
        parser(json['data']),
        message: message ?? 'यशस्वी',
        code: status,
        meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : const {},
      );
    }
    throw _exceptionFromStatus(status, message);
  }

  /// `message` + (for 422) every `errors[].message` on its own line.
  String? _extractMessage(dynamic json) {
    if (json is! Map) return null;
    final base = json['message'] is String ? json['message'] as String : null;
    final errors = json['errors'];
    if (errors is List && errors.isNotEmpty) {
      final lines = errors
          .whereType<Map>()
          .map((e) => e['message']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (lines.isNotEmpty) return [if (base != null) base, ...lines].join('\n');
    }
    return base;
  }

  ApiException _exceptionFromStatus(int status, String? message) {
    switch (status) {
      case 400:
      case 403:
      case 409:
      case 422:
      case 429:
        return BadRequestException(message, code: status);
      case 401:
        return UnauthorizedException(message);
      case 404:
        return NotFoundException(message);
      default:
        // 502 = payment / refund / upload provider failed
        if (status >= 500) return ServerException(message, code: status);
        return UnknownException(message);
    }
  }

  ApiException _toApiException(Object e) {
    if (e is ApiException) return e;
    if (e is SocketException || e is http.ClientException) return NoInternetException();
    if (e is TimeoutException) return RequestTimeoutException();
    if (e is FormatException || e is TypeError) return DataParseException();
    return UnknownException();
  }

  /// Token expired / invalid on a protected API -> clear session, go to login.
  Future<void> _onSessionExpired() async {
    await StorageService.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}
