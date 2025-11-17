import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiAuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://furniture-app-ruby.vercel.app';
    } else if (Platform.isAndroid) {
      return 'https://furniture-app-ruby.vercel.app';
    } else if (Platform.isIOS) {
      return 'https://furniture-app-ruby.vercel.app';
    } else {
      return 'https://furniture-app-ruby.vercel.app';
    }
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        
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

        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', role);
        await prefs.setString('user_email', email);

        return {
          'success': true,
          'message': data['message'] ?? 'printin successful',
          'role': role,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'printin failed',
        };
      }
    } catch (error) {
      print('printin error: $error');
      return {'success': false, 'message': 'Something went wrong: $error'};
    }
  }
}
