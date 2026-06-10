import 'package:dio/dio.dart';

/// 应用层异常基类
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message])
      : super(message ?? '登录已过期，请重新登录', 401);
}

class ServerException extends AppException {
  ServerException(String message, [int? statusCode])
      : super(message, statusCode);
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? '网络连接失败，请检查网络');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, 400);
}

class ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code != null && code != 200) {
        final message = data['message']?.toString() ?? '请求失败';
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: AppException(message, code as int?),
          ),
        );
        return;
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapDioException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
      ),
    );
  }

  AppException _mapDioException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('连接超时，请稍后重试');
      case DioExceptionType.connectionError:
        return NetworkException('网络连接失败，请检查网络');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractMessage(err.response);
        switch (statusCode) {
          case 401:
            return UnauthorizedException(message);
          case 400:
            return ValidationException(message);
          default:
            return ServerException(message, statusCode);
        }
      default:
        return AppException('未知错误');
    }
  }

  String _extractMessage(Response? response) {
    if (response?.data is Map<String, dynamic>) {
      return response!.data['message']?.toString() ?? '请求失败';
    }
    return '请求失败';
  }
}
