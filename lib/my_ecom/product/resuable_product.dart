import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProductWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isLoggedIn;

  const MyProductWidget({
    super.key,
    required this.product,
    required this.onTap,
    this.isLoggedIn = true,
    required void Function() onLoginPrompt,
  });

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
    final isTablet = screenWidth >= 600;
    final scale = isTablet ? 1.0 : screenWidth / 400;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        shadowColor: Colors.grey.shade300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(2)),
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images[0]
                        : 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: isTablet ? 270 : 140 * scale,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: isTablet ? 220 : 140 * scale,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image,
                          size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistManager>(
                    builder: (context, wishlistManager, child) {
                      bool isInWishlist =
                          wishlistManager.isInWishlist(product.id);

                      final isLoading =
                          wishlistManager.isLoadingFor(product.id);

                      return GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('auth_token');

                          if (token == null || token.isEmpty) {
                            _showLoginPrompt(context);
                            return;
                          } else {
                            wishlistManager.toggleWishlist(product.id, context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isInWishlist
                                      ? Colors.red
                                      : Color.fromARGB(255, 35, 34, 34),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 8.0 : 8.0 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 12 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 44, 43, 43),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Expanded(
                      child: Text(
                        product.description,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 10 * scale,
                          color: const Color.fromARGB(255, 100, 99, 99),
                        ),
                        maxLines: isTablet ? 5 : 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: isTablet ? 5 : 5 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${product.price. round()}',
                              style: TextStyle(
                                  fontSize: isTablet ? 16 : 11 * scale,
                                  color: const Color.fromARGB(255, 247, 82, 70),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor:
                                      const Color.fromARGB(255, 134, 134, 134),
                                  decorationThickness: 3),
                            ),
                            Text(
                              '₹${product.offerPrice. round()}',
                              style: TextStyle(
                                fontSize: isTablet ? 21 : 14 * scale,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 26, 82, 29),
                              ),
                            ),
                          ],
                        ),
                        if (product.price > product.offerPrice)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 8 : 8 * scale,
                              vertical: isTablet ? 4 : 4 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(((product.price - product.offerPrice) / product.price) * 100).round()}% OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 12 : 10 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 5 : 5 * scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


