import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_management_service/api_client.dart';

class InvoiceDetailsService {
  static Future<Map<String, dynamic>> downloadInvoice(String orderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) { 
        return {'success': false, 'message': 'Authentication token not found'};
      }

      final response = await ApiClient.get(
        '/api/order/invoice/$orderId',
        auth: true,
      );

      debugPrint('Invoice Download Response Code: ${response.statusCode}');
            debugPrint('Invoice Download Response Code: ${response.body}');


      if (response.statusCode == 200) {
        try {
          final directory = await _getDownloadsDirectory();
          final filePath = '${directory.path}/invoice_$orderId.pdf';
          final file = File(filePath);

          await file.writeAsBytes(response.bodyBytes);

          return {
            'success': true,
            'message': 'Invoice downloaded successfully.',
            'filePath': filePath,
          };
        } catch (e) {
          debugPrint('File save error: $e');
          return {
            'success': true,
            'message': 'Invoice downloaded successfully (no file path available)',
          };
        }
      } else if (response.statusCode == 403) {
        await prefs.clear();
        return {
          'success': false,
          'message': 'Session expired. Please log in again.',
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to download invoice',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Unexpected response while downloading invoice.',
          };
        }
      }
    } catch (error) {
      debugPrint('Download failed: $error');
      return {'success': false, 'message': 'Download failed: $error'};
    }
  }

  static Future<Directory> _getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        return Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      } else {
        // desktop/web fallback
        return await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      debugPrint('Error accessing download directory: $e');
      return await getTemporaryDirectory();
    }
  }
}
