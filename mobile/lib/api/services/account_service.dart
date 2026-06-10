import '../dio_client.dart';
import '../../common/constants/api_constants.dart';
import '../../models/account.dart';

class AccountService {
  final DioClient _client;

  AccountService(this._client);

  Future<List<Account>> getAccounts() async {
    final response = await _client.dio.get(ApiConstants.accounts);
    final list = response.data['data'] as List;
    return list.map((e) => Account.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Account> createAccount(Map<String, dynamic> body) async {
    final response = await _client.dio.post(
      ApiConstants.accounts,
      data: body,
    );
    return Account.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Account> updateAccount(int id, Map<String, dynamic> body) async {
    final response = await _client.dio.put(
      '${ApiConstants.accounts}/$id',
      data: body,
    );
    return Account.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteAccount(int id) async {
    await _client.dio.delete('${ApiConstants.accounts}/$id');
  }
}
