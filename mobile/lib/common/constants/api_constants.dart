class ApiConstants {
  ApiConstants._();

  // TODO: 根据运行环境修改 baseUrl
  // Android 模拟器: http://10.0.2.2:8080/api
  // iOS 模拟器: http://localhost:8080/api
  // 真机: http://你的电脑IP:8080/api
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static const String appKey = 'nl_flutter_2026';

  // 端点路径
  static const String ping = '/ping';
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String userMe = '/user/me';
  static const String transactions = '/transactions';
  static const String categories = '/categories';
  static const String accounts = '/accounts';
  static const String budgets = '/budgets';
}
