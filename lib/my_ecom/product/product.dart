import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/appbar.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:furniture_ecom_app/my_ecom/product/resuable_product.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  final String subCategoryId;

  const ProductPage({
    super.key,
    required this.subCategoryId,
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<Product>> _productsFuture;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _productsFuture = ApiService.fetchProducts(widget.subCategoryId);
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  void _showLoginPrompt(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            width: isTablet ? screenWidth * 0.6 : double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 20,
              vertical: isTablet ? 40 : 25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.lock_outline,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  "Login Required",
                  style: TextStyle(
                    fontSize: isTablet ? 26 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please log in to continue adding items to your cart or wishlist.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 72, 181, 64),
                          Color.fromARGB(255, 13, 112, 4)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 50 : 30,
                        vertical: isTablet ? 16 : 12,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Login Now",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SafeArea(
                  bottom: true,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Maybe later",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Consumer<WishlistManager>(
      builder: (context, wishlistManager, child) {
        return Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: MyAppbar(title: 'Products'),
          ),
          body: FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (!mounted) return const SizedBox();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }

              final products = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(10),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        isTablet ? 0.7 : 0.72, // Adjusted to reduce empty space
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return MyProductWidget(
                      product: product,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPagep(
                            product: product,
                          ),
                        ),
                      ),
                      isLoggedIn: _isLoggedIn,
                      onLoginPrompt: () => _showLoginPrompt(context),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}




  // itemBuilder: (context, index) {
                  //   final product = products[index];
                  //   final isInWishlist =
                  //       wishlistManager.isInWishlist(product.id);

                  //   return GestureDetector(
                  //     onTap: () => Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) =>
                  //             ProductDetailPagep(product: product),
                  //       ),
                  //     ),
                  //     child: Card(
                  //       elevation: 6,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       color: Colors.white,
                  //       shadowColor: Colors.grey.shade300,
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Stack(
                  //             children: [
                  //               ClipRRect(
                  //                 borderRadius: const BorderRadius.vertical(
                  //                     top: Radius.circular(12)),
                  //                 child: Image.network(
                  //                   product.images.isNotEmpty
                  //                       ? product.images[0]
                  //                       : 'https://via.placeholder.com/150',
                  //                   fit: BoxFit.cover,
                  //                   width: double.infinity,
                  //                   height: isTablet ? 270 : 150,
                  //                   errorBuilder:
                  //                       (context, error, stackTrace) =>
                  //                           Container(
                  //                     height: isTablet ? 220 : 140,
                  //                     color: Colors.grey.shade300,
                  //                     child: const Icon(Icons.broken_image,
                  //                         size: 50, color: Colors.grey),
                  //                   ),
                  //                 ),
                  //               ),
                  //               Positioned(
                  //                 top: 8,
                  //                 left: 8,
                  //                 child: Container(
                  //                   padding: const EdgeInsets.symmetric(
                  //                       horizontal: 8, vertical: 4),
                  //                   decoration: BoxDecoration(
                  //                     color: Colors.red.shade600,
                  //                     borderRadius: BorderRadius.circular(6),
                  //                   ),
                  //                   child: Text(
                  //                     '${(((product.price - product.offerPrice) / product.price) * 100).round()}% OFF',
                  //                     style: const TextStyle(
                  //                       color: Colors.white,
                  //                       fontSize: 12,
                  //                       fontWeight: FontWeight.bold,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //               Positioned(
                  //                 top: 8,
                  //                 right: 8,
                  //                 child: GestureDetector(
                  //                   onTap: () {
                  //                     if (_isLoggedIn) {
                  //                       wishlistManager.toggleWishlist(
                  //                           product.id, context);
                  //                     } else {
                  //                       _showLoginPrompt(context);
                  //                     }
                  //                   },
                  //                   child: Container(
                  //                     padding: const EdgeInsets.all(6),
                  //                     decoration: const BoxDecoration(
                  //                       color:
                  //                           Color.fromRGBO(255, 255, 255, 0.6),
                  //                       shape: BoxShape.circle,
                  //                     ),
                  //                     child: Icon(
                  //                       isInWishlist
                  //                           ? Icons.favorite
                  //                           : Icons.favorite_border,
                  //                       color: isInWishlist
                  //                           ? Colors.red
                  //                           : const Color.fromARGB(
                  //                               255, 35, 34, 34),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           Expanded(
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   Text(
                  //                     product.title,
                  //                     style: TextStyle(
                  //                       fontSize: isTablet ? 20 : 12,
                  //                       fontWeight: FontWeight.bold,
                  //                       color: Colors.black,
                  //                     ),
                  //                     maxLines: 1,
                  //                     overflow: TextOverflow.ellipsis,
                  //                   ),
                  //                   if (isTablet) const SizedBox(height: 5),
                  //                   if (isTablet)
                  //                     Expanded(
                  //                       child: Text(
                  //                         product.description,
                  //                         style: const TextStyle(
                  //                           fontSize: 18,
                  //                           color: Color.fromARGB(
                  //                               255, 100, 99, 99),
                  //                         ),
                  //                         maxLines: 4,
                  //                         overflow: TextOverflow.ellipsis,
                  //                       ),
                  //                     ),
                  //                   const SizedBox(height: 5),
                  //                   Row(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.spaceBetween,
                  //                     children: [
                  //                       Text(
                  //                         '\$${product.offerPrice. round()}',
                  //                         style: TextStyle(
                  //                           fontSize: isTablet ? 21 : 14,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: Colors.green.shade700,
                  //                         ),
                  //                       ),
                  //                       Text(
                  //                         '\$${product.price. round()}',
                  //                         style: TextStyle(
                  //                           fontSize: isTablet ? 16 : 12,
                  //                           color: Colors.red,
                  //                           decoration:
                  //                               TextDecoration.lineThrough,
                  //                           decorationColor: Colors.black,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   );
                  // },