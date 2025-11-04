import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../model/model_file.dart';
import '../storage/secure_storage.dart';

class OrderService {
  static Future<List<Order>> fetchOrderHistory() async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.get('/api/orders/history', auth: true);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (!jsonResponse.containsKey('orders') ||
            jsonResponse['orders'] == null) {
          return [];
        }

        final List<dynamic> data = jsonResponse['orders'];
        debugPrint('Parsed response: $jsonResponse');

        return data.map((order) => Order.fromJson(order)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
          'Failed to load order history: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (error) {
      debugPrint('fetchOrderHistory Error: $error');
      throw Exception('An error occurred while fetching order history.');
    }
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.post(
        '/api/orders/cancel',
        {'orderId': orderId},
        auth: true,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {
          'error': true,
          'message': error['message'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  static Future<Order> fetchOrderDetail(String orderId) async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response =
          await ApiClient.get('/api/orders/history/$orderId', auth: true);

      debugPrint('Order detail response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data['order']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch order details.',
        );
      }
    } catch (error) {
      debugPrint('Error fetching order detail: $error');
      throw Exception('Error fetching order detail: $error');
    }
  }
}
