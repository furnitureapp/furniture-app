
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../model/model_file.dart';

class ProductService {
  static Future<List<Product>> fetchAllProducts() async {
    final response = await ApiClient.get('/api/getallp', auth: true);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('API Response: ${response.body}');

      if (data['success'] == true && data.containsKey('products')) {
        return (data['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception(
          'No products found or API returned unexpected response',
        );
      }
    } else {
      throw Exception(
        'Failed to connect to the API (status code: ${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> getProductById(String productId) async {
    final response = await ApiClient.get('/api/products/$productId', auth: true);

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('product')) {
        return jsonResponse['product'] as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response format: Product data missing.');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Product not found');
    } else {
      throw Exception(
        'Failed to fetch product: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  static Future<List<Product>> fetchProducts(String subCategoryId) async {
    final response = await ApiClient.get('/api/getproduct/$subCategoryId', auth: true);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productList = data['products'];
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> getRelatedProducts(String productId) async {
    final response = await ApiClient.get('/api/productlist/$productId', auth: true);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['relatedProducts'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Unknown error occurred');
      }
    } else {
      throw Exception('Failed to fetch related products');
    }
  }
}



