import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://krishnan-admin-plzh.vercel.app';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'https://krishnan-admin-plzh.vercel.app';
    } else {
      return 'https://krishnan-admin-plzh.vercel.app';
    }
  }

  static Future<dynamic> register(
      String email,
      String username,
      String password,
      String confirmPassword,
      String phoneNo,
      String address) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNo': phoneNo,
        'address': address
      }),
    );

    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'success': true, 'message': 'Registration successful'};
    } else {
      return {
        'success': false,
        'message': decoded['error'] ?? 'Registration failed'
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        return {'success': false, 'message': 'Failed to retrieve FCM token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
          'platform': Platform.isAndroid ? 'mobile' : 'web',
        }),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        final user = responseData['user'];
        final prefs = await SharedPreferences.getInstance();

        // if (user != null) {
        //   await prefs.setString('user_email', user['email']);
        // }
        if (user != null) {
          await prefs.setString('user_email', user['email']);
          await prefs.setString('username', user['username'] ?? '');
          await prefs.setString('phoneNo', user['phoneNo'] ?? '');
          await prefs.setString('address', user['address'] ?? '');
        }

        await prefs.setString('fcm_token', fcmToken);

        return {'success': true, 'message': 'Login successful', 'user': user};
      } else {
        String errorMsg = responseData['error'] ?? 'Login failed';
        return {'success': false, 'message': errorMsg};
      }
    } catch (error) {
      return {'success': false, 'message': 'Login failed: $error'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    final url = Uri.parse('$baseUrl/api/verify-otp');
    final body = jsonEncode({'email': email, 'otp': otp});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        return {
          'success': true,
          'message': 'OTP verified successfully',
          'token': data['token']
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'Invalid OTP!'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to verify OTP: $error'};
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse('$baseUrl/api/resend-otp');
    final body = jsonEncode({'email': email});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': ' ✅ New OTP sent successfully!'};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to resend OTP!'
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to resend OTP: $error'};
    }
  }

  // static Future<Map<String, dynamic>> forgotPassword(String email) async {
  //   final url = Uri.parse('$baseUrl/api/forgot-password');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'email': email}),
  //     );

  //     final Map<String, dynamic> responseData = jsonDecode(response.body);
  //     if (response.statusCode == 200) {
  //       return {'success': true, 'message': responseData['message']};
  //     } else {
  //       return {'success': false, 'message': responseData['message']};
  //     }
  //   } catch (error) {
  //     return {'success': false, 'message': 'Failed to send reset email'};
  //   }
  // }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent to your email'
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Something went wrong'
        };
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to send reset email'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String otp, String newPassword, String confirmNewPassword) async {
    final url = Uri.parse('$baseUrl/api/reset-password');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'otp': otp,
            'newPassword': newPassword,
            'confirmNewPassword': confirmNewPassword
          }));
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {'success': false, 'message': responseData['message']};
      }
    } catch (error) {
      return {'success': false, 'message': 'Failed to send reset email'};
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/getprofile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['user'] == null || data['user']['email'] == null) {
          throw Exception('User data is missing');
        }

        return data['user'];
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access - Invalid token');
      } else {
        throw Exception('Failed to load profile: ${response.reasonPhrase}');
      }
    } catch (error) {
      return null;
    }
  }

  // Future<List<String>> fetchBannerImages() async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/api/getbanner'));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       List<String> images = List<String>.from(data['banner']['images']);
  //       return images;
  //     } else {
  //       throw Exception('Failed to load banner images');
  //     }
  //   } catch (e) {
  //     throw Exception('Error: $e');
  //   }
  // }

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/getbanner'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List bannersJson = data['banners'];
        return bannersJson.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banners');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/api/getallc"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['categories'] as List)
            .map((category) => Category.fromJson(category))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } else {
      throw Exception('Failed to connect to the API');
    }
  }

  static Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(Uri.parse("$baseUrl/api/getallp"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('API Response: ${response.body}');

      if (data['success'] == true && data.containsKey('products')) {
        return (data['products'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception(
            'No products found or API returned unexpected response');
      }
    } else {
      throw Exception(
          'Failed to connect to the API (status code: ${response.statusCode})');
    }
  }

  Future<List<SubCategory>> fetchSubCategories(String categoryId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/api/getsubc/$categoryId"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
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

  static Future<List<Product>> fetchProducts(String subCategoryId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/getproduct/$subCategoryId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productList = data['products'];
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<Product>> getRelatedProducts(String productId) async {
    final url = Uri.parse('$baseUrl/api/productlist/$productId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['relatedProducts'] as List)
            .map((product) => Product.fromJson(product))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to fetch related products');
    }
  }

  Future<List<Offer>> fetchOffers() async {
    final url = Uri.parse('$baseUrl/api/offers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final offers = data['offers'] as List;
      return offers.map((offer) => Offer.fromJson(offer)).toList();
    } else {
      throw Exception('Failed to load offers: ${response.statusCode}');
    }
  }

  static Future<List<Offer>> fetchOfferProductsAsOffers() async {
    final url = Uri.parse('$baseUrl/api/offers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final offers = data['offers'] as List;

      return offers.map((offerJson) {
        return Offer.fromJson(offerJson);
      }).toList();
    } else {
      throw Exception('Failed to load offers: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> searchProductss(String query) async {
    final String url = '$baseUrl/api/search?title=$query';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('search result Response: ${response.body}');
        List<dynamic> allProducts = [];

        if (data.containsKey('products')) {
          allProducts.addAll(data['products']);
        }

        if (data.containsKey('subcategories')) {
          for (var sub in data['subcategories']) {
            if (sub.containsKey('products')) {
              allProducts.addAll(sub['products']);
            }
          }
        }

        if (data.containsKey('categories')) {
          for (var cat in data['categories']) {
            if (cat.containsKey('products')) {
              allProducts.addAll(cat['products']);
            }
          }
        }

        return allProducts;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

//   Future<List<RelatedProducts>> searchWithRelated(String query) async {
//   final url = Uri.parse('$baseUrl/api/products/searchwithrelated?title=$query');
//   final response = await http.get(url);

//   if (response.statusCode == 200) {
//     final List<dynamic> jsonData = json.decode(response.body);
//    print(response.body);
//     return jsonData.map((item) => RelatedProducts.fromJson(item)).toList();
//   } else {
//     throw Exception('Failed to load related products');
//   }
// }

  static Future<List<Product>> searchWithRelated(String query) async {
    final url = Uri.parse('$baseUrl/api/search-with-related?title=$query');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(response.body);

      if (response.statusCode == 200) {
        // ✅ Handle 'products'
        if (jsonResponse.containsKey('products')) {
          return (jsonResponse['products'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
        }

        if (jsonResponse.containsKey('multipleProducts')) {
          return (jsonResponse['multipleProducts'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
        } else if (jsonResponse.containsKey('product')) {
          final productData = jsonResponse['product'];

          final Product mainProduct = Product.fromJson(productData['product']);

          final List<Product> relatedProducts = [];

          if (productData['related'] != null &&
              productData['related']['similarStartingLetter'] != null) {
            relatedProducts.addAll(
              (productData['related']['similarStartingLetter'] as List)
                  .map((e) => Product.fromJson(e))
                  .toList(),
            );
          }

          return [mainProduct, ...relatedProducts];
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch search results.');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      throw Exception('Something went wrong while searching.');
    }
  }

  Future<List<Product>> searchProductsWithRelated(String title) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/search-with-related?title=${Uri.encodeQueryComponent(title)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['products'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
        return products;
      } else if (response.statusCode == 400) {
        throw Exception('Title query parameter is required');
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token not found'};
      }
      final String? email = prefs.getString('user_email');
      final String? fcmToken = prefs.getString('fcm_token');

      if (email == null || fcmToken == null) {
        return {'success': false, 'message': 'User data missing'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'fcmToken': fcmToken,
        }),
      );
      log('Logout Response: ${response.body}');
      log('Logout Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        // await prefs.remove('auth_token');
        // await prefs.remove('user_email');
        // await prefs.remove('fcm_token');
        // await prefs.remove('wishlist');

        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['error'] ?? 'Failed to log out'
        };
      }
    } catch (error) {
      log('❌ Logout Exception: $error');
      return {'success': false, 'message': 'Logout failed: $error'};
    }
  }

  static Future<Map<String, dynamic>> downloadInvoice(String orderId) async {
    final url = Uri.parse('$baseUrl/api/order/invoice/$orderId');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token not found'};
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        try {
          final directory = await getDownloadsDirectory();
          final filePath = '${directory.path}/invoice_$orderId.pdf';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          return {
            'success': true,
            'message': 'Invoice downloaded successfully to Downloads folder',
            'filePath': filePath
          };
        } catch (e) {
          return {
            'success': true,
            'message': 'Invoice downloaded successfully'
          };
        }
      } else if (response.statusCode == 403) {
        await prefs.clear();
        return {
          'success': false,
          'message': 'Session expired. Please log in again.'
        };
      } else {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to download invoice'
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to download invoice. Unexpected response format.'
          };
        }
      }
    } catch (error) {
      return {'success': false, 'message': 'Download failed: $error'};
    }
  }

  static Future<Directory> getDownloadsDirectory() async {
    final directory = Directory('/storage/emulated/0/Download');
    return directory;
  }

  static Future<Map<String, dynamic>> addToCart(
      Product product, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      // showTopSnackBar(context, 'Please login to add item to Cart.');
      return {'error': 'Please Ensure Login'};
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/addtocart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'productId': product.id,
          'quantity': 1,
        }),
      );
      debugPrint(product.id);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return {
          'message': responseBody['message'],
          'cart': responseBody['cart'],
        };
      } else {
        final errorBody = json.decode(response.body);
        log("Error response: ${errorBody.toString()}");
        return {'error': errorBody['error'] ?? 'Failed to add product to cart'};
      }
    } catch (e) {
      log("Caught error: $e");
      return {'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/viewcart');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      List<dynamic> itemsData = responseData['cart']['items'] ?? [];
      List<CartItem> cartItems =
          itemsData.map((itemJson) => CartItem.fromJson(itemJson)).toList();

      Map<String, dynamic> quoteData = responseData['cart']['quote'];
      return {
        'cartItems': cartItems,
        'quote': quoteData,
      };
    } else if (response.statusCode == 404) {
      return {
        'cartItems': [],
        'quote': {},
      };
    } else {
      throw Exception('Failed to load cart items: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }
    final url = Uri.parse('$baseUrl/api/removefromcart');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'productId': productId}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to remove product from cart');
      }
    } catch (error) {
      throw Exception('Error removing product from cart: $error');
    }
  }

  static Future<Map<String, dynamic>> addToWishlist(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/addtowishlist');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add product to wishlist: ${response.body}');
    }
  }

  static Future<void> removeFromWishlist(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/removefromwishlist');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to remove product from wishlist: ${response.body}');
    }
  }

  // static Future<List<Map<String, dynamic>>> getWishlistItems() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('auth_token');

  //   if (token == null || token.isEmpty) {
  //     throw Exception('Authentication token is missing. Please log in again.');
  //   }

  //   final url = Uri.parse('$baseUrl/api/viewwishlist');
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> jsonResponse = json.decode(response.body);

  //     if (jsonResponse.containsKey('wishlist') &&
  //         jsonResponse['wishlist'] is List) {
  //       final List<dynamic> wishlist = jsonResponse['wishlist'];

  //       if (wishlist.isEmpty) {
  //         debugPrint('Wishlist is empty');
  //       }

  //       return wishlist.map((item) {
  //         return {
  //           '_id': item['productId'],
  //           'title': item['title'],
  //           'price': item['price'],
  //           'offerPrice': item['offerPrice'],
  //           'description': item[
  //               'name'],
  //           'images': item['image'] != null
  //               ? [item['image']]
  //               : [],
  //           'stock': item['stock'],
  //         };
  //       }).toList();
  //     } else {
  //       throw Exception(
  //           'Invalid response format: Wishlist data is missing or malformed.');
  //     }
  //   } else {
  //     throw Exception('Failed to load wishlist');
  //   }
  // }

  static Future<List<Map<String, dynamic>>> getWishlistItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/viewwishlist');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('wishlist') &&
            jsonResponse['wishlist'] is List) {
          final List<dynamic> wishlist = jsonResponse['wishlist'];

          if (wishlist.isEmpty) {
            debugPrint('Wishlist is empty');
            return [];
          }

          return wishlist.map((item) {
            return {
              '_id': item['productId'],
              'title': item['title'],
              'price': item['price'],
              'offerPrice': item['offerPrice'],
              'description': item['name'],
              'gstPercentage': item['gstPercentage'],
              'images': item['images'] != null ? [item['images']] : [],
              'stock': item['stock'],
            };
          }).toList();
        } else {
          debugPrint(
              'Wishlist key missing or malformed, returning empty list.');
          return [];
        }
      } else {
        debugPrint(
            'Failed to fetch wishlist, status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching wishlist from API: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateCartQuantity(
      String productId, int quantity) async {
    final url = Uri.parse('$baseUrl/api/updatecart/$productId');
    log("Making PUT request to: $url");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update cart: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

// static Future<Map<String, dynamic>> myupdateDelivery({
//   required String deliveryId,
//   required String username,
//   required String phoneNo,
//   required String houseNo,
//   required String streetName,
//   required String city,
//   required String state,
//   required String pinCode,
// }) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('auth_token');

//   if (token == null || token.isEmpty) {
//     throw Exception('Authentication token is missing. Please log in again.');
//   }

//   final response = await http.put(
//     Uri.parse('$baseUrl/api/delivery'),
//     headers: {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     },
//     body: jsonEncode({
//       'deliveryId': deliveryId,
//       'username': username,
//       'phoneNo': phoneNo,
//       'houseNo': houseNo,
//       'streetName': streetName,
//       'city': city,
//       'state': state,
//       'pinCode': pinCode,
//     }),
//   );

//   log('Response status: ${response.statusCode}');
//   log('Response body: ${response.body}');

//   final Map<String, dynamic> responseData = jsonDecode(response.body);

//   if (response.statusCode == 200) {
//     return responseData['delivery'] ?? {};
//   } else if (response.statusCode == 400) {
//     throw Exception(responseData['message'] ?? 'Invalid request data');
//   } else if (response.statusCode == 404) {
//     throw Exception(responseData['message'] ?? 'Delivery not found');
//   } else {
//     throw Exception(
//         'Failed to update delivery: ${responseData['message'] ?? response.body}');
//   }
// }

  static Future<List<Order>> fetchOrderHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception(
            'Authentication token is missing. Please log in again.');
      }

      final url = Uri.parse('$baseUrl/api/orders/history');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (!jsonResponse.containsKey('orders') ||
            jsonResponse['orders'] == null) {
          return [];
        }
        final List<dynamic> data = jsonResponse['orders'];
        print('Parsed response: $jsonResponse');

        return data.map((order) => Order.fromJson(order)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            'Failed to load order history: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('fetchOrderHistory Error: $error');
      throw Exception('An error occurred while fetching order history.');
    }
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }
    final url = Uri.parse('$baseUrl/api/orders/cancel');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'orderId': orderId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': true,
          'message': jsonDecode(response.body)['message'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  static Future<Order> fetchOrderDetail(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }
    final url = Uri.parse('$baseUrl/api/orders/history/$orderId');

    print(url);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return Order.fromJson(data['order']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to fetch order history');
      }
    } catch (error) {
      print('Error fetching order history: $error');
      throw Exception('Error fetching order history: $error');
    }
  }

  static Future<List<Notifications>> getNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/notifications');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        List<dynamic> body = responseData['data'];

        if (body.isEmpty) {
          return [];
        }

        return body
            .map((dynamic item) => Notifications.fromJson(item))
            .toList();
      } else if (responseData['message'] ==
          "No notifications found for this user") {
        // ✅ Handle the "No notifications" case properly
        return [];
      } else {
        print('Error: ${response.body}');
        throw Exception(
            responseData['error'] ?? 'Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  static Future<Map<String, dynamic>> getProductById(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/products/$productId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('product')) {
          return jsonResponse['product'] as Map<String, dynamic>;
        } else {
          throw Exception(
              'Invalid response format: Product data is missing or malformed.');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception(
            'Failed to fetch product: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching product by ID: $e');
      throw Exception('An error occurred while fetching the product.');
    }
  }

  static Future<Map<String, dynamic>> checkout(
      Map<String, dynamic> requestBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/checkout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      print('Checkout Request Body: $requestBody');
      if (response.statusCode == 200) {
        print('Backend error response: ${response.body}');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final error = jsonDecode(response.body);
        print(response.body);
        print(error['message']);
        throw Exception('Checkout failed: ${error['message']}');
      }
    } catch (e) {
      print(e);
      throw Exception('An error occurred during checkout: $e');
    }
  }

  static Future<bool> confirmPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    if (razorpayOrderId.isEmpty ||
        razorpayPaymentId.isEmpty ||
        razorpaySignature.isEmpty) {
      throw Exception('Invalid payment details received.');
    }

    final url = Uri.parse('$baseUrl/api/orders/confirm-payment');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        }),
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // ✅ Logs full response

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to confirm payment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in confirmPayment: $e');
      throw Exception('An error occurred while confirming the payment: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchMaintenanceStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/status'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'maintenance': false};
      }
    } catch (e) {
      return {'maintenance': false};
    }
  }

  static Future<List<Map<String, dynamic>>> mygetDeliveryDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      prefs.remove('selectedAddressId');
      prefs.remove('selectedUsername');
      prefs.remove('selectedPhoneNo');
      prefs.remove('selectedAddress');
      return [];
    }

    final url = Uri.parse('$baseUrl/api/userget');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Handle successful response
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print("Raw API Response: $data");

      // If API returns valid items in response, parse them; if empty, return empty list
      if (data.isNotEmpty &&
          data[0] is Map<String, dynamic> &&
          data[0].containsKey('items') &&
          (data[0]['items'] as List).isNotEmpty) {
        return List<Map<String, dynamic>>.from(data[0]['items']);
      } else {
        // No items found, clear selected address in SharedPreferences and return empty list
        prefs.remove('selectedAddressId');
        prefs.remove('selectedUsername');
        prefs.remove('selectedPhoneNo');
        prefs.remove('selectedAddress');
        print("No delivery addresses found in API response.");
        return [];
      }
    } else {
      print(response.body);
      throw Exception('Failed to load delivery details: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createDelivery({
    required String username,
    required String phoneNo,
    required String houseNo,
    required String streetName,
    required String city,
    required String state,
    required String pinCode,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'phoneNo': phoneNo,
        'username': username,
        'houseNo': houseNo,
        'streetName': streetName,
        'city': city,
        'state': state,
        'pinCode': pinCode,
      }),
    );

    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception(errorResponse['message'] ?? 'Failed to create delivery');
    }
  }

  static Future<Map<String, dynamic>> myupdateDelivery({
    required String deliveryId,
    required String username,
    required String phoneNo,
    required String houseNo,
    required String streetName,
    required String city,
    required String state,
    required String pinCode,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/delivery'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'deliveryId': deliveryId,
        'username': username,
        'phoneNo': phoneNo,
        'houseNo': houseNo,
        'streetName': streetName,
        'city': city,
        'state': state,
        'pinCode': pinCode,
      }),
    );

    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData['delivery'] ?? {};
    } else if (response.statusCode == 400) {
      throw Exception(responseData['message'] ?? 'Invalid request data');
    } else if (response.statusCode == 404) {
      throw Exception(responseData['message'] ?? 'Delivery not found');
    } else {
      throw Exception(
        'Failed to update delivery: ${responseData['message'] ?? response.body}',
      );
    }
  }

  static Future<List<double>> fetchOnlyOfferPrices(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final url = Uri.parse('$baseUrl/api/orders/history/$orderId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['order']['items'] as List<dynamic>;

        // Return only the offer prices
        return items
            .map<double>((item) => (item['offerPrice'] as num).toDouble())
            .toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to fetch order details');
      }
    } catch (error) {
      throw Exception('Error fetching offer prices: $error');
    }
  }

  static Future<Map<String, dynamic>> editUserDetailsByEmail({
    required String email,
    String? username,
    String? address,
    String? phoneNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (address != null) body['address'] = address;
    if (phoneNo != null) body['phoneNo'] = phoneNo;

    final response = await http.put(
      Uri.parse('$baseUrl/api/edit/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('EDIT RESPONSE: ${response.statusCode} ${response.body}');

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': data['message'],
        'user': data['user']
      };
    } else {
      return {'success': false, 'message': data['error'] ?? 'Unknown error'};
    }
  }

  static Future<Marquees?> fetchMarquee() async {
    final response = await http.get(Uri.parse("$baseUrl/api/marquee"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['marquee'] != null) {
        return Marquees.fromJson(data['marquee']);
      }
    }
    return null;
  }

static Future<String> fetchPrivacyPolicy() async {
  final url = Uri.parse('$baseUrl/api/policy/privacy');

  try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Privacy Policy Data: $data");

      return data['policy']?['content'] ?? "No content available";
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ?? 'Failed to fetch privacy policy',
      );
    }
  } catch (error) {
    throw Exception('Error fetching privacy policy: $error');
  }
}


  static Future<String> fetchTermsPolicy() async {
    final url = Uri.parse('$baseUrl/api/policy/terms');

   try {
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Privacy Policy Data: $data");

      return data['policy']?['content'] ?? "No content available";
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ?? 'Failed to fetch privacy policy',
      );
    }
  } catch (error) {
    throw Exception('Error fetching privacy policy: $error');
  }
}

static Future<Map<String, dynamic>> getSettings() async {
  final url = Uri.parse('$baseUrl/api/settings');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch settings');
    }
  } catch (e) {
    throw Exception('Error fetching settings: $e');
  }
}



static Future<ShopSettings?> fetchShopSettings() async {
  final response = await http.get(Uri.parse("$baseUrl/api/shop-settings"));
  print("Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}"); 
   if (response.statusCode == 200) {
    final data = json.decode(response.body);
        print("Decoded JSON: $data");

    return ShopSettings.fromJson(data);
  }
  return null;
}


}

class Delivery {
  final String id;
  final String username;
  final String phoneNo;
  final String houseNo;
  final String streetName;
  final String city;
  final String state;
  final String pinCode;

  Delivery({
    required this.id,
    required this.username,
    required this.phoneNo,
    required this.houseNo,
    required this.streetName,
    required this.city,
    required this.state,
    required this.pinCode,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['_id'],
      username: json['username'],
      phoneNo: json['phoneNo'],
      houseNo: json['houseNo'],
      streetName: json['streetName'],
      city: json['city'],
      state: json['state'],
      pinCode: json['pinCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phoneNo': phoneNo,
      'houseNo': houseNo,
      'streetName': streetName,
      'city': city,
      'state': state,
      'pinCode': pinCode,
    };
  }
}

// class RelatedProducts {
//   final Product product;
//   final List<Product> similarStartingLetter;
//   final List<Product> sameCategory;

//   RelatedProducts({
//     required this.product,
//     required this.similarStartingLetter,
//     required this.sameCategory,
//   });

//   factory RelatedProducts.fromJson(Map<String, dynamic> json) {
//     return RelatedProducts(
//       product: Product.fromJson(json['product']),
//       similarStartingLetter: (json['related']['similarStartingLetter'] as List)
//           .map((e) => Product.fromJson(e))
//           .toList(),
//       sameCategory: (json['related']['sameCategory'] as List)
//           .map((e) => Product.fromJson(e))
//           .toList(),
//     );
//   }
// }
class RelatedProducts {
  final Product product;
  final List<Product> related;

  RelatedProducts({
    required this.product,
    required this.related,
  });

  factory RelatedProducts.fromJson(Map<String, dynamic> json) {
    return RelatedProducts(
      product: Product.fromJson(json['product']),
      related:
          (json['related'] as List).map((e) => Product.fromJson(e)).toList(),
    );
  }
}

class Product {
  final String id;
  final String title;
  final double price;
  final double offerPrice;
  final String description;
  final List<String> images;
  final int stock;
  final double gstPercentage;
  final String unit;

  Product(
      {required this.id,
      required this.title,
      required this.price,
      required this.description,
      required this.images,
      required this.offerPrice,
      required this.stock,
      required this.gstPercentage,
      required this.unit});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      title: json['title'],
      price: json['price'].toDouble(),
      offerPrice: json['offerPrice'].toDouble(),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] != null ? json['stock'] as int : 0,
      gstPercentage: (json['gstPercentage'] != null)
          ? double.tryParse(json['gstPercentage'].toString()) ?? 0.0
          : 0.0,
      unit: json['unit'] ?? '',
    );
  }
}

class Category {
  final String id;
  final String title;
  final List<String> images;

  Category({required this.id, required this.title, required this.images});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      title: json['title'],
      images: List<String>.from(json['images']),
    );
  }
}

class Offer {
  final String id;
  final String productId;
  final String title;
  final String description;
  final double actualPrice;
  final double offerPrice;
  final List<String> images;
  final int stock;
  final double gstPercentage;
  final String unit;

  Offer({
    required this.id,
    required this.productId,
    required this.title,
    required this.description,
    required this.actualPrice,
    required this.offerPrice,
    required this.images,
    required this.stock,
    required this.gstPercentage,
    required this.unit,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'],
      productId: json['product'],
      title: json['title'],
      description: json['description'],
      actualPrice: (json['actualPrice'] as num).toDouble(),
      offerPrice: (json['offerPrice'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] ?? 1,
      gstPercentage: (json['gstPercentage'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'actualPrice': actualPrice,
      'offerPrice': offerPrice,
      'description': description,
      'images': images,
      'stock': stock,
      'gstPercentage': gstPercentage,
      'unit': unit,
    };
  }
}

class SubCategory {
  final String id;
  final String title;
  final String categoryId;
  final List<String> images;

  SubCategory(
      {required this.id,
      required this.title,
      required this.categoryId,
      required this.images});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'],
      title: json['title'],
      categoryId: json['categoryId'],
      images: List<String>.from(json['images']),
    );
  }
}

class CartItem {
  final String productId;
  final String productTitle;
  final String productImages;
  int quantity;
  final int stock;
  final double originalPrice;
  final double offerPrice;
  final double gstPercentage;
  final double gstAmount;
  final double totalWithGST;
  final double savings;
  final bool isUpdating;

  CartItem({
    required this.productId,
    required this.productTitle,
    required this.productImages,
    required this.quantity,
    required this.stock,
    required this.originalPrice,
    required this.offerPrice,
    required this.gstPercentage,
    required this.gstAmount,
    required this.totalWithGST,
    required this.savings,
    this.isUpdating = false,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImages: json['productImages'] ?? '',
      quantity: json['quantity'] ?? 0,
      stock: json['stock'] ?? 0,
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      gstPercentage: (json['gstPercentage'] is num)
          ? (json['gstPercentage'] as num).toDouble()
          : 0.0,
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      totalWithGST: (json['totalWithGST'] ?? 0).toDouble(),
      savings: (json['savings'] ?? 0).toDouble(),
    );
  }

  CartItem copyWith({
    String? productId,
    String? productTitle,
    String? productImages,
    int? quantity,
    int? stock,
    double? originalPrice,
    double? offerPrice,
    double? gstPercentage,
    double? gstAmount,
    double? totalWithGST,
    double? savings,
    bool? isUpdating,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImages: productImages ?? this.productImages,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      originalPrice: originalPrice ?? this.originalPrice,
      offerPrice: offerPrice ?? this.offerPrice,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      gstAmount: gstAmount ?? this.gstAmount,
      totalWithGST: totalWithGST ?? this.totalWithGST,
      savings: savings ?? this.savings,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class BannerModel {
  final String image;
  final String page;

  BannerModel({required this.image, required this.page});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      image: json['image'] ?? '',
      page: json['page'] ?? '',
    );
  }
}

class Order {
  final String orderId;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double overallTotal;
  final String houseNo;
  final String streetName;
  final String city;
  final String state;
  final String pinCode;
  final String phoneNo;
  final String username;
  final String paymentMethod;
  final String status;
  final String deliveryId;
  final String? offerId;
  final double gstAmount;
  final List<OrderStatusEntry> statusHistory;

  Order({
    // required this.productId,
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.overallTotal,
    required this.phoneNo,
    required this.houseNo,
    required this.state,
    required this.streetName,
    required this.city,
    required this.pinCode,
    required this.paymentMethod,
    required this.status,
    required this.username,
    required this.deliveryId,
    this.offerId,
    required this.gstAmount,
    required this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
      overallTotal: (json['overallTotal'] as num).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      houseNo: json['houseNo'] ?? '',
      streetName: json['streetName'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pinCode'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      username: json['username'] ?? '',
      deliveryId: json['deliveryId'] ?? '',
      offerId: json['offerId'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .map((entry) => OrderStatusEntry.fromJson(entry))
          .toList(),
    );
  }
}

class OrderItem {
  final String productId;
  final String productTitle;
  final String productImage;
  final double offerPrice;
  final int quantity;
  final String deliveryId;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.offerPrice,
    required this.quantity,
    required this.deliveryId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      deliveryId: json['deliveryId'] ?? '',
    );
  }
}

class OrderStatusEntry {
  final String status;
  final DateTime timestamp;

  OrderStatusEntry({required this.status, required this.timestamp});

  factory OrderStatusEntry.fromJson(Map<String, dynamic> json) {
    return OrderStatusEntry(
      status: json['status'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Notifications {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String? page;
  final String? productId;
  final String? orderId;
  final String? deliveryId;

  Notifications(
      {required this.id,
      required this.title,
      required this.body,
      required this.date,
      this.page,
      this.productId,
      this.orderId,
      this.deliveryId});

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
        id: json['_id'], // Parse the _id from MongoDB
        title: json['title'],
        body: json['body'],
        date: DateTime.parse(json['date']),
        page: json['page'],
        productId: json['productId'],
        orderId: json['orderId'],
        deliveryId: json['deliveryId']);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'page': page,
      'productId': productId,
      'orderId': orderId,
      'deliveryId': deliveryId
    };
  }
}

class Marquees {
  final String id;
  final String content;
  final bool isActive;

  Marquees({required this.id, required this.content, required this.isActive});

  factory Marquees.fromJson(Map<String, dynamic> json) {
    return Marquees(
      id: json['_id'],
      content: json['content'],
      isActive: json['isActive'],
    );
  }
}

class ShopSettings {
  final String websiteUrl;
  final String profileImage;
  final String mapLink;
  final String message;
  final String name;
  final String phoneNumber;
  final String whatsappNumber;
  final String poweredByImage;
  final String poweredByName;
  final String link;

  ShopSettings({
    required this.websiteUrl,
    required this.profileImage,
    required this.mapLink,
    required this.message,
    required this.name,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.poweredByImage,
    required this.poweredByName,
    required this.link,
  });

factory ShopSettings.fromJson(Map<String, dynamic> json) {
  return ShopSettings(
    websiteUrl: json['websiteUrl'] ?? '',
    profileImage: json['profileImage'] ?? '',
    mapLink: json['mapLink'] ?? '',
    message: json['message'] ?? '',
    name: json['name'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    whatsappNumber: json['whatsappNumber'] ?? '',
    poweredByImage: json['poweredBy']?['image'] ?? '',
    poweredByName: json['poweredBy']?['name'] ?? '',
    link: json['poweredBy']?['link'] ?? '',
  );
}

}
