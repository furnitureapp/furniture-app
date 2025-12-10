import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:furniture_ecom_app/marketers/models/activity.dart';
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

// static Future<Map<String, dynamic>> getDealerStatus() async {
//   final prefs = await SharedPreferences.getInstance();
//   final email = prefs.getString("dealer_email");
//   final username = prefs.getString("dealer_username");

//   if (email == null && username == null) {
//     throw Exception("Dealer identity not found");
//   }

//   final uri = Uri.parse(
//     email != null
//         ? "$baseUrl/api/users/dealerstatus?email=$email"
//         : "$baseUrl/api/users/dealerstatus?username=$username",
//   );

//   final response = await http.get(uri);
//    print('🔹 Dealers API status check: ${response.statusCode}');
//       print('🔹 Response of status check: ${response.body}');

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     throw Exception("Failed to fetch dealer status");
//   }
// }

static Future<Map<String, dynamic>> getDealerStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString("pending_email");

  if (email == null) {
    throw Exception("Pending dealer email not found");
  }

  final uri = Uri.parse(
    "$baseUrl/api/users/dealerstatus?email=$email",
  );

  final response = await http.get(uri);

  print('🔹 Dealer status check api: ${response.statusCode}');
  print('🔹 Dealer status response body: ${response.body}');

   if (response.statusCode != 200) {
      throw Exception("Failed to fetch dealer status");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || decoded["data"] == null) {
      throw Exception("Invalid dealer status response");
    }

    return decoded;
  }


  static Future<Map<String, dynamic>> selfregisterDealer({
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
      // final authToken = prefs.getString('auth_token') ?? '';
      final gstToken = prefs.getString('gst_verification_token') ?? '';

      // if (authToken.isEmpty) {
      //   return {'success': false, 'message': 'Login required.'};
      // }

      if (gstToken.isEmpty) {
        return {
          'success': false,
          'message': 'GST verification required before registration.',
        };
      }

      final resp = await http.post(
        Uri.parse('$baseUrl/api/register/dealer'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $authToken',
          // 'gst-verification-token': gstToken,
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

      debugPrint('Response status of register dealer: ${resp.statusCode}');
      debugPrint(resp.body, wrapWidth: 1024);

      final Map<String, dynamic> body = jsonDecode(resp.body);

      if (resp.statusCode == 201 || (body['success'] == true)) {
        // Optionally return created dealer data
        final dealerData = body['data'] != null
            ? DealerModel.fromJson(body['data'])
            : null;
        return {
          'success': true,
          'message': body['message'] ?? 'Dealer registered successfully.',
          'data': dealerData,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to register dealer.',
          'body': body,
        };
      }
    } catch (e, st) {
      debugPrint('registerDealer error: $e\n$st');
      return {'success': false, 'message': 'Error registering dealer: $e'};
    }
  }


  static Future<Map<String, dynamic>> registerDealerbyMarketer({
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
      final authToken = prefs.getString('auth_token') ?? '';
      final gstToken = prefs.getString('gst_verification_token') ?? '';

      if (authToken.isEmpty) {
        return {'success': false, 'message': 'Login required.'};
      }

      if (gstToken.isEmpty) {
        return {
          'success': false,
          'message': 'GST verification required before registration.',
        };
      }

      final resp = await http.post(
        Uri.parse('$baseUrl/api/register/dealer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
          // 'gst-verification-token': gstToken,
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

      debugPrint('Response status of register dealer: ${resp.statusCode}');
      debugPrint(resp.body, wrapWidth: 1024);

      final Map<String, dynamic> body = jsonDecode(resp.body);

      if (resp.statusCode == 201 || (body['success'] == true)) {
        // Optionally return created dealer data
        final dealerData = body['data'] != null
            ? DealerModel.fromJson(body['data'])
            : null;
        return {
          'success': true,
          'message': body['message'] ?? 'Dealer registered successfully.',
          'data': dealerData,
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to register dealer.',
          'body': body,
        };
      }
    } catch (e, st) {
      debugPrint('registerDealer error: $e\n$st');
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
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

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
  int page = 1,
  int limit = 20,
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

    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (role != null && role != 'All') queryParams['role'] = role;
    if (actionType != null && actionType != 'All') queryParams['actionType'] = actionType;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/api/activity-logs')
        .replace(queryParameters: queryParams);

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
        'data': jsonBody['data'],
        'pagination': jsonBody['pagination'],
      };
    } else {
      return {
        'success': false,
        'message': jsonBody['message'] ?? 'Failed to load activities',
      };
    }
  } catch (err) {
    return {'success': false, 'message': 'Server error: $err'};
  }
}

  static Future<Map<String, dynamic>> fetchDealersManagers({
    String? search,
    String? approvalStatus,
    String? startDate,
    String? endDate,
    String? createdByFilter, // 👈 NEW FILTER (all, admin, marketer)
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

      // 🔍 Search
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // ✔ Approval Status
      if (approvalStatus != null &&
          approvalStatus.isNotEmpty &&
          approvalStatus != 'all') {
        queryParams['approvalStatus'] = approvalStatus;
      }

      // 📅 Start date
      if (startDate != null && startDate.isNotEmpty) {
        queryParams['startDate'] = startDate;
      }

      // 📅 End date
      if (endDate != null && endDate.isNotEmpty) {
        queryParams['endDate'] = endDate;
      }

      // 👤 NEW — Created By filter (Admin / Marketer / All)
      if (createdByFilter != null &&
          createdByFilter.isNotEmpty &&
          createdByFilter.toLowerCase() != 'all') {
        queryParams['role'] = createdByFilter.toLowerCase();
      }

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

      print('🔹 Dealers API by Manager: ${response.statusCode}');
      print('🔹 Response by Manager: ${response.body}');

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
}
