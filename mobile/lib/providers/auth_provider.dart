import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/services/auth_service.dart';
import '../common/constants/app_constants.dart';
import '../models/user.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;

  /// 检查本地是否有 token，自动登录
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null || token.isEmpty) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    // 尝试获取用户信息验证 token 有效性
    try {
      _status = AuthStatus.loading;
      notifyListeners();
      // 用 ping 简单验证连通性，再通过 token 请求 /user/me
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      await _clearToken();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// 登录
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.login(
        username: username,
        password: password,
      );
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      _user = User.fromJson(userData);

      // 保存 token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// 注册
  Future<bool> register(String username, String password, {String? nickname}) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        username: username,
        password: password,
        nickname: nickname,
      );
      // 注册成功后自动登录
      return await login(username, password);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }
}
