import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/constants/colors.dart';


// class MyrelatedproductWidget extends StatelessWidget {
//   final Product product;
//   final VoidCallback onTap;

//   const MyrelatedproductWidget({
//     super.key,
//     required this.product,
//     required this.onTap,
//   });


//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isTablet = screenWidth >= 600;
//     final scale = isTablet ? 1.0 : screenWidth / 400;

//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 6,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         color: Colors.white,
//         shadowColor: Colors.grey.shade300,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(2)),
//                   child: Image.network(
//                     product.images.isNotEmpty
//                         ? product.images[0]
//                         : 'https://via.placeholder.com/150',
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: isTablet ? 270 : 100 * scale,
//                     errorBuilder: (context, error, stackTrace) => Container(
//                       height: isTablet ? 220 : 140 * scale,
//                       color: Colors.grey.shade300,
//                       child: const Icon(Icons.broken_image,
//                           size: 50, color: Colors.grey),
//                     ),
//                   ),
//                 ),
              
//               ],
//             ),
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(isTablet ? 8.0 : 8.0 * scale),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product.title,
//                       style: TextStyle(
//                         fontSize: isTablet ? 20 : 12 * scale,
//                         fontWeight: FontWeight.bold,
//                         color: const Color.fromARGB(255, 44, 43, 43),
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Expanded(
//                       child: Text(
//                         product.description,
//                         style: TextStyle(
//                           fontSize: isTablet ? 18 : 10 * scale,
//                           color: const Color.fromARGB(255, 100, 99, 99),
//                         ),
//                         maxLines: isTablet ? 5 : 4,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     SizedBox(height: isTablet ? 5 : 5 * scale),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '₹${product.price. round()}',
//                               style: TextStyle(
//                                   fontSize: isTablet ? 16 : 11 * scale,
//                                   color: const Color.fromARGB(255, 247, 82, 70),
//                                   fontWeight: FontWeight.bold,
//                                   decoration: TextDecoration.lineThrough,
//                                   decorationColor:
//                                       const Color.fromARGB(255, 134, 134, 134),
//                                   decorationThickness: 3),
//                             ),
//                             Text(
//                               '₹${product.offerPrice. round()}',
//                               style: TextStyle(
//                                 fontSize: isTablet ? 21 : 14 * scale,
//                                 fontWeight: FontWeight.bold,
//                                 color: mythemecolor,

//                               ),
//                             ),
//                           ],
//                         ),
//                         if (product.price > product.offerPrice)
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: isTablet ? 8 : 8 * scale,
//                               vertical: isTablet ? 4 : 4 * scale,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade600,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               '${(((product.price - product.offerPrice) / product.price) * 100).round()}% OFF',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: isTablet ? 12 : 10 * scale,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: isTablet ? 5 : 5 * scale),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

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
            /// IMAGE
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.images.isNotEmpty
                    ? product.images.first
                    : 'https://via.placeholder.com/150',
                width: double.infinity,
                height: isTablet ? 140 : 120,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: isTablet ? 140 : 120,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C2B2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: const Color(0xFF646363),
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// PRICE ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.price > product.offerPrice)
                            Text(
                              '₹${product.price.round()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                decoration:
                                    TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '₹${product.offerPrice.round()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: mythemecolor,
                            ),
                          ),
                        ],
                      ),
                      if (product.price > product.offerPrice)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(((product.price - product.offerPrice) / product.price) * 100).round()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


