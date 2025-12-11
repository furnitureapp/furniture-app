import 'dart:convert';
import '../api_management_service/api_client.dart';
import '../models_ecom/model_file.dart';

class CatSubBannersService {
  static Future<List<BannerModel>> fetchBanners() async {
    final response = await ApiClient.get('/api/getbanner');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List bannersJson = data['banners'];
      return bannersJson.map((json) => BannerModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load banners');
    }
  }

  static Future<List<Categorys>> fetchCategories() async {
    final response = await ApiClient.get('/api/getallc');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['categories'] as List)
            .map((category) => Categorys.fromJson(category))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } else {
      throw Exception('Failed to connect to the API');
    }
  }

  static Future<List<SubCategory>> fetchSubCategories(String categoryId) async {
    final response = await ApiClient.get('/api/getsubc/$categoryId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return (data['subCategories'] as List)
            .map((subcategory) => SubCategory.fromJson(subcategory))
            .toList();
      } else {
        throw Exception('No subcategories found');
      }
    } else {
      throw Exception('Failed to load subcategories');
    }
  }
}
