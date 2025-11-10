import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/product_service.dart';
import 'package:furniture_ecom_app/core/services/search_service.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:furniture_ecom_app/my_ecom/product/productwidget.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultScreen extends StatefulWidget {
  final String query;

  const ResultScreen({super.key, required this.query});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<List<Product>> _searchResultsFuture;
  late Future<List<Product>> _allProductsFuture;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _searchResultsFuture = fetchProducts(widget.query);
    _allProductsFuture = ProductService.fetchAllProducts();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });
  }

  // Future<List<Product>> fetchProducts(String query) async {
  //   try {
  //     final apiService = SearchService();
  //     final fetchedProducts = await apiService.searchProducts(query);
  //     print(fetchedProducts);
  //     return fetchedProducts
  //         .map<Product>((data) => Product.fromJson(data))
  //         .toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }


  Future<List<Product>> fetchProducts(String query) async {
  try {
    final fetchedProducts = await SearchService.searchProducts(query);
    print(fetchedProducts);
    return fetchedProducts
        .map<Product>((data) => Product.fromJson(data))
        .toList();
  } catch (e) {
    print("Search error: $e");
    return [];
  }
}


  @override
  Widget build(BuildContext context) {
    final wishlistManager = Provider.of<WishlistManager>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final int crossAxisCount = isTablet ? 4 : 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                  mythemecolor1,
               mythemecolor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Search Results",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _searchResultsFuture = fetchProducts(widget.query);
          });
        },
        color: const Color.fromARGB(255, 13, 75, 15),
        backgroundColor: const Color.fromARGB(255, 245, 240, 242),
        displacement: 40,
        strokeWidth: 2.5,
        child: FutureBuilder<List<Product>>(
          future: _searchResultsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: mythemecolor,
              ));
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text('Error loading products.'));
            }

            final products = snapshot.data!;
            if (products.isEmpty) {
              return _buildNoResultsUI(wishlistManager, crossAxisCount);
            }

            return _buildProductGrid(products, wishlistManager, crossAxisCount);
          },
        ),
      ),
    );
  }

 Widget _buildNoResultsUI(
    WishlistManager wishlistManager, int crossAxisCount) {
  return SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: Column(
      children: [
        const SizedBox(
          height: 80,
        ),
        Image.asset(
          'assets/images/nosuch.png',
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          'No such products, you may like these!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(255, 128, 10, 75),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Product>>(
          future: _allProductsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Error loading products.'),
              );
            }

            final allProducts = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _buildProductGrid(
                allProducts,
                wishlistManager,
                crossAxisCount,
                isInsideScrollView: true,
              ),
            );
          },
        ),
      ],
    ),
  );
}

  Widget _buildProductGrid(
    List<Product> products,
    WishlistManager wishlistManager,
    int crossAxisCount, {
    bool isInsideScrollView = false,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      physics: isInsideScrollView
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      shrinkWrap: isInsideScrollView,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductWidget(
          product: product,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailPagep(product: product, productId: product.id),
            ),
          ),
          isLoggedIn: _isLoggedIn,
        );
      },
    );
  }
}


