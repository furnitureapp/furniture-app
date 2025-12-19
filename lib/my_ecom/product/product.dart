import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/product_service.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/appbar.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:furniture_ecom_app/my_ecom/product/resuable_product.dart';
import 'package:furniture_ecom_app/my_ecom/wishlist/wishlist_manager.dart';

import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  final String subCategoryId;
  final bool isPreview;
  final bool enableWishlist;

  const ProductPage({
    super.key,
    required this.subCategoryId,
    this.isPreview = false,
    this.enableWishlist = true,
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.fetchProducts(widget.subCategoryId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Consumer<WishlistManager>(
      builder: (context, wishlistManager, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: MyAppbar(
              title: 'Products',
              isPreview: widget.isPreview, 
            ),
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
                    childAspectRatio: isTablet
                        ? 0.7
                        : 0.72, // Adjusted to reduce empty space
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    // return MyProductWidget(
                    //   product: product,
                    //   onTap: () => Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) =>
                    //           ProductDetailPagep(product: product),
                    //     ),
                    //   ),
                    // );
                    return MyProductWidget(
                      product: product,
                      enableWishlist: !widget.isPreview, 
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}
