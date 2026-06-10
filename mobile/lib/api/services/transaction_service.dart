import '../dio_client.dart';
import '../../common/constants/api_constants.dart';
import '../../models/transaction.dart';

class TransactionService {
  final DioClient _client;

  TransactionService(this._client);

  Future<List<Transaction>> getTransactions({
    String? type,
    int? categoryId,
    int? accountId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (accountId != null) queryParams['accountId'] = accountId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _client.dio.get(
      ApiConstants.transactions,
      queryParameters: queryParams,
    );
    final list = response.data['data'] as List;
    return list.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Transaction> getTransaction(int id) async {
    final response = await _client.dio.get('${ApiConstants.transactions}/$id');
    return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Transaction> createTransaction(Map<String, dynamic> body) async {
    final response = await _client.dio.post(
      ApiConstants.transactions,
      data: body,
    );
    return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Transaction> updateTransaction(int id, Map<String, dynamic> body) async {
    final response = await _client.dio.put(
      '${ApiConstants.transactions}/$id',
      data: body,
    );
    return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(int id) async {
    await _client.dio.delete('${ApiConstants.transactions}/$id');
  }
}
