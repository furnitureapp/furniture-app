import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:furniture_ecom_app/marketers/models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GSTApiService {
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
  


static Future<GstModel?> verifyGst(String gstNumber) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // final authToken = prefs.getString('auth_token');

    // if (authToken == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/api/verify-gst'),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'gstNumber': gstNumber}),
    );

    print("GST VERIFY RESPONSE: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final gstToken = data['gstVerificationToken'];
      await prefs.setString('gst_verification_token', gstToken);

      final expiry = DateTime.now().add(const Duration(minutes: 10));
      prefs.setString('gst_token_expiry', expiry.toIso8601String());

      // Save GST data locally
      prefs.setString('gst_cache', jsonEncode(data['data']));

      return GstModel.fromJson(data);
    }

    return null;
  } catch (e) {
    print("GST VERIFY ERROR: $e");
    return null;
  }
}

  static Future<bool> isGstTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('gst_token_expiry');
    if (expiryStr == null) return false;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return false;

    return DateTime.now().isBefore(expiry);
  }

  static Future<void> clearExpiredGstTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final valid = await isGstTokenValid();
    if (!valid) {
      await prefs.remove('gst_verification_token');
      await prefs.remove('gst_token_expiry');
    }
  }

}


// old code without updated baseurl and print statements 
  // static Future<bool> isGstTokenValid() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final expiryStr = prefs.getString('gst_token_expiry');
  //   if (expiryStr == null) return false;

  //   final expiry = DateTime.tryParse(expiryStr);
  //   if (expiry == null) return false;

  //   return DateTime.now().isBefore(expiry);
  // }

  // static Future<void> clearExpiredGstTokenIfNeeded() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final valid = await isGstTokenValid();
  //   if (!valid) {
  //     await prefs.remove('gst_verification_token');
  //     await prefs.remove('gst_token_expiry');
  //   }
  // }

  // static Future<Map<String, dynamic>> verifyGst(String gstNumber) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final authToken = prefs.getString('auth_token');
  //     print(authToken);
  //     if (authToken == null) {
  //       return {'success': false, 'message': 'Login required before verifying GST.'};
  //     }

  //     final response = await http.post(
  //       Uri.parse('$baseUrl/api/verify-gst'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $authToken', 
  //       },
  //       body: jsonEncode({'gstNumber': gstNumber}),
  //     );
  //     print('Response status of gst verify: ${response.statusCode}');
  //     print('Response body of gst verify : ${response.body}');

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200 && data['success'] == true) {
  //       final gstToken = data['gstVerificationToken'];
  //       await prefs.setString('gst_verification_token', gstToken);

  //       final expiryTime = DateTime.now().add(const Duration(minutes: 10));
  //       await prefs.setString('gst_token_expiry', expiryTime.toIso8601String());

  //       return {
  //         'success': true,
  //         'message': data['message'],
  //         'data': data['data'],
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': data['message'] ?? 'GST verification failed.',
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': 'Error verifying GST: $e'};
  //   }
  // }