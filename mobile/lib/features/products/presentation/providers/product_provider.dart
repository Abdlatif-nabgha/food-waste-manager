import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/product_service.dart';
import '../../../../core/network/auth_storage_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _expiringProducts = [];
  List<ProductModel> _expiredProducts = [];
  List<CategoryModel> _categories = [];
  
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  List<ProductModel> get expiringProducts => _expiringProducts;
  List<ProductModel> get expiredProducts => _expiredProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalProducts => _products.length;
  int get expiringSoonCount => _expiringProducts.length;
  int get expiredCount => _expiredProducts.length;
  int get consumedCount => _products.where((p) => p.status == 'CONSUMED').length;

  Future<void> fetchAllData() async {
    _setLoading(true);
    _error = null;
    try {
      final userId = await AuthStorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final results = await Future.wait([
        _productService.getUserProducts(userId),
        _productService.getExpiringProducts(userId),
        _productService.getExpiredProducts(userId),
        _productService.getCategories(),
      ]);

      _products = results[0] as List<ProductModel>;
      _expiringProducts = results[1] as List<ProductModel>;
      _expiredProducts = results[2] as List<ProductModel>;
      _categories = results[3] as List<CategoryModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProduct({
    required String name,
    required int quantity,
    required String expiryDate,
    required int categoryId,
  }) async {
    _setLoading(true);
    try {
      final userId = await AuthStorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      await _productService.addProduct(
        userId: userId,
        name: name,
        quantity: quantity,
        expiryDate: expiryDate,
        categoryId: categoryId,
      );
      await fetchAllData();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required int quantity,
    required String expiryDate,
    required int categoryId,
  }) async {
    _setLoading(true);
    try {
      final userId = await AuthStorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      await _productService.updateProduct(
        id: id,
        userId: userId,
        name: name,
        quantity: quantity,
        expiryDate: expiryDate,
        categoryId: categoryId,
      );
      await fetchAllData();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    _setLoading(true);
    try {
      final userId = await AuthStorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      await _productService.deleteProduct(id: id, userId: userId);
      await fetchAllData();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> consumeProduct(int id) async {
    _setLoading(true);
    try {
      final userId = await AuthStorageService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      await _productService.consumeProduct(id: id, userId: userId);
      await fetchAllData();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> addCategory(String name) async {
    _setLoading(true);
    try {
      await _productService.addCategory(name);
      await fetchAllData();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
