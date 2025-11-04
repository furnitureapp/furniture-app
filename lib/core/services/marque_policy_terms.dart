import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/api/api_client.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';

class MarqueePolicyTermsService {
  static Future<Marquees?> fetchMarquee() async {
    try {
      final response = await ApiClient.get('/api/marquee');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['marquee'] != null) {
          return Marquees.fromJson(data['marquee']);
        } else {
          debugPrint('No marquee data found.');
        }
      } else {
        debugPrint('Failed to load marquee: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching marquee: $e');
      throw Exception('Error fetching marquee: $e');
    }
    return null;
  }

  static Future<String> fetchPrivacyPolicy() async {
    try {
      final response = await ApiClient.get('/api/policy/privacy');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Privacy Policy Data: $data");

        return data['policy']?['content'] ?? "No content available";
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch privacy policy',
        );
      }
    } catch (error) {
      debugPrint('Error fetching privacy policy: $error');
      throw Exception('Error fetching privacy policy: $error');
    }
  }

  static Future<String> fetchTermsPolicy() async {
    try {
      final response = await ApiClient.get('/api/policy/terms');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Terms Policy Data: $data");

        return data['policy']?['content'] ?? "No content available";
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch terms policy');
      }
    } catch (error) {
      debugPrint('Error Fetching Terms Policy: $error');
      throw Exception('Error fetching terms policy: $error');
    }
  }
}
