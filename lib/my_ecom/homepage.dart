import 'dart:async';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:furniture_ecom_app/my_ecom/banner_widget.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/categories_widget.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/appbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/drawer.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:furniture_ecom_app/my_ecom/product/productwidget.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/products.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Myhome extends StatefulWidget {
  const Myhome({super.key});

  @override
  State<Myhome> createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  late Future<List<Product>> _productsFuture;
  late Future<ShopSettings?> _shopSettingsFuture;

  bool _isLoggedIn = false;
  late Future<Marquees?> _marqueeFuture;

  @override
  void initState() {
    super.initState();
    _shopSettingsFuture = ApiService.fetchShopSettings();
    _marqueeFuture = ApiService.fetchMarquee();

    _productsFuture = ApiService.fetchAllProducts();

    _checkLoginStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCartCount();
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final loggedIn = token != null && token.isNotEmpty;

    if (mounted && loggedIn != _isLoggedIn) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }

    if (loggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<WishlistManager>(context, listen: false).initialize();
      });
    }
  }

  Future<void> _refreshData() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavBar()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: FutureBuilder<ShopSettings?>(
          future: _shopSettingsFuture,
          builder: (context, snapshot) {
            String title = "Fresh Grocery";
            if (snapshot.connectionState == ConnectionState.waiting) {
              title = "Fresh Grocery";
            } else if (snapshot.hasData && snapshot.data != null) {
              title = snapshot.data!.name; 
            }
            return MyAppbar(title: title);
          },
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color.fromARGB(255, 13, 75, 15),
        backgroundColor: const Color.fromARGB(255, 245, 240, 242),
        displacement: 40,
        strokeWidth: 2.5,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              if (!isTablet) const SearchScreens(),
              const MyCategoriesWidget(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: FutureBuilder<Marquees?>(
                  future: _marqueeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 30);
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        height: 35,
                        color: const Color.fromARGB(255, 231, 244, 233),
                        child: Marquee(
                          text: snapshot.data!.content,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 26, 77, 34),
                            letterSpacing: 1.0,
                          ),
                          scrollAxis: Axis.horizontal,
                          blankSpace: 50.0,
                          velocity: 50.0,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              const SizedBox(height: 5),
              const BannerWidget(),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "TOP DEALS FOR YOU!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    height: 1.5,
                    decorationThickness: 2.5,
                    decorationStyle: TextDecorationStyle.solid,
                    color: Color.fromARGB(255, 13, 75, 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const OfferGridWidget(),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Products You May Like!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 13, 75, 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.green,
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  final products = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(7),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 2,
                      crossAxisSpacing: isTablet ? 12 : 5,
                      mainAxisSpacing: isTablet ? 12 : 5,
                      childAspectRatio: isTablet ? 0.7 : 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];

                      debugPrint(
                          'Navigating to product: ${product.title}, Stock: ${product.stock}');

                      return ProductWidget(
                        product: product,
                        isLoggedIn: _isLoggedIn,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPagep(
                              product: product,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}































  // Future<void> _checkLoginStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('auth_token');
  //   setState(() {
  //     _isLoggedIn = token != null && token.isNotEmpty;
  //   });
  //    if (_isLoggedIn) {
  //   Provider.of<WishlistManager>(context, listen: false).initialize();
  // }
  // }             
  // @override
  // void initState() {
  //   super.initState();
  //   _productsFuture = ApiService.fetchAllProducts();
  //   _checkLoginStatus();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Provider.of<CartProvider>(context, listen: false).fetchCartCount();
  //   });
  // }
  // isInWishlist: isInWishlist,
                        // onToggleWishlist: () {
                        //   wishlistManager.toggleWishlist(product.id, context);
                        // }


// itemCount: products.length,
      // itemBuilder: (context, index) {
      //   final product = products[index];

      //   return ProductWidget(
      //     product: product,
      //     onTap: () => Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => ProductDetailPagep(product: product),
      //       ),
      //     ),
      //     isLoggedIn: _isLoggedIn,
      //   );
      // },































// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/banner_widget.dart';
// import 'package:model_app/cart/cart_provider.dart';
// import 'package:model_app/categories_widget.dart';
// import 'package:model_app/navbar/appbar.dart';
// import 'package:model_app/navbar/search_screen.dart';
// import 'package:model_app/offer/offer.dart';
// import 'package:model_app/product/product_detail.dart';
// import 'package:model_app/product/productwidget.dart';
// import 'package:model_app/wishlist/wishlist_manager.dart';
// import 'package:provider/provider.dart';

// class Myhome extends StatefulWidget {
//   const Myhome({super.key});

//   @override
//   State<Myhome> createState() => _MyhomeState();
// }

// class _MyhomeState extends State<Myhome> {
//   late Future<List<Categorys>> _categoriesFuture;
//   late Future<List<String>> _bannersFuture;
//   late Future<List<Product>> _productsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _categoriesFuture = ApiService.fetchCategories();
//     _bannersFuture = ApiService().fetchBannerImages();
//     _productsFuture = ApiService.fetchAllProducts();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<CartProvider>(context, listen: false).fetchCartCount();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final wishlistManager = Provider.of<WishlistManager>(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final bool isTablet = screenWidth >= 600;

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 245, 240, 242),
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(60),
//         child: MyAppbar(),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 5),
//             if (!isTablet) const SearchScreen(),
//             const SizedBox(height: 5),

//             // Lazy Load Categories
//             FutureBuilder<List<Categorys>>(
//               future: _categoriesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return _buildLoadingPlaceholder(height: 100);
//                 } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("No categories found"));
//                 }
//                 return const MyCategoriesWidget();
//               },
//             ),

//             // Lazy Load Banners
//             FutureBuilder<List<String>>(
//               future: _bannersFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return _buildLoadingPlaceholder(height: 150);
//                 } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text("No banners found"));
//                 }
//                 return const BannerWidget();
//               },
//             ),

//             const SizedBox(height: 10),
//             const Center(
//               child: Text(
//                 "TOP DEALS FOR YOU!",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Color.fromARGB(255, 13, 75, 15),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),

//             const OfferGridWidget(),
//             const SizedBox(height: 10),

//             const Center(
//               child: Text(
//                 "Products You May Like!",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Color.fromARGB(255, 13, 75, 15),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Lazy Load Products
//             FutureBuilder<List<Product>>(
//               future: _productsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return _buildLoadingPlaceholder(height: 300);
//                 } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No products found'));
//                 }

//                 final products = snapshot.data!;
//                 return GridView.builder(
//                   padding: const EdgeInsets.all(10),
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: isTablet ? 4 : 2,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                     childAspectRatio: isTablet ? 0.7 : 0.75,
//                   ),
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     final product = products[index];
//                     final isInWishlist = wishlistManager.isInWishlist(product.id);

//                     return ProductWidget(
//                       product: product,
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ProductDetailPagep(product: product),
//                         ),
//                       ),
//                       isInWishlist: isInWishlist,
//                       onToggleWishlist: () {
//                         wishlistManager.toggleWishlist(product.id, context);
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Placeholder for loading effect
//   Widget _buildLoadingPlaceholder({double height = 100}) {
//     return Container(
//       height: height,
//       color: Colors.grey[300], // Light grey for skeleton effect
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//     );
//   }
// }
