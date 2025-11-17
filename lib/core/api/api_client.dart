import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:furniture_ecom_app/core/storage/secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['WEB_URL'] ?? 'https://furniture-app-ruby.vercel.app';
    } else if (Platform.isAndroid) {
      return dotenv.env['ANDROID_URL'] ??
          'https://furniture-app-ruby.vercel.app';
    } else if (Platform.isIOS) {
      return dotenv.env['IOS_URL'] ?? 'https://furniture-app-ruby.vercel.app';
    } else {
      return dotenv.env['DESKTOP_URL'] ??
          'https://furniture-app-ruby.vercel.app';    }
  }

  static Future<Map<String, String>> _headers({
    bool withAuth = false,
    String? contentType,
  }) async {
    final headers = <String, String>{
      'Content-Type': contentType ?? 'application/json',
    };
    if (withAuth) {
      final token = await SecureStorage.readToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    bool auth = false,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    return http.get(uri, headers: await _headers(withAuth: auth));
  }

  static Future<http.Response> post(
    String endpoint,
    Map data, {
    bool auth = false,
    String? contentType,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return http.post(
      uri,
      headers: await _headers(withAuth: auth, contentType: contentType),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> put(
    String endpoint,
    Map data, {
    bool auth = false,
    String? contentType,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return http.put(
      uri,
      headers: await _headers(withAuth: auth, contentType: contentType),
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    bool auth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return http.delete(uri, headers: await _headers(withAuth: auth));
  }
}


// https://krishnan-admin-plzh.vercel.app