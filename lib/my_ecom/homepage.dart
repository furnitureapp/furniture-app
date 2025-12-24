import 'dart:async';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/marque_policy_terms.dart';
import 'package:furniture_ecom_app/core/services_ecom/product_service.dart';
import 'package:furniture_ecom_app/my_ecom/banner_widget.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/categories_widget.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/appbar.dart';
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
import 'package:shimmer/shimmer.dart';

class Myhome extends StatefulWidget {
  final bool isPreview;
  final int? typeOfProduct;
  const Myhome({super.key, this.isPreview = false, this.typeOfProduct});

  // const Myhome({super.key});

  @override
  State<Myhome> createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  late Future<List<Product>> _productsFuture;

  bool _isLoggedIn = false;
  late Future<Marquees?> _marqueeFuture;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _checkLoginStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isPreview) {
        Provider.of<CartProvider>(context, listen: false).fetchCartCount();
      }
    });
  }

  void _loadAllData() {
    _marqueeFuture = MarqueePolicyTermsService.fetchMarquee();

    _productsFuture = widget.isPreview
        ? ProductService.fetchAllProductsforAdmin(
            typeOfProduct: widget.typeOfProduct,
          )
        : ProductService.fetchAllProducts();
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

  // Future<void> _refreshData() async {
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const BottomNavBar()),
  //     (route) => false,
  //   );
  // }

  Future<void> _refreshData() async {
    setState(() {
      _loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final bool isTablet = screenWidth >= 600;
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isTabletPortrait = width >= 600 && width < 900;
    final bool isTabletLandscape = width >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: MyAppbar(title: "Wood Pecker", isPreview: widget.isPreview),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: mythemecolor,
        backgroundColor: Colors.white,
        displacement: 40,
        strokeWidth: 2.5,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              if (!isTabletLandscape && !isTabletPortrait && !widget.isPreview)
                const SearchScreens(),
              MyCategoriesWidget(isPreview: widget.isPreview),
              Padding(
                padding: const EdgeInsets.all(2),
                child: FutureBuilder<Marquees?>(
                  future: _marqueeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 35,
                        color: const Color.fromARGB(255, 233, 235, 233),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 20,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        height: 35,
                        color: const Color.fromARGB(255, 233, 235, 233),
                        child: Marquee(
                          text: snapshot.data!.content,
                          style: GoogleFonts.bebasNeue(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: mythemecolor,
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
                    fontSize: 16,
                    height: 1.5,
                    decorationThickness: 2.5,
                    decorationStyle: TextDecorationStyle.solid,
                    color: mythemecolor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OfferGridWidget(isPreview: widget.isPreview),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Products You May Like!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: mythemecolor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: mythemecolor),
                    );
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
                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //   crossAxisCount: isTablet ? 4 : 2,
                    //   crossAxisSpacing: isTablet ? 12 : 5,
                    //   mainAxisSpacing: isTablet ? 12 : 5,
                    //   childAspectRatio: isTablet ? 0.7 : 0.75,
                    // ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTabletPortrait
                          ? 3 // ✅ TABLET PORTRAIT → 3 ITEMS PER ROW
                          : isTabletLandscape
                          ? 4 // ✅ TABLET LANDSCAPE → 4 ITEMS
                          : 2, // ✅ MOBILE
                      crossAxisSpacing: isMobile ? 6 : 14,
                      mainAxisSpacing: isMobile ? 6 : 14,
                      childAspectRatio: isTabletPortrait
                          ? 0.65
                          : isTabletLandscape
                          ? 0.7
                          : 0.7,
                    ),

                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductWidget(
                        enableWishlist: !widget.isPreview,
                        product: product,
                        onTap: () => Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) => ProductDetailPagep(
                              product: product,
                              isPreview: widget.isPreview,
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
