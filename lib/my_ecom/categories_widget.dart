import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:furniture_ecom_app/my_ecom/categories.dart';
import 'package:furniture_ecom_app/my_ecom/subc_screen.dart';

import 'package:shimmer/shimmer.dart';

class MyCategoriesWidget extends StatefulWidget {
  const MyCategoriesWidget({super.key});

  @override
  _MyCategoriesWidgetState createState() => _MyCategoriesWidgetState();
}

class _MyCategoriesWidgetState extends State<MyCategoriesWidget> {
  late Future<List<Category>> _categoriesFuture;
  final Set<String> _wishlist = {};

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.fetchCategories();
  }

  void _toggleWishlist(String productId) {
    setState(() {
      if (_wishlist.contains(productId)) {
        _wishlist.remove(productId);
      } else {
        _wishlist.add(productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return FutureBuilder<List<Category>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return isTablet
              ? _buildTabletPlaceholder()
              : _buildMobilePlaceholder();
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        final categories = snapshot.data!;
        return isTablet
            ? _buildExploreSection(categories)
            : _buildExploreSection(categories);
      },
    );
  }

Widget _buildExploreSection(List<Category> categories) {
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth >= 600;
  final itemWidth = isTablet ? 120.0 : (screenWidth - 64) / 4;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Explore',
              style: TextStyle(
                fontSize: isTablet ? 20 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesScreen()),
                );
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isTablet ? 20 : 16,
                    color: Colors.grey[800],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: isTablet ? 170 : 110,
        // child: 
        // ListView.builder(
        //   scrollDirection: Axis.horizontal,
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //   itemCount: categories.length,
        //   itemBuilder: (context, index) {
        //     return Padding(
        //       padding: const EdgeInsets.only(right: 12.0),
        //       child: _buildCategoryItem(categories[index], itemWidth, isTablet),
        //     );
        //   },
        // ),
        child: ListView.separated(
  scrollDirection: Axis.horizontal,
  padding:  EdgeInsets.symmetric(horizontal:  isTablet ? 30 : 5),
  itemCount: categories.length,
  separatorBuilder: (context, index) =>
      SizedBox(width: isTablet ? 30 : 12), // 👈 adjust for tablet
  itemBuilder: (context, index) {
    return _buildCategoryItem(categories[index], itemWidth, isTablet);
  },
),

      ),
    ],
  );
}

  // Widget _buildExploreSection(List<Category> categories) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final itemWidth = (screenWidth - 64) / 4;

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Explore',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.grey[800],
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => CategoriesScreen()),
  //                 );
  //               },
  //               child: Row(
  //                 children: [
  //                   Text(
  //                     'View All',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       fontWeight: FontWeight.w500,
  //                       color: Colors.grey[800],
  //                     ),
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Icon(
  //                     Icons.arrow_forward_ios,
  //                     size: 16,
  //                     color: Colors.grey[800],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(
  //         height: 110,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //           itemCount: categories.length,
  //           itemBuilder: (context, index) {
  //             return Padding(
  //               padding: const EdgeInsets.only(right: 12.0),
  //               child: _buildCategoryItem(categories[index], itemWidth),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  

  // Widget _buildCategoryItem(Category category, double width) {
  //   final String displayTitle = category.title.contains('&')
  //       ? category.title.split('&').first.trim()
  //       : category.title;

  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => SubCategoryScreen(
  //             categoryId: category.id,
  //             wishlist: _wishlist,
  //             toggleWishlist: _toggleWishlist,
  //           ),
  //         ),
  //       );
  //     },
  //     child: SizedBox(
  //       width: width,
  //       child: Column(
  //         children: [
  //           SizedBox(
  //             height: 60,
  //             width: 60,
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(10),
  //               child: Image.network(
  //                 category.images[0],
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             displayTitle,
  //             style: TextStyle(
  //               fontSize: 11,
  //               fontWeight: FontWeight.w600,
  //             ),
  //             textAlign: TextAlign.center,
  //             overflow: TextOverflow.ellipsis,
  //             maxLines: 1,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildCategoryItem(Category category, double width, bool isTablet) {
  final String displayTitle = category.title.contains('&')
      ? category.title.split('&').first.trim()
      : category.title;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoryScreen(
            categoryId: category.id,
            wishlist: _wishlist,
            toggleWishlist: _toggleWishlist,
          ),
        ),
      );
    },
    child: SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            height: isTablet ? 110 : 60,
            width: isTablet ? 140 : 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                category.images[0],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayTitle,
            style: TextStyle(
              fontSize: isTablet ? 18 : 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildMobilePlaceholder() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 50,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }




  Widget _buildTabletPlaceholder() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 140,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}






  // Widget _buildCategoryItems(Category category) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final bool isTablet = screenWidth >= 600;
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => SubCategoryScreen(
  //             categoryId: category.id,
  //             wishlist: _wishlist,
  //             toggleWishlist: _toggleWishlist,
  //           ),
  //         ),
  //       );
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //       child: SizedBox(
  //         width: isTablet ? 115 : 60,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             SizedBox(
  //               width: isTablet ? 150 : 70,
  //               height: isTablet ? 100 : 70,
  //               child: Card(
  //                 elevation: 0,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(5),
  //                 ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(10),
  //                   child: Image.network(
  //                     category.images[0],
  //                     fit: BoxFit.cover,
  //                     width: double.infinity,
  //                     height: isTablet ? 100 : 70,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             SizedBox(
  //               width: isTablet ? 180 : 70,
  //               height: isTablet ? 50 : 30,
  //               child: Text(
  //                 category.title,
  //                 style: TextStyle(
  //                   fontSize: isTablet ? 15 : 10,
  //                   color: Color.fromARGB(255, 8, 63, 17),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 textAlign: TextAlign.center,
  //                 maxLines: isTablet ? 2 : 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  

  // Widget _buildMobileView(List<Category> categories) {
  //   const SizedBox(height: 20);
  //   return SizedBox(
  //     height: 180,

  //     child: ListView.separated(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: categories.length + 1,
  //       itemBuilder: (context, index) {
  //         if (index == categories.length) {
  //           return _buildSeeAllIcon();
  //         } else {
  //           return _buildCategoryItem(categories[index]);
  //         }
  //       },
  //       separatorBuilder: (context, index) => const SizedBox(width: 16),
  //     ),
  //   );
  // }
//
 
 // Widget _buildMobileView(List<Category> categories) {
  //   final displayCategories = categories.take(7).toList();
  //   final firstRow = displayCategories.take(4).toList();
  //   final secondRow = displayCategories.skip(4).toList();

  //   return SizedBox(
  //     height: 270,
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: firstRow
  //                     .map((category) => _buildCategoryItem(category))
  //                     .toList(),
  //               ),
  //               const SizedBox(height: 10),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   ...secondRow
  //                       .map((category) => _buildCategoryItem(category)),
  //                   _buildSeeAllIcon(),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

//   Widget _buildCategoryPlaceholder() {
//     return SizedBox(
//       height: 120,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 6, // Show 6 placeholders
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     width: 70,
//                     height: 15,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }


// import 'package:flutter/material.dart';
// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/categories.dart';
// import 'package:model_app/subc_screen.dart';
// import 'package:shimmer/shimmer.dart';

// class MyCategoriesWidget extends StatefulWidget {
//   const MyCategoriesWidget({super.key});

//   @override
//   _MyCategoriesWidgetState createState() => _MyCategoriesWidgetState();
// }

// class _MyCategoriesWidgetState extends State<MyCategoriesWidget> {
//   late Future<List<Category>> _categoriesFuture;
//   final Set<String> _wishlist = {};

//   @override
//   void initState() {
//     super.initState();
//     _categoriesFuture = ApiService.fetchCategories();
//   }

//   void _toggleWishlist(String productId) {
//     setState(() {
//       if (_wishlist.contains(productId)) {
//         _wishlist.remove(productId);
//       } else {
//         _wishlist.add(productId);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final bool isTablet = screenWidth >= 600;

//     return FutureBuilder<List<Category>>(
//       future: _categoriesFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildCategoryPlaceholder();
//         } else if (snapshot.hasError ||
//             !snapshot.hasData ||
//             snapshot.data!.isEmpty) {
//           return const Center(child: Text('No categories found'));
//         }

//         final categories = snapshot.data!;
//         return isTablet
//             ? _buildTabletView(categories)
//             : _buildMobileView(categories);
//       },
//     );
//   }

//   // Widget _buildMobileView(List<Category> categories) {
//   //   final displayCategories = categories.take(7).toList();
//   //   final firstRow = displayCategories.take(4).toList();
//   //   final secondRow =
//   //       displayCategories.skip(4).toList(); // will have 3 or fewer

//   //   return SizedBox(
//   //     height: 260,
//   //     child: ListView(
//   //       scrollDirection: Axis.horizontal,
//   //       children: [
//   //         Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Row(
//   //               mainAxisAlignment: MainAxisAlignment.start,
//   //               children: firstRow
//   //                   .map((category) => _buildCategoryItem(category))
//   //                   .toList(),
//   //             ),
//   //             const SizedBox(height: 10),
//   //             Row(
//   //               mainAxisAlignment: MainAxisAlignment.start,
//   //               children: [
//   //                 ...secondRow.map((category) => _buildCategoryItem(category)),
//   //                 _buildSeeAllIcon(),
//   //               ],
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }


//   Widget _buildSeeAllIcon() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final bool isTablet = screenWidth >= 600;
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CategoriesScreen(),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: Column(
//           children: [
//             SizedBox(
//               width: 80,
//               height: isTablet ? 100 : 80,
//               child: Card(
//                 color: Colors.transparent,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 child: Icon(
//                   Icons.category_rounded,
//                   size: isTablet ? 60 : 40,
//                   color: Color.fromARGB(255, 8, 63, 17),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 5),
//             SizedBox(
//               width: 70,
//               child: Text(
//                 'See All',
//                 style: TextStyle(
//                   fontSize: isTablet ? 15 : 10,
//                   color: const Color.fromARGB(255, 8, 63, 17),
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// Widget _buildMobileView(List<Category> categories) {
//   final displayCategories = categories.take(7).toList();
//   final firstRow = displayCategories.take(4).toList();
//   final secondRow = displayCategories.skip(4).toList(); // will have 3 or fewer

//   return SizedBox(
//     height: 240,
//     child: SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 19.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               children: firstRow
//                   .map((category) => _buildCategoryItem(category))
//                   .toList(),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 ...secondRow.map((category) => _buildCategoryItem(category)),
//                 _buildSeeAllIcon(),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

//   Widget _buildTabletView(List<Category> categories) {
//     return SizedBox(
//       height: 120,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length + 1,
//         itemBuilder: (context, index) {
//           if (index == categories.length) {
//             return _buildSeeAllIcon();
//           } else {
//             return _buildCategoryItem(categories[index]);
//           }
//         },
//         separatorBuilder: (context, index) => const SizedBox(width: 16),
//       ),
//     );
//   }

// Widget _buildCategoryItem(Category category) {
//   return LayoutBuilder(
//     builder: (context, constraints) {
//       final screenWidth = MediaQuery.of(context).size.width;

//       final double itemWidth = screenWidth < 400
//           ? screenWidth / 5.2
//           : screenWidth < 600
//               ? screenWidth / 6
//               : 90;

//       return GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SubCategoryScreen(
//                 categoryId: category.id,
//                 wishlist: _wishlist,
//                 toggleWishlist: _toggleWishlist,
//               ),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//           child: SizedBox(
//             width: itemWidth,
//             child: Column(
//               children: [
//                 SizedBox(
//                   width: itemWidth,
//                   height: itemWidth,
//                   child: Card(
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.network(
//                         category.images[0],
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 SizedBox(
//                   height: 30,
//                   child: Text(
//                     category.title,
//                     style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 8, 63, 17),
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

//   Widget _buildSeeAllIcon() {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CategoriesScreen(),
//           ),
//         );
//       },
//       child: Column(
//         children: [
//           SizedBox(
//             width: 70,
//             height: 70,
//             child: Card(
//               color: Colors.transparent,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: const Icon(
//                 Icons.category_rounded,
//                 size: 40,
//                 color: Color.fromARGB(255, 8, 63, 17),
//               ),
//             ),
//           ),
//           const SizedBox(height: 5),
//           const SizedBox(
//             width: 70,
//             child: Text(
//               'See All',
//               style: TextStyle(
//                 fontSize: 10,
//                 color: Color.fromARGB(255, 8, 63, 17),
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryPlaceholder() {
//     return SizedBox(
//       height: 120,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 6, // Show 6 placeholders
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 // 🔹 Shimmer Effect on the Category Icon
//                 Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 5),

//                 // 🔹 Shimmer Effect on the Category Text
//                 Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     width: 70,
//                     height: 15,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
  // here, everything is fine, the only thing, is in mobile view, it need to adjust thecategory items, should be adjusted based on the mobile screen isze, right. 