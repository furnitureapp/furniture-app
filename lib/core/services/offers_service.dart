import 'dart:convert';
import '../api/api_client.dart';
import '../model/model_file.dart';

class OfferService {
  static Future<List<Offer>> fetchOffers() async {
    final response = await ApiClient.get('/api/offers');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final offers = data['offers'] as List;
      return offers.map((offer) => Offer.fromJson(offer)).toList();
    } else {
      throw Exception('Failed to load offers: ${response.statusCode}');
    }
  }

  static Future<List<Offer>> fetchOfferProductsAsOffers() async {
    final response = await ApiClient.get('/api/offers');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final offers = data['offers'] as List;
      return offers.map((offerJson) => Offer.fromJson(offerJson)).toList();
    } else {
      throw Exception('Failed to load offers: ${response.statusCode}');
    }
  }

  static Future<List<double>> fetchOnlyOfferPrices(String orderId) async {
    final response = await ApiClient.get('/api/orders/history/$orderId', auth: true);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['order']['items'] as List<dynamic>;

      return items
          .map<double>((item) => (item['offerPrice'] as num).toDouble())
          .toList();
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch order details');
    }
  }
}
