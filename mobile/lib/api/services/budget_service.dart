import '../dio_client.dart';
import '../../common/constants/api_constants.dart';
import '../../models/budget.dart';

class BudgetService {
  final DioClient _client;

  BudgetService(this._client);

  Future<List<Budget>> getBudgets({String? month}) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month;

    final response = await _client.dio.get(
      ApiConstants.budgets,
      queryParameters: queryParams,
    );
    final list = response.data['data'] as List;
    return list.map((e) => Budget.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Budget> createBudget(Map<String, dynamic> body) async {
    final response = await _client.dio.post(
      ApiConstants.budgets,
      data: body,
    );
    return Budget.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Budget> updateBudget(int id, Map<String, dynamic> body) async {
    final response = await _client.dio.put(
      '${ApiConstants.budgets}/$id',
      data: body,
    );
    return Budget.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBudget(int id) async {
    await _client.dio.delete('${ApiConstants.budgets}/$id');
  }
}
