import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';


class MyOfferWidget extends StatelessWidget {
  final Offer offer;
  final VoidCallback onTap;

  const MyOfferWidget({
    super.key,
    required this.offer,
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
                    offer.images.isNotEmpty
                        ? offer.images[0]
                        : 'https://via.placeholder.com/150',
                    fit: BoxFit.contain,
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
              
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 8.0 : 8.0 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
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
                        offer.description,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 10 * scale,
                          color: const Color.fromARGB(255, 100, 99, 99),
                        ),
                        maxLines: isTablet ? 5 : 2,
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
                              '₹${offer.actualPrice. round()}',
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
                              '₹${offer.offerPrice. round()}',
                              style: TextStyle(
                                fontSize: isTablet ? 21 : 14 * scale,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 26, 82, 29),
                              ),
                            ),
                          ],
                        ),
                        if (offer.actualPrice > offer.offerPrice)
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
                              '${(((offer.actualPrice - offer.offerPrice) / offer.actualPrice) * 100).round()}% OFF',
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
