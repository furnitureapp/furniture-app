

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['WEB_URL'] ?? 'https://furniture-app-ruby.vercel.app';
    } else if (Platform.isAndroid) {
      return dotenv.env['ANDROID_URL'] ??
          'https://furniture-app-ruby.vercel.app';
    } else if (Platform.isIOS) {
      return dotenv.env['IOS_URL'] ?? 'https://furniture-app-ruby.vercel.app';
    } else {
      return dotenv.env['DESKTOP_URL'] ??
          'https://furniture-app-ruby.vercel.app';
    }
  }

  static Future<dynamic> register(
    String email,
    String username,
    String password,
    String confirmPassword,
    String phoneNo,
    String address,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNo': phoneNo,
        'address': address,
      }),
    );

    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Registration successful'};
    } else {
      return {
        'success': false,
        'message': decoded['error'] ?? 'Registration failed',
      };
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        return {'success': false, 'message': 'Failed to retrieve FCM token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
          'platform': Platform.isAndroid ? 'mobile' : 'web',
        }),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        final user = responseData['user'];
        final prefs = await SharedPreferences.getInstance();

        if (user != null) {
          await prefs.setString('user_email', user['email']);
          await prefs.setString('username', user['username'] ?? '');
          await prefs.setString('phoneNo', user['phoneNo'] ?? '');
          await prefs.setString('address', user['address'] ?? '');
        }

        await prefs.setString('fcm_token', fcmToken);

        return {'success': true, 'message': 'Login successful', 'user': user};
      } else {
        String errorMsg = responseData['error'] ?? 'Login failed';
        return {'success': false, 'message': errorMsg};
      }
    } catch (error) {
      return {'success': false, 'message': 'Login failed: $error'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    final url = Uri.parse('$baseUrl/api/verify-otp');
    final body = jsonEncode({'email': email, 'otp': otp});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        return {
          'success': true,
          'message': 'OTP verified successfully',
          'token': data['token'],
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'Invalid OTP!'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to verify OTP: $error'};
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/api/resend-otp');
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': ' ✅ New OTP sent successfully!'};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to resend OTP!',
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to resend OTP: $error'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent to your email',
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Something went wrong',
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to send reset email'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String otp,
    String newPassword,
    String confirmNewPassword,
  ) async {
    final url = Uri.parse('$baseUrl/api/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp': otp,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {'success': false, 'message': responseData['message']};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to send reset email'};
    }
  }
}


// import 'dart:convert';
// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import '../api/api_client.dart';
// import '../storage/secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   static Future<Map<String, dynamic>> register({
//     required String email,
//     required String username,
//     required String password,
//     required String confirmPassword,
//     required String phoneNo,
//     required String address,
//   }) async {
//     final response = await ApiClient.post('/api/register', {
//       'email': email,
//       'username': username,
//       'password': password,
//       'confirmPassword': confirmPassword,
//       'phoneNo': phoneNo,
//       'address': address,
//     });

//     final decoded = jsonDecode(response.body);
//     log('Register → ${response.statusCode} : ${response.body}');

//     if (response.statusCode == 201) {
//       return {'success': true, 'message': 'Registration successful'};
//     } else {
//       return {'success': false, 'message': decoded['error'] ?? 'Registration failed'};
//     }
//   }

//   static Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken == null) return {'success': false, 'message': 'Failed to get FCM token'};

//       final response = await ApiClient.post('/api/login', {
//         'email': email,
//         'password': password,
//         'fcmToken': fcmToken,
//       });

//       final data = jsonDecode(response.body);
//       log('Login → ${response.statusCode} : ${response.body}');

//       if (response.statusCode == 200) {
//         final prefs = await SharedPreferences.getInstance();
//         final user = data['user'];
//         if (user != null) {
//           await prefs.setString('user_email', user['email']);
//           await prefs.setString('username', user['username'] ?? '');
//           await prefs.setString('phoneNo', user['phoneNo'] ?? '');
//           await prefs.setString('address', user['address'] ?? '');
//         }
//         await prefs.setString('fcm_token', fcmToken);
//         return {'success': true, 'user': user};
//       } else {
//         return {'success': false, 'message': data['error'] ?? 'Login failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': e.toString()};
//     }
//   }

//   static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
//     final response = await ApiClient.post('/api/verify-otp', {'email': email, 'otp': otp});
//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       await SecureStorage.saveToken(data['token']);
//       return {'success': true, 'token': data['token']};
//     } else {
//       return {'success': false, 'message': data['error'] ?? 'Invalid OTP'};
//     }
//   }

//   static Future<Map<String, dynamic>> resendOtp(String email) async {
//     final response = await ApiClient.post('/api/resend-otp', {'email': email});
//     final data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return {'success': true, 'message': 'OTP resent successfully'};
//     } else {
//       return {'success': false, 'message': data['error'] ?? 'Failed to resend OTP'};
//     }
//   }

//   static Future<Map<String, dynamic>> forgotPassword(String email) async {
//     final response = await ApiClient.post('/api/forgot-password', {'email': email});
//     final data = jsonDecode(response.body);
//     if (response.statusCode == 200) {
//       return {'success': true, 'message': data['message']};
//     } else {
//       return {'success': false, 'message': data['error'] ?? 'Something went wrong'};
//     }
//   }

//   static Future<Map<String, dynamic>> resetPassword(String otp, String newPassword, String confirmNewPassword) async {
//     final response = await ApiClient.post('/api/reset-password', {
//       'otp': otp,
//       'newPassword': newPassword,
//       'confirmNewPassword': confirmNewPassword,
//     });
//     final data = jsonDecode(response.body);
//     return {
//       'success': response.statusCode == 200,
//       'message': data['message'] ?? 'Reset failed',
//     };
//   }
// }
