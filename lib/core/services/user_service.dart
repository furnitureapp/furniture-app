import 'dart:convert';
import 'package:furniture_ecom_app/core/api/api_service_auth.dart';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {

  static Future<Map<String, dynamic>?> getUserProfile() async {
  final response = await ApiClient.get('/api/users/dealer', auth: true);

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    print('Response status of get dealer: ${response.statusCode}');
      print('Response body of get dealer: ${response.body}');
    final list = decoded['data'];
    if (list is List && list.isNotEmpty) {
      return list[0]; // return first dealer
    }
  }
  return null;
}

 static Future<void> saveProfileToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final profile = await getUserProfile();

    if (profile == null) return;
    
    await prefs.setString("user_name", profile["username"] ?? "");
    await prefs.setString("company_name", profile["companyName"] ?? "");
    await prefs.setString("phoneno", profile["phoneNumber"] ?? "");
    await prefs.setString("address", profile["address"] ?? "");
  }


static Future<Map<String, dynamic>> logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Read stored token
    final token = prefs.getString('auth_token');
    if (token == null) {
      return {
        'success': false,
        'message': 'No token found'
      };
    }

    // Send logout request
    final response = await http.post(
      Uri.parse('${ApiAuthService.baseUrl}/api/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Logout status: ${response.statusCode}');
    print('Logout body: ${response.body}');

    if (response.statusCode == 200) {
      // Clear ALL stored credentials
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_email');
      await prefs.remove('fcm_token');

      return {'success': true, 'message': 'Logout successful'};
    } else {
      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Logout failed'
      };
    }
  } catch (e) {
    return {'success': false, 'message': e.toString()};
  }
}

  static Future<Map<String, dynamic>> updateDealer({
  required String dealerId,
  String? companyName,
  String? phoneNumber,
  String? address,
  String? email,
  String? username,
  String? gstNumber,
  String? dealerType,
}) async {
  try {
    // Build request body only with provided fields
    final Map<String, dynamic> body = {};

    if (companyName != null && companyName.isNotEmpty) {
      body['companyName'] = companyName;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }
    if (address != null && address.isNotEmpty) {
      body['address'] = address;
    }
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }
    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }
    if (gstNumber != null && gstNumber.isNotEmpty) {
      body['gstNumber'] = gstNumber;
    }
    if (dealerType != null && dealerType.isNotEmpty) {
      body['dealerType'] = dealerType;
    }

    print("Updating dealer $dealerId with body: $body");

    final response = await ApiClient.put(
      '/api/dealer/$dealerId',
      body,
      auth: true,
    );

    print("Update dealer status: ${response.statusCode}");
    print("Update dealer body: ${response.body}");

    final decoded = jsonDecode(response.body);

    return {
      "success": response.statusCode == 200,
      "message": decoded["message"] ?? "Unknown response",
      "data": decoded["data"] ?? {},
    };
  } catch (e) {
    print("Update dealer exception: $e");

    return {
      "success": false,
      "message": e.toString(),
    };
  }
}


}
