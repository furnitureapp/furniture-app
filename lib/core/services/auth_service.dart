import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required String phoneNo,
    required String address,
  }) async {
    final response = await ApiClient.post('/api/register', {
      'email': email,
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'phoneNo': phoneNo,
      'address': address,
    });

    final decoded = jsonDecode(response.body);
    log('Register → ${response.statusCode} : ${response.body}');

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Registration successful'};
    } else {
      return {'success': false, 'message': decoded['error'] ?? 'Registration failed'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return {'success': false, 'message': 'Failed to get FCM token'};

      final response = await ApiClient.post('/api/login', {
        'email': email,
        'password': password,
        'fcmToken': fcmToken,
      });

      final data = jsonDecode(response.body);
      log('Login → ${response.statusCode} : ${response.body}');

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final user = data['user'];
        if (user != null) {
          await prefs.setString('user_email', user['email']);
          await prefs.setString('username', user['username'] ?? '');
          await prefs.setString('phoneNo', user['phoneNo'] ?? '');
          await prefs.setString('address', user['address'] ?? '');
        }
        await prefs.setString('fcm_token', fcmToken);
        return {'success': true, 'user': user};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await ApiClient.post('/api/verify-otp', {'email': email, 'otp': otp});
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await SecureStorage.saveToken(data['token']);
      return {'success': true, 'token': data['token']};
    } else {
      return {'success': false, 'message': data['error'] ?? 'Invalid OTP'};
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await ApiClient.post('/api/resend-otp', {'email': email});
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'OTP resent successfully'};
    } else {
      return {'success': false, 'message': data['error'] ?? 'Failed to resend OTP'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await ApiClient.post('/api/forgot-password', {'email': email});
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['error'] ?? 'Something went wrong'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String otp, String newPassword, String confirmNewPassword) async {
    final response = await ApiClient.post('/api/reset-password', {
      'otp': otp,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    });
    final data = jsonDecode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Reset failed',
    };
  }
}
