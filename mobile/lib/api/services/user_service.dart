import '../dio_client.dart';
import '../../common/constants/api_constants.dart';
import '../../models/user.dart';

class UserService {
  final DioClient _client;

  UserService(this._client);

  Future<User> getMe() async {
    final response = await _client.dio.get(ApiConstants.userMe);
    return User.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
