enum ApiStatus { success, error }

/// Every API call returns this – the UI only checks [isSuccess].
///
/// success -> [data], [message], [code] (HTTP status), [meta] (page / unread ...)
/// error   -> [message], [code] (HTTP status or app error code)
class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String message;
  final int? code;
  final Map<String, dynamic> meta;

  const ApiResponse._({
    required this.status,
    required this.message,
    this.data,
    this.code,
    this.meta = const {},
  });

  factory ApiResponse.success(T data,
          {String message = 'यशस्वी', int? code, Map<String, dynamic> meta = const {}}) =>
      ApiResponse._(
          status: ApiStatus.success, data: data, message: message, code: code, meta: meta);

  factory ApiResponse.error(String message, {int? code}) =>
      ApiResponse._(status: ApiStatus.error, message: message, code: code);

  bool get isSuccess => status == ApiStatus.success;
  bool get isError => status == ApiStatus.error;

  @override
  String toString() =>
      'ApiResponse(status: ${status.name}, code: $code, message: $message)';
}
