//pending need to go with checkout and payment api integration!

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../storage/secure_storage.dart';

// class CheckoutPaymentService {
//   static Future<Map<String, dynamic>> checkout(
//     Map<String, dynamic> requestBody,
//   ) async {
//     final token = await SecureStorage.getToken();

//     if (token == null || token.isEmpty) {
//       throw Exception('Authentication token is missing. Please log in again.');
//     }

//     try {
//       final response = await ApiClient.post(
//         '/api/checkout',
//         requestBody,
//         auth: true,
//       );

//       debugPrint('Checkout Request Body: $requestBody');
//       debugPrint('Checkout Response Code: ${response.statusCode}');
//       debugPrint('Checkout Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body) as Map<String, dynamic>;
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception('Checkout failed: ${error['message']}');
//       }
//     } catch (e) {
//       debugPrint('Checkout error: $e');
//       throw Exception('An error occurred during checkout: $e');
//     }
//   }

//   /// 💳 Confirm Razorpay Payment
//   static Future<bool> confirmPayment({
//     required String razorpayOrderId,
//     required String razorpayPaymentId,
//     required String razorpaySignature,
//   }) async {
//     final token = await SecureStorage.getToken();

//     if (token == null || token.isEmpty) {
//       throw Exception('Authentication token is missing. Please log in again.');
//     }

//     if (razorpayOrderId.isEmpty ||
//         razorpayPaymentId.isEmpty ||
//         razorpaySignature.isEmpty) {
//       throw Exception('Invalid payment details received.');
//     }

//     try {
//       final response = await ApiClient.post(
//         '/api/orders/confirm-payment',
//         {
//           'razorpayOrderId': razorpayOrderId,
//           'razorpayPaymentId': razorpayPaymentId,
//           'razorpaySignature': razorpaySignature,
//         },
//         auth: true,
//       );

//       debugPrint('Confirm Payment Response Code: ${response.statusCode}');
//       debugPrint('Confirm Payment Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         throw Exception(
//           'Failed to confirm payment: ${response.statusCode} - ${response.body}',
//         );
//       }
//     } catch (e) {
//       debugPrint('Error in confirmPayment: $e');
//       throw Exception('An error occurred while confirming the payment: $e');
//     }
//   }
// }


class CheckoutPaymentService {
  static Future<Map<String, dynamic>> checkout(Map<String, dynamic> requestBody) async {
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    try {
      final response = await ApiClient.post(
        '/api/checkout',
        requestBody,
        auth: true,
      );

      debugPrint('Checkout Request Body: $requestBody');
      debugPrint('Checkout Response Code: ${response.statusCode}');
      debugPrint('Checkout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        // Extract important info for frontend
        final orderId = result['order']['_id'];
        final razorpayOrderId = result['order']['paymentDetails']?['razorpayOrderId'];
        final keyId = result['key_id'];
        return {
          'orderId': orderId,
          'razorpayOrderId': razorpayOrderId,
          'keyId': keyId,
          'raw': result,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Checkout failed: ${error['message']}');
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      throw Exception('An error occurred during checkout: $e');
    }
  }
static Future<bool> confirmPayment({
  required String razorpayOrderId,
  required String razorpayPaymentId,
  required String razorpaySignature,
}) async {
  final token = await SecureStorage.getToken();
  if (token == null || token.isEmpty) {
    throw Exception('Authentication token is missing.');
  }

  final response = await ApiClient.post(
    '/api/orders/confirm-payment',
    {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    },
    auth: true,
  );

  if (response.statusCode == 200) {
    return true; // ✅ Return bool
  } else {
    throw Exception(
        'Failed to confirm payment: ${response.statusCode} - ${response.body}');
  }
}

}
