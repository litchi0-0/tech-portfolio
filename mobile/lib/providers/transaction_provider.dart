import 'package:flutter/material.dart';
import '../api/services/transaction_service.dart';
import '../api/interceptors/error_interceptor.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;

  TransactionProvider(this._service);

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // 筛选条件
  String? _filterType;
  int? _filterCategoryId;
  int? _filterAccountId;
  String? _filterStartDate;
  String? _filterEndDate;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterType => _filterType;

  // 本月统计
  double get totalExpense =>
      _transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
  double get totalIncome =>
      _transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpense;

  Future<void> fetchTransactions({
    String? type,
    int? categoryId,
    int? accountId,
    String? startDate,
    String? endDate,
  }) async {
    _filterType = type;
    _filterCategoryId = categoryId;
    _filterAccountId = accountId;
    _filterStartDate = startDate;
    _filterEndDate = endDate;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _service.getTransactions(
        type: type,
        categoryId: categoryId,
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction(Map<String, dynamic> body) async {
    try {
      await _service.createTransaction(body);
      await fetchTransactions(
        type: _filterType,
        categoryId: _filterCategoryId,
        accountId: _filterAccountId,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(int id, Map<String, dynamic> body) async {
    try {
      await _service.updateTransaction(id, body);
      await fetchTransactions(
        type: _filterType,
        categoryId: _filterCategoryId,
        accountId: _filterAccountId,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      await _service.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// 根据 ID 查找交易记录（先从本地缓存找，找不到则从 API 获取）
  Future<Transaction> findTransactionById(int id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return await _service.getTransaction(id);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
