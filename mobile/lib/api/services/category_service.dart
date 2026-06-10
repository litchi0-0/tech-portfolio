import '../dio_client.dart';
import '../../common/constants/api_constants.dart';
import '../../models/category.dart';

class CategoryService {
  final DioClient _client;

  CategoryService(this._client);

  Future<List<Category>> getCategories({String? type}) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;

    final response = await _client.dio.get(
      ApiConstants.categories,
      queryParameters: queryParams,
    );
    final list = response.data['data'] as List;
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Category> createCategory(Map<String, dynamic> body) async {
    final response = await _client.dio.post(
      ApiConstants.categories,
      data: body,
    );
    return Category.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> body) async {
    final response = await _client.dio.put(
      '${ApiConstants.categories}/$id',
      data: body,
    );
    return Category.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await _client.dio.delete('${ApiConstants.categories}/$id');
  }
}
