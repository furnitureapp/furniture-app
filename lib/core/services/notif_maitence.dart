import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../model/model_file.dart';
import '../storage/secure_storage.dart';

class NotifMaintenanceService {

  static Future<List<Notifications>> getNotifications() async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.get('/api/notifications', auth: true);
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> body = responseData['data'];

        if (body.isEmpty) return [];

        return body.map((item) => Notifications.fromJson(item)).toList();
      } else if (responseData['message'] ==
          'No notifications found for this user') {
        return [];
      } else {
        debugPrint('Error: ${response.body}');
        throw Exception(
          responseData['error'] ?? 'Failed to load notifications',
        );
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      throw Exception('Something went wrong. Please try again.');
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
