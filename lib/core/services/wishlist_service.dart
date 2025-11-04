import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';

class WishlistService {
  static Future<Map<String, dynamic>> addToWishlist(String productId) async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.post(
        '/api/addtowishlist',
        {'productId': productId},
        auth: true,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to add product to wishlist: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error adding to wishlist: $e');
    }
  }

  static Future<void> removeFromWishlist(String productId) async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
     
      final response = await ApiClient.post(
        '/api/removefromwishlist',
        {'productId': productId},
        auth: true,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to remove product from wishlist: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error removing from wishlist: $e');
    }
  }

  /// 🧾 Fetch all items in the wishlist
  static Future<List<Map<String, dynamic>>> getWishlistItems() async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.get('/api/viewwishlist', auth: true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('wishlist') &&
            jsonResponse['wishlist'] is List) {
          final List<dynamic> wishlist = jsonResponse['wishlist'];

          if (wishlist.isEmpty) {
            debugPrint('🩶 Wishlist is empty');
            return [];
          }

          return wishlist.map((item) {
            return {
              '_id': item['productId'],
              'title': item['title'],
              'price': item['price'],
              'offerPrice': item['offerPrice'],
              'description': item['name'],
              'gstPercentage': item['gstPercentage'],
              'images': item['images'] != null ? [item['images']] : [],
              'stock': item['stock'],
            };
          }).toList();
        } else {
          debugPrint(
            '⚠️ Wishlist key missing or malformed, returning empty list.',
          );
          return [];
        }
      } else {
        debugPrint(
          '❌ Failed to fetch wishlist, status code: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('🔥 Error fetching wishlist from API: $e');
      return [];
    }
  }
}
