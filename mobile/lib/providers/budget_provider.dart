import 'package:flutter/material.dart';
import '../api/services/budget_service.dart';
import '../api/interceptors/error_interceptor.dart';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _service;

  BudgetProvider(this._service);

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;
  String _currentMonth = '';

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentMonth => _currentMonth;

  /// 总预算
  Budget? get totalBudget {
    try {
      return _budgets.firstWhere((b) => b.isTotalBudget);
    } catch (_) {
      return null;
    }
  }

  /// 分类预算列表
  List<Budget> get categoryBudgets =>
      _budgets.where((b) => !b.isTotalBudget).toList();

  Future<void> fetchBudgets({String? month}) async {
    _isLoading = true;
    _error = null;
    _currentMonth = month ?? _currentMonth;
    notifyListeners();

    try {
      _budgets = await _service.getBudgets(month: _currentMonth);
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBudget(Map<String, dynamic> body) async {
    try {
      await _service.createBudget(body);
      await fetchBudgets(month: body['month'] as String? ?? _currentMonth);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget(int id, Map<String, dynamic> body) async {
    try {
      await _service.updateBudget(id, body);
      await fetchBudgets();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      await _service.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
