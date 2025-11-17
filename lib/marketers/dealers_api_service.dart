import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DealerApiService {
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

  static Future<Map<String, dynamic>> registerDealer({
    required String companyName,
    required String phoneNumber,
    required String gstNumber,
    required String address,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      final gstToken = prefs.getString('gst_verification_token');

      if (authToken == null) {
        return {'success': false, 'message': 'Login required.'};
      }

      if (gstToken == null) {
        return {
          'success': false,
          'message': 'GST verification required before registration.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/register/dealer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          'gst-verification-token': gstToken,
        },
        body: jsonEncode({
          'companyName': companyName,
          'phoneNumber': phoneNumber,
          'gstNumber': gstNumber,
          'address': address,
          'email': email,
          'username': username,
          'password': password,
        }),
      );
      print('Response status of register dealer: ${response.statusCode}');
      print('Response body of register dealer: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Dealer registered successfully.',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to register dealer.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error registering dealer: $e'};
    }
  }


  static Future<Map<String, dynamic>> fetchDealers({
    String? search,
    String? approvalStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please log in again.',
        };
      }

      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (approvalStatus != null &&
          approvalStatus.isNotEmpty &&
          approvalStatus != 'all') {
        queryParams['approvalStatus'] = approvalStatus;
      }
      if (startDate != null && startDate.isNotEmpty)
        queryParams['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty)
        queryParams['endDate'] = endDate;

      final uri = Uri.parse(
        '$baseUrl/api/users/dealer',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final data = jsonDecode(response.body);
      print('🔹 Dealers API: ${response.statusCode}');
      print('🔹 Response: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'] ?? 0,
          'message': data['message'] ?? 'Dealers retrieved successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch dealers',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  static Future<Map<String, dynamic>> approveDealer(
    String dealerId,
    int dealerType,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please log in again.',
        };
      }

      final body = jsonEncode({"action": "approve", "dealerType": dealerType});

      final response = await http.patch(
        Uri.parse('$baseUrl/api/dealer/$dealerId'), // ✅ FIXED ENDPOINT
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: body,
      );
      print('Response status of approve dealer: ${response.statusCode}');
      print('Response body of approve dealer: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Dealer approved',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Approval failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  static Future<Map<String, dynamic>> rejectDealer(
    String dealerId,
    String reason,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please log in again.',
        };
      }

      final body = jsonEncode({"action": "reject", "reason": reason});

      final response = await http.patch(
        Uri.parse('$baseUrl/api/dealer/$dealerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: body,
      );
      print('Response status of reject dealer: ${response.statusCode}');
      print('Response body of reject dealer: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Dealer rejected',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Rejection failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  static Future<Map<String, dynamic>> setUserActiveStatus({
    required String dealerId,
    required bool isActive,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please log in again.',
        };
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/api/user/dealer/$dealerId'), // ✅ PATCH route
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'isActive': isActive}),
      );

      print('Response status of setUserActiveStatus: ${response.statusCode}');
      print('Response body of setUserActiveStatus: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Status updated successfully',
          'id': data['id'],
          'owner': data['companyName'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update status',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchActivities({
    String? role,
    String? actionType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again.',
        };
      }

      final Map<String, String> queryParams = {};

      if (role != null) queryParams['role'] = role;
      if (actionType != null) queryParams['actionType'] = actionType;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final uri = Uri.parse('$baseUrl/api/activity-logs')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final jsonBody = jsonDecode(response.body);

      print("📌 Activity Logs Response: ${response.statusCode}");
      print(jsonBody);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonBody['message'],
          'data': jsonBody['data'],       // All logs (array)
        };
      } else {
        return {
          'success': false,
          'message': jsonBody['message'] ?? 'Failed to load activities',
        };
      }
    } catch (err) {
      return {
        'success': false,
        'message': 'Server error: $err',
      };
    }
  }

  //  static Future<Map<String, dynamic>> fetchActivities({
  //   int page = 1,
  //   int limit = 20,
  //   String? role,
  //   String? actionType,
  //   String? startDate,
  //   String? endDate,
  // }) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final authToken = prefs.getString('auth_token');

  //     if (authToken == null) {
  //       return {
  //         'success': false,
  //         'message': 'Unauthorized. Please login again.',
  //       };
  //     }

  //     final queryParams = {
  //       'page': page.toString(),
  //       'limit': limit.toString(),
  //     };

  //     if (role != null) queryParams['role'] = role;
  //     if (actionType != null) queryParams['actionType'] = actionType;
  //     if (startDate != null) queryParams['startDate'] = startDate;
  //     if (endDate != null) queryParams['endDate'] = endDate;

  //     final uri = Uri.parse('$baseUrl/api/activity-logs').replace(queryParameters: queryParams);

  //     final response = await http.get(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $authToken',
  //       },
  //     );

  //     final json = jsonDecode(response.body);

  //     print('📌 Activity Logs Response: ${response.statusCode}');
  //     print(json);

  //     if (response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'message': json['message'],
  //         'data': json['data'],
  //         'pagination': json['pagination'],
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'message': json['message'] ?? 'Failed to load activities',
  //       };
  //     }
  //   } catch (err) {
  //     return {
  //       'success': false,
  //       'message': 'Server error: $err',
  //     };
  //   }
  // }
}
