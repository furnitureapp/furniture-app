import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://furniture-app-1q75.vercel.app';
    } else if (Platform.isAndroid) {
      return 'https://furniture-app-1q75.vercel.app';
    } else if (Platform.isIOS) {
      return 'https://furniture-app-1q75.vercel.app';
    } else {
      return 'https://furniture-app-1q75.vercel.app';
    }
  }

  // static Future<Map<String, dynamic>> loginUser(
  //   String email,
  //   String password,
  // ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/api/login'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'email': email, 'password': password}),
  //     );

  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       final prefs = await SharedPreferences.getInstance();

  //       final token = data['data']['token'];
  //       final role = data['data']['role'];
  //       final email = data['data']['email'];
  //       final companyName = data['data']['companyName'] ?? '';
  //       final username = data['data']['username'] ?? '';
  //       final phoneno = data['data']['phoneNumber'] ?? '';
  //       final address = data['data']['address'] ?? '';

  //       await prefs.setString('auth_token', token);
  //       await prefs.setString('user_role', role);
  //       await prefs.setString('user_email', email);
  //       await prefs.setString('user_name', username);
  //       await prefs.setString('company_name', companyName);
  //       await prefs.setString('phoneno', phoneno);
  //       await prefs.setString('address', address);
  //       print("LOGIN RESPONSE FIELDS:");
  //       print("email: ${data['data']['email']}");
  //       print("username: ${data['data']['username']}");
  //       print("company: ${data['data']['companyName']}");
  //       print("phone: ${data['data']['phoneNumber']}");
  //       print("address: ${data['data']['address']}");

  //       return {
  //         'success': true,
  //         'message': data['message'] ?? 'printin successful',
  //         'role': role,
  //       };
  //     }
  //     if (response.statusCode == 403 &&
  //         data['message'] == "Your account is pending approval.") {
  //       final prefs = await SharedPreferences.getInstance();

  //       // ✅ SAVE EMAIL FOR STATUS CHECK
  //       await prefs.setString('pending_email', email);

  //       return {'success': false, 'pending': true, 'message': data['message']};
  //     }

  //     return {'success': false, 'message': data['message'] ?? 'Login failed'};
  //   } catch (error) {
  //     print('printin error: $error');
  //     return {'success': false, 'message': 'Something went wrong: $error'};
  //   }
  // }

static Future<Map<String, dynamic>> loginUser(
  String email,
  String password,
) async {
  try {
    // 1️⃣ Get the FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $fcmToken");

    // 2️⃣ Send login request with FCM token
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fcmToken': fcmToken,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      final token = data['data']['token'];
      final role = data['data']['role'];
      final email = data['data']['email'];
      final companyName = data['data']['companyName'] ?? '';
      final username = data['data']['username'] ?? '';
      final phoneno = data['data']['phoneNumber'] ?? '';
      final address = data['data']['address'] ?? '';

      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', username);
      await prefs.setString('company_name', companyName);
      await prefs.setString('phoneno', phoneno);
      await prefs.setString('address', address);

      return {
        'success': true,
        'message': data['message'] ?? 'Login successful',
        'role': role,
      };
    }

    if (response.statusCode == 403 &&
        data['message'] == "Your account is pending approval.") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_email', email);
      return {'success': false, 'pending': true, 'message': data['message']};
    }

    return {'success': false, 'message': data['message'] ?? 'Login failed'};
  } catch (error) {
    print('Login error: $error');
    return {'success': false, 'message': 'Something went wrong: $error'};
  }
}

  // 🔹 Get saved token
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 🔹 Get saved role
  static Future<String?> getStoredRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // 🔹 Clear all auth data (for logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
  }
}
