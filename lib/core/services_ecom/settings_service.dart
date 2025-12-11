import 'dart:convert';
import '../api_management_service/api_client.dart';
import '../models_ecom/model_file.dart';

class SettingsService {
  static Future<Map<String, dynamic>> getSettings() async {
    final response = await ApiClient.get('/api/settings');
    if (response.statusCode == 200) {
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch settings');
    }
  }

  static Future<ShopSettings?> fetchShopSettings() async {
    final response = await ApiClient.get('/api/shop-settings');
    if (response.statusCode == 200) {
      print("Status of fetch shop settings: ${response.statusCode}");
      print("Body of fetch shop settings: ${response.body}");
      return ShopSettings.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
