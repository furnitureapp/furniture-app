import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';
import 'package:provider/provider.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool enableWishlist;
  const ProductWidget({
    super.key,
    required this.product,
    required this.onTap,
    this.enableWishlist = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final scale = isTablet ? 1.0 : screenWidth / 400;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        shadowColor: Colors.grey.shade300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(2),
                  ),
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
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (enableWishlist)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistManager>(
                      builder: (context, wishlistManager, child) {
                        bool isInWishlist = wishlistManager.isInWishlist(
                          product.id,
                        );
                        final isLoading = wishlistManager.isLoadingFor(
                          product.id,
                        );

                        return GestureDetector(
                          onTap: () async {
                            wishlistManager.toggleWishlist(product.id, context);
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
                                      color: Colors.grey,
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
                        color: const Color.fromARGB(255, 0, 0, 0),
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
                              '₹${product.price.round()}',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 11 * scale,
                                color:  const Color.fromARGB(
                                  255,
                                  134,
                                  134,
                                  134,
                                ),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: const Color.fromARGB(255, 66, 66, 66),
                                decorationThickness: 2,
                              ),
                            ),
                            Text(
                              '₹${product.offerPrice.round()}',
                              style: TextStyle(
                                fontSize: isTablet ? 21 : 14 * scale,
                                fontWeight: FontWeight.bold,
                                color: mythemecolor,
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
