import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api_management_service/api_client.dart';
import '../models_ecom/model_file.dart';
import '../storage/secure_storage.dart';

class NotifMaintenanceService {



static Future<List<Notifications>> getNotifications() async {
  final token = await SecureStorage.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Authentication token is missing. Please log in again.');
  }

  try {
    final response = await ApiClient.get(
      '/api/notifications',
      auth: true,
    );

    debugPrint('🧾 Status Code: ${response.statusCode}');
    debugPrint('🧾 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          json.decode(response.body);

      if (responseData['success'] == true) {
        final List<dynamic> notificationList =
            responseData['notifications'] ?? [];

        return notificationList
            .map((item) => Notifications.fromJson(item))
            .toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load notifications');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('❌ Error fetching notifications: $e');
    rethrow;
  }
}

static Future<bool> markNotificationAsRead(String notificationId) async {
  final token = await SecureStorage.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Authentication token missing');
  }

  try {
    final response = await ApiClient.post(
      '/api/notificationread/$notificationId',{},
      auth: true,
    );

    debugPrint('🧾 Read API Response of notification read: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          json.decode(response.body);

      return responseData['success'] == true;
    } else {
      return false;
    }
  } catch (e) {
    debugPrint('❌ Error marking notification as read: $e');
    return false;
  }
}

  static Future<Map<String, dynamic>> fetchMaintenanceStatus() async {
    try {
      final response = await ApiClient.get('/api/status');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'maintenance': false};
      }
    } catch (e) {
      debugPrint('Maintenance status fetch error: $e');
      return {'maintenance': false};
    }
  }
}

