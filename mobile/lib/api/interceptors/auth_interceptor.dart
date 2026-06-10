import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants/api_constants.dart';
import '../../common/constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 注册和登录接口需要 X-App-Key
    final path = options.path;
    if (path.contains('/auth/register') || path.contains('/auth/login')) {
      options.headers['X-App-Key'] = ApiConstants.appKey;
    }

    // 从 SharedPreferences 读取 token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token 过期，清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
    }
    handler.next(err);
  }
}
