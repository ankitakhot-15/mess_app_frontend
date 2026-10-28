import '../constants/api_constants.dart';

enum ApiErrorType {
  noInternet,
  timeout,
  badRequest,
  unauthorized,
  notFound,
  server,
  parse,
  unknown,
}

/// Base exception for every API failure.
class ApiException implements Exception {
  final String message;
  final int code;
  final ApiErrorType type;

  const ApiException(this.message, {required this.code, required this.type});

  @override
  String toString() => 'ApiException(code: $code, type: ${type.name}, message: $message)';
}

class NoInternetException extends ApiException {
  NoInternetException([String? message])
      : super(message ?? 'इंटरनेट कनेक्शन नाही. कृपया इंटरनेट तपासा.',
            code: ApiCode.noInternet, type: ApiErrorType.noInternet);
}

class RequestTimeoutException extends ApiException {
  RequestTimeoutException([String? message])
      : super(message ?? 'सर्व्हरला उत्तर द्यायला वेळ लागला. पुन्हा प्रयत्न करा.',
            code: ApiCode.timeout, type: ApiErrorType.timeout);
}

/// 400 / 403 / 409 / 422 – wrong input, duplicate data, no permission
class BadRequestException extends ApiException {
  BadRequestException(String? message, {int code = 400})
      : super(message ?? 'चुकीची विनंती.', code: code, type: ApiErrorType.badRequest);
}

/// 401 – wrong credentials or session expired
class UnauthorizedException extends ApiException {
  UnauthorizedException(String? message)
      : super(message ?? 'कृपया पुन्हा लॉगिन करा.',
            code: 401, type: ApiErrorType.unauthorized);
}

class NotFoundException extends ApiException {
  NotFoundException(String? message)
      : super(message ?? 'माहिती सापडली नाही.', code: 404, type: ApiErrorType.notFound);
}

/// 5xx
class ServerException extends ApiException {
  ServerException(String? message, {int code = 500})
      : super(message ?? 'सर्व्हर एरर. थोड्या वेळाने प्रयत्न करा.',
            code: code, type: ApiErrorType.server);
}

/// Response format was not what we expected
class DataParseException extends ApiException {
  DataParseException([String? message])
      : super(message ?? 'सर्व्हरकडून चुकीचा डेटा मिळाला.',
            code: ApiCode.parseError, type: ApiErrorType.parse);
}

class UnknownException extends ApiException {
  UnknownException([String? message])
      : super(message ?? 'काहीतरी चूक झाली. पुन्हा प्रयत्न करा.',
            code: ApiCode.unknown, type: ApiErrorType.unknown);
}
