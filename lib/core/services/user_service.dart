import 'dart:convert';
import 'dart:developer';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final response = await ApiClient.get('/api/getprofile', auth: true);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    }
    return null;
  }

  static Future<Map<String, dynamic>> editUserDetails({
    required String email,
    String? username,
    String? address,
    String? phoneNo,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (address != null) body['address'] = address;
    if (phoneNo != null) body['phoneNo'] = phoneNo;

    final response = await ApiClient.put('/api/edit/$email', body, auth: true);
    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? data['error'],
      'user': data['user'],
    };
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      final fcmToken = prefs.getString('fcm_token');
      if (email == null || fcmToken == null) {
        return {'success': false, 'message': 'User data missing'};
      }

      final response = await ApiClient.post('/api/logout', {
        'email': email,
        'fcmToken': fcmToken,
      }, auth: true);

      log('Logout: ${response.statusCode} → ${response.body}');

      if (response.statusCode == 200) {
        await SecureStorage.clear();
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['error'] ?? 'Logout failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
