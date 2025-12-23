import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/constants/colors.dart';

class MyrelatedproductWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const MyrelatedproductWidget({
    super.key,
    required this.product,
    required this.onTap,
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
            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images.first
                        : 'https://via.placeholder.com/150',
                    fit: BoxFit.contain,

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
              ],
            ),

            /// CONTENT
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 8.0 : 8.0 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 12 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C2B2B),
                      ),
                    ),
                    const SizedBox(height: 4),
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
                            if (product.price > product.offerPrice)
                              Text(
                                '₹${product.price.round()}',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 11 * scale,
                                  color: Colors.red,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: const Color.fromARGB(
                                    255,
                                    134,
                                    134,
                                    134,
                                  ),
                                  decorationThickness: 3,
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
