import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../api_management_service/api_client.dart';
import '../models_ecom/model_file.dart';
import '../storage/secure_storage.dart';

class CartService {
  static Future<Map<String, dynamic>> addToCart(
    Product product,
    BuildContext context,
  ) async {
    try {
      final token = await SecureStorage.getToken();

      if (token == null || token.isEmpty) {
        return {'error': 'Please ensure you are logged in.'};
      }

      final response = await ApiClient.post(
        '/api/addtocart',
        {'productId': product.id, 'quantity': 1},
        auth: true,
      );

      debugPrint("🛒 Adding product ID: ${product.id}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return {
          'message': responseBody['message'],
          'cart': responseBody['cart'],
        };
      } else {
        final errorBody = json.decode(response.body);
        log("❌ Error response: ${errorBody.toString()}");
        return {
          'error': errorBody['error'] ?? 'Failed to add product to cart',
        };
      }
    } catch (e) {
      log("🔥 Exception in addToCart: $e");
      return {'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getCartItems() async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.get('/api/viewcart', auth: true);
      debugPrint('🧾 Cart response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final itemsData = responseData['cart']['items'] ?? [];
        final List<CartItem> cartItems =
            itemsData.map<CartItem>((item) => CartItem.fromJson(item)).toList();

        final quoteData = responseData['cart']['quote'] ?? {};
        return {'cartItems': cartItems, 'quote': quoteData};
      } else if (response.statusCode == 404) {
        return {'cartItems': [], 'quote': {}};
      } else {
        throw Exception('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading cart: $e');
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(String productId) async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.put(
        '/api/removefromcart',
        {'productId': productId},
        auth: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Failed to remove product from cart',
        );
      }
    } catch (error) {
      throw Exception('Error removing product from cart: $error');
    }
  }

  static Future<Map<String, dynamic>> updateCartQuantity(
    String productId,
    int quantity,
  ) async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      debugPrint("🔄 Updating quantity for $productId to $quantity");

      final response = await ApiClient.put(
        '/api/updatecart/$productId',
        {'quantity': quantity},
        auth: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update cart: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
