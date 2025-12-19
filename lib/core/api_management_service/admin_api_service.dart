import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:furniture_ecom_app/core/api_management_service/dealers_api_service.dart';
import 'package:furniture_ecom_app/core/models_ecom/orders_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApiService {
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

  static Future<Map<String, dynamic>> fetchAdmins({
    String? search,
    String? role,
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

      // Build query params
      final queryParams = <String, String>{};

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (role != null && role.isNotEmpty && role != 'all') {
        queryParams['role'] = role;
      }

      // Build URI
      final uri = Uri.parse(
        '$baseUrl/api/users/admin',
      ).replace(queryParameters: queryParams);

      // Make request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final data = jsonDecode(response.body);

      print("🔹 Admin API: ${response.statusCode}");
      print("🔹 Response: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'] ?? 0,
          'message': data['message'] ?? 'Admins retrieved successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch admins',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchMarketers({
    String? search,
    String? role,
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

      // ------------ QUERY PARAMETERS -------------
      final queryParams = <String, String>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (role != null && role.isNotEmpty && role.toLowerCase() != "all") {
        queryParams['role'] = role.trim();
      }

      final uri = Uri.parse(
        '$baseUrl/api/users/marketer',
      ).replace(queryParameters: queryParams);

      print("🔹 MARKETER API URL: $uri");

      // ------------ API CALL -------------
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final data = jsonDecode(response.body);

      print('🔹 Marketers API Status: ${response.statusCode}');
      print('🔹 Response: ${response.body}');

      // ------------ SUCCESS RESPONSE -------------
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'count': data['count'] ?? 0,
          'message': data['message'] ?? 'Marketers retrieved successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch marketers',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  static Future<OrderResponse> fetchOrders({
    String? status,
    String? dealerId,
    String? paymentMethod,
    String? productId,
    String? search,
    String? filterType,
    String? specificDate,
    String? fromDate,
    String? toDate,
    double? minTotal,
    double? maxTotal,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception("Unauthorized. Please log in.");
      }

      // ------------------- QUERY PARAMS -------------------
      final Map<String, String> params = {
        if (status != null) "status": status,
        if (dealerId != null) "dealerId": dealerId,
        if (paymentMethod != null) "paymentMethod": paymentMethod,
        if (productId != null) "productId": productId,
        if (search != null && search.isNotEmpty) "search": search,
        if (filterType != null) "filterType": filterType,
        if (specificDate != null) "specificDate": specificDate,
        if (fromDate != null) "fromDate": fromDate,
        if (toDate != null) "toDate": toDate,
        if (minTotal != null) "minTotal": minTotal.toString(),
        if (maxTotal != null) "maxTotal": maxTotal.toString(),
        if (sortBy != null) "sortBy": sortBy,
        if (sortOrder != null) "sortOrder": sortOrder,
      };

      // ------------------- FIXED URL -------------------
      final uri = Uri.parse(
        '$baseUrl/api/admin/orders',
      ).replace(queryParameters: params);

      print("🔹 ORDERS API URL: $uri");

      // ------------------- API CALL -------------------
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('🔹 manager API Status orders: ${response.statusCode}');
      print('🔹 Response of orders: ${response.body}');

      if (response.statusCode == 200) {
        return OrderResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load orders: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching orders: $e");
    }
  }

  static Future<Map<String, dynamic>> fetchDashboardCounts() async {
    try {
      final ordersResponse = await AdminApiService.fetchOrders();

      final List orders = ordersResponse.orders;
    
      int placed = 0;
      int shipped = 0;
      int delivered = 0;
      int cancelled = 0;

      for (var o in orders) {
        switch (o.status?.toLowerCase()) {
          case "placed":
            placed++;
            break;
          case "shipped":
            shipped++;
            break;
          case "delivered":
            delivered++;
            break;
          case "cancelled":
            cancelled++;
            break;
        }
      }

      final int totalOrders = ordersResponse.totalOrders;
      final double totalrevenue = ordersResponse.overallDealerOrderAmount;
      final adminsResponse = await AdminApiService.fetchAdmins();
      final int adminCount = adminsResponse['count'] ?? 0;
      final marketersResponse = await AdminApiService.fetchMarketers();
      final int marketerCount = marketersResponse['count'] ?? 0;
      final dealersResponse = await DealerApiService.fetchDealers();
      final int dealerCount = dealersResponse['count'] ?? 0;
      final managerresponse = await AdminApiService.fetchManagers();
      final int managercount = managerresponse['count'] ?? 0;


      return {
        "success": true,
        "totalOrders": totalOrders,
        "placed": placed,
        "shipped": shipped,
        "delivered": delivered,
        "cancelled": cancelled,
        "adminCount": adminCount,
        "marketerCount": marketerCount,
        "dealerCount": dealerCount,
        "managercount": managercount,
        "totalrevenue": totalrevenue,
      };
  
    } catch (e) {
      return {
        "success": false,
        "message": "Error loading dashboard counts: $e",
      };
    }
  }

static Future<Map<String, dynamic>> fetchManagers({
  String? search,
  String? role,
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

    // Build query params
    final queryParams = <String, String>{};

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    if (role != null && role.isNotEmpty && role != 'all') {
      queryParams['role'] = role;
    }

    // Build URI
    final uri = Uri.parse(
      '$baseUrl/api/users/manager',
    ).replace(queryParameters: queryParams);

    // Make request
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    final data = jsonDecode(response.body);

    print("🔹 Admin API: ${response.statusCode}");
    print("🔹 Response: ${response.body}");

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': data['managers'] ?? [],   
        'count': data['count'] ?? 0,
        'message': data['message'] ?? 'Managers retrieved successfully',
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch managers',
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Server error: $e'};
  }
}

}
