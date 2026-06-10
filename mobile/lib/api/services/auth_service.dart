import '../dio_client.dart';
import '../../common/constants/api_constants.dart';
import '../../models/user.dart';

class AuthService {
  final DioClient _client;

  AuthService(this._client);

  Future<String> ping() async {
    final response = await _client.dio.get(ApiConstants.ping);
    return response.data['data'] as String;
  }

  Future<User> register({
    required String username,
    required String password,
    String? nickname,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.authRegister,
      data: {
        'username': username,
        'password': password,
        if (nickname != null) 'nickname': nickname,
      },
    );
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.authLogin,
      data: {
        'username': username,
        'password': password,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
