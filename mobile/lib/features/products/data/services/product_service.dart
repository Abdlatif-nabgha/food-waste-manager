import 'package:dio/dio.dart';
import '../../../../../core/network/dio_client.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final Dio _dio = DioClient().dio;

  Future<List<ProductModel>> getUserProducts(int userId) async {
    try {
      final response = await _dio.get('/api/products/user/$userId');
      return (response.data as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProductModel>> getExpiringProducts(int userId) async {
    try {
      final response = await _dio.get('/api/products/expiring/user/$userId');
      return (response.data as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProductModel>> getExpiredProducts(int userId) async {
    try {
      final response = await _dio.get('/api/products/expired/user/$userId');
      return (response.data as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/api/categories');
      return (response.data as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> addCategory(String name) async {
    try {
      final response = await _dio.post(
        '/api/categories',
        data: {'name': name},
      );
      return response.data['message'] ?? 'Category added successfully';
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> addProduct({
    required int userId,
    required String name,
    required int quantity,
    required String expiryDate,
    required int categoryId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/products/$userId',
        data: {
          'name': name,
          'quantity': quantity,
          'expiryDate': expiryDate,
          'categoryId': categoryId,
        },
      );
      return response.data['message'] ?? 'Product added successfully';
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> updateProduct({
    required int id,
    required int userId,
    required String name,
    required int quantity,
    required String expiryDate,
    required int categoryId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/products/$id/user/$userId',
        data: {
          'name': name,
          'quantity': quantity,
          'expiryDate': expiryDate,
          'categoryId': categoryId,
        },
      );
      return response.data['message'] ?? 'Product updated successfully';
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> deleteProduct({
    required int id,
    required int userId,
  }) async {
    try {
      final response = await _dio.delete('/api/products/$id/user/$userId');
      return response.data['message'] ?? 'Product deleted successfully';
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> consumeProduct({
    required int id,
    required int userId,
  }) async {
    try {
      final response = await _dio.patch('/api/products/$id/consume/user/$userId');
      return response.data['message'] ?? 'Product marked as consumed';
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }
      return error.message ?? 'An unknown error occurred';
    }
    return error.toString();
  }
}
