import 'package:flutter/material.dart';
import '../api/services/user_service.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;

  UserProvider(this._userService);

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userService.getMe();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
