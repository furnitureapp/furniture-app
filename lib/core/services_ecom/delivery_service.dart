import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api_management_service/api_client.dart';
import '../models_ecom/model_file.dart';
import '../storage/secure_storage.dart';

class DeliveryService {

static Future<List<Map<String, dynamic>>> mygetDeliveryDetails() async {
  final token = await SecureStorage.getToken();

  if (token == null || token.isEmpty) {
    return [];
  }

  try {
    final response = await ApiClient.get(
      '/api/dealerget',
      auth: true,
    );

    debugPrint('Get Delivery Status: ${response.statusCode}');
    debugPrint('Get Delivery Body: ${response.body}');

    // ✅ Backend returns 404 when empty
    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode == 200) {
      final List<dynamic> deliveries = jsonDecode(response.body);

      final List<Map<String, dynamic>> allItems = [];

      for (final delivery in deliveries) {
        if (delivery is Map<String, dynamic>) {
          final items = delivery['items'] as List<dynamic>? ?? [];

          for (final item in items) {
            if (item is Map<String, dynamic>) {
              allItems.add(item);
            }
          }
        }
      }

      return allItems;
    }

    throw Exception('Failed to load delivery details');
  } catch (e) {
    debugPrint('mygetDeliveryDetails Error: $e');
    rethrow;
  }
}


static Future<Map<String, dynamic>> createDelivery({
  required String dealername,
  required String phoneNo,
  required String houseNo,
  required String streetName,
  required String city,
  required String state,
  required String pinCode,
}) async {
  final token = await SecureStorage.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Authentication token is missing.');
  }

  try {
    final response = await ApiClient.post(
      '/api/create',
      {
        'dealername': dealername,
        'phoneNo': phoneNo,
        'houseNo': houseNo,
        'streetName': streetName,
        'city': city,
        'state': state,
        'pinCode': pinCode,
      },
      auth: true,
    );

    debugPrint('Create Delivery Status: ${response.statusCode}');
    debugPrint('Create Delivery Body: ${response.body}');

    final Map<String, dynamic> decoded = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'message': decoded['message'],
        'delivery': decoded['delivery'],
      };
    }

    throw Exception(decoded['message'] ?? 'Failed to create delivery');
  } catch (e) {
    debugPrint('createDelivery Error: $e');
    rethrow;
  }
}

static Future<Map<String, dynamic>> myupdateDelivery({
  required String deliveryId, // ✅ items[]. _id
  required String dealername,
  required String phoneNo,
  required String houseNo,
  required String streetName,
  required String city,
  required String state,
  required String pinCode,
}) async {
  final token = await SecureStorage.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Authentication token is missing.');
  }

  try {
    final response = await ApiClient.put(
      '/api/delivery',
      {
        'deliveryId': deliveryId,
        'dealername': dealername,
        'phoneNo': phoneNo,
        'houseNo': houseNo,
        'streetName': streetName,
        'city': city,
        'state': state,
        'pinCode': pinCode,
      },
      auth: true,
    );

    debugPrint('Update Delivery Status: ${response.statusCode}');
    debugPrint('Update Delivery Body: ${response.body}');

    final Map<String, dynamic> decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'message': decoded['message'],
        'delivery': decoded['delivery'],
      };
    }

    throw Exception(decoded['message'] ?? 'Failed to update delivery');
  } catch (e) {
    debugPrint('myupdateDelivery Error: $e');
    rethrow;
  }
}

  static Future<Map<String, dynamic>> editUserDetailsByEmail({
    required String email,
    String? username,
    String? address,
    String? phoneNo,
  }) async {
    await SecureStorage.getToken();

    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (address != null) body['address'] = address;
    if (phoneNo != null) body['phoneNo'] = phoneNo;

    try {
      final response = await ApiClient.put('/api/edit/$email', body, auth: true);

      debugPrint('EDIT RESPONSE: ${response.statusCode} ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      debugPrint('editUserDetailsByEmail Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Marquees?> fetchMarquee() async {
    try {
      final response = await ApiClient.get('/api/marquee');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['marquee'] != null) {
          return Marquees.fromJson(data['marquee']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('fetchMarquee Error: $e');
      return null;
    }
  }
}




// static Future<List<Map<String, dynamic>>> mygetDeliveryDetails() async {
//   final token = await SecureStorage.getToken();

//   if (token == null || token.isEmpty) {
//     return [];
//   }

//   try {
//     final response = await ApiClient.get(
//       '/api/dealerget',
//       auth: true,
//     );

//     debugPrint('Get Delivery Status: ${response.statusCode}');
//     debugPrint('Get Delivery Body: ${response.body}');

//     // ✅ No deliveries
//     if (response.statusCode == 404) {
//       return [];
//     }

//     if (response.statusCode == 200) {
//       final List<dynamic> deliveries = jsonDecode(response.body);

//       // Flatten all items from all deliveries
//       final List<Map<String, dynamic>> allItems = [];

//       for (final delivery in deliveries) {
//         if (delivery is Map<String, dynamic> &&
//             delivery.containsKey('items')) {
//           final List<dynamic> items = delivery['items'];
//           allItems.addAll(
//             List<Map<String, dynamic>>.from(items),
//           );
//         }
//       }

//       return allItems;
//     } else {
//       throw Exception(
//         'Failed to load delivery details',
//       );
//     }
//   } catch (e) {
//     debugPrint('mygetDeliveryDetails Error: $e');
//     rethrow;
//   }
// }

//   static Future<Map<String, dynamic>> myupdateDelivery({
//   required String deliveryId,
//   required String dealername,
//   required String phoneNo,
//   required String houseNo,
//   required String streetName,
//   required String city,
//   required String state,
//   required String pinCode,
// }) async {
//   final token = await SecureStorage.getToken();

//   if (token == null || token.isEmpty) {
//     throw Exception('Authentication token is missing. Please log in again.');
//   }

//   try {
//     final response = await ApiClient.put(
//       '/api/delivery',
//       {
//         'deliveryId': deliveryId,
//         'dealername': dealername,
//         'phoneNo': phoneNo,
//         'houseNo': houseNo,
//         'streetName': streetName,
//         'city': city,
//         'state': state,
//         'pinCode': pinCode,
//       },
//       auth: true,
//     );

//     debugPrint('Update Delivery Status: ${response.statusCode}');
//     debugPrint('Update Delivery Body: ${response.body}');

//     final Map<String, dynamic> data = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return data; // contains message + delivery
//     }

//     if (response.statusCode == 400 || response.statusCode == 404) {
//       throw Exception(data['message'] ?? 'Request failed');
//     }

//     throw Exception(
//       'Failed to update delivery',
//     );
//   } catch (e) {
//     debugPrint('myupdateDelivery Error: $e');
//     rethrow;
//   }
// }

// static Future<Map<String, dynamic>> createDelivery({
//   required String dealername,
//   required String phoneNo,
//   required String houseNo,
//   required String streetName,
//   required String city,
//   required String state,
//   required String pinCode,
// }) async {
//   final token = await SecureStorage.getToken();

//   if (token == null || token.isEmpty) {
//     throw Exception('Authentication token is missing. Please log in again.');
//   }

//   try {
//     final response = await ApiClient.post(
//       '/api/create',
//       {
//         'dealername': dealername,
//         'phoneNo': phoneNo,
//         'houseNo': houseNo,
//         'streetName': streetName,
//         'city': city,
//         'state': state,
//         'pinCode': pinCode,
//       },
//       auth: true, // ✅ required for req.user.id
//     );

//     debugPrint('Response status: ${response.statusCode}');
//     debugPrint('Response body: ${response.body}');

//     final decoded = jsonDecode(response.body);

//     if (response.statusCode == 201) {
//       return decoded; // contains message + delivery
//     } else {
//       throw Exception(
//         decoded['message'] ?? 'Failed to create delivery',
//       );
//     }
//   } catch (e) {
//     debugPrint('createDelivery Error: $e');
//     rethrow;
//   }
// }

