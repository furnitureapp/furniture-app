import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../model/model_file.dart';

class SearchService {
  
  static Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await ApiClient.get('/api/search?title=$query');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('🔍 Search Response: ${response.body}');
        List<dynamic> allProducts = [];

        if (data.containsKey('products')) {
          allProducts.addAll(data['products']);
        }

        if (data.containsKey('subcategories')) {
          for (var sub in data['subcategories']) {
            if (sub.containsKey('products')) {
              allProducts.addAll(sub['products']);
            }
          }
        }

        if (data.containsKey('categories')) {
          for (var cat in data['categories']) {
            if (cat.containsKey('products')) {
              allProducts.addAll(cat['products']);
            }
          }
        }

        return allProducts;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  /// 🧠 Search products with related/similar items
  static Future<List<Product>> searchWithRelated(String query) async {
    try {
      final response = await ApiClient.get('/api/search-with-related?title=$query');

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      debugPrint('🧠 Search-with-Related Response: ${response.body}');

      if (response.statusCode == 200) {
        // ✅ Handle 'products'
        if (jsonResponse.containsKey('products')) {
          return (jsonResponse['products'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
        }

        // ✅ Handle 'multipleProducts'
        if (jsonResponse.containsKey('multipleProducts')) {
          return (jsonResponse['multipleProducts'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
        }

        // ✅ Handle single product + related items
        if (jsonResponse.containsKey('product')) {
          final productData = jsonResponse['product'];

          final Product mainProduct = Product.fromJson(productData['product']);

          final List<Product> relatedProducts = [];

          if (productData['related'] != null &&
              productData['related']['similarStartingLetter'] != null) {
            relatedProducts.addAll(
              (productData['related']['similarStartingLetter'] as List)
                  .map((e) => Product.fromJson(e))
                  .toList(),
            );
          }

          return [mainProduct, ...relatedProducts];
        }

        return [];
      } else {
        throw Exception('Failed to fetch search results.');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      throw Exception('Something went wrong while searching.');
    }
  }

  /// 🧭 Alternate search endpoint (if used elsewhere)
  static Future<List<Product>> searchProductsWithRelated(String title) async {
    try {
      final encodedTitle = Uri.encodeQueryComponent(title);
      final response =
          await ApiClient.get('/api/search-with-related?title=$encodedTitle');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['products'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
        return products;
      } else if (response.statusCode == 400) {
        throw Exception('Title query parameter is required');
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
