import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌──── HTTP REQUEST ────────────────────────────');
      print('│ ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        print('│ Headers: ${options.headers}');
      }
      if (options.data != null) {
        print('│ Body: ${options.data}');
      }
      print('└──────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌──── HTTP RESPONSE ───────────────────────────');
      print('│ ${response.statusCode} ${response.requestOptions.uri}');
      print('│ Data: ${response.data}');
      print('└──────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('┌──── HTTP ERROR ──────────────────────────────');
      print('│ ${err.type} ${err.requestOptions.uri}');
      print('│ ${err.message}');
      if (err.response != null) {
        print('│ Response: ${err.response?.data}');
      }
      print('└──────────────────────────────────────────────');
    }
    handler.next(err);
  }
}
