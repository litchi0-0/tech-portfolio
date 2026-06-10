import 'package:flutter/material.dart';
import '../api/services/account_service.dart';
import '../api/interceptors/error_interceptor.dart';
import '../models/account.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service;

  AccountProvider(this._service);

  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance =>
      _accounts.fold(0.0, (sum, a) => sum + a.balance);

  Future<void> fetchAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accounts = await _service.getAccounts();
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccount(Map<String, dynamic> body) async {
    try {
      await _service.createAccount(body);
      await fetchAccounts();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAccount(int id, Map<String, dynamic> body) async {
    try {
      await _service.updateAccount(id, body);
      await fetchAccounts();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(int id) async {
    try {
      await _service.deleteAccount(id);
      _accounts.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Account? getAccountById(int id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
