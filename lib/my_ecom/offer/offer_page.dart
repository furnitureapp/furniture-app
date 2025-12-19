import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/product_service.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/appbar.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:furniture_ecom_app/my_ecom/product/resuable_product.dart';

class OfferPage extends StatefulWidget {
  final bool enableWishlist;
  final bool isPreview;

  const OfferPage({
    super.key,
    this.enableWishlist = true,
    this.isPreview = false,
  });

  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  List<Product> products = [];
  bool isLoading = true;
  bool noResults = false;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    setState(() {
      isLoading = true;
      noResults = false;
    });

    try {
      List<Product> fetchedProducts = await ProductService.fetchAllProducts();

      setState(() {
        products = fetchedProducts;
        isLoading = false;
        noResults = fetchedProducts.isEmpty;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showTopSnackBar(context, "Failed to load offers");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MyAppbar(
          title: "offers for you!",
          isPreview: widget.isPreview,
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await fetchOffers();
        },
        color: mythemecolor,
        backgroundColor: const Color.fromARGB(255, 245, 240, 242),
        displacement: 40,
        strokeWidth: 2.5,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTitle("Exclusive Offers Just for You"),
              const SizedBox(height: 10),
              _buildSubtitle("Check out the latest deals"),
              const SizedBox(height: 20),
              Center(child: OfferGridWidget(isPreview: widget.isPreview)),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'You may like these products!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              isLoading
                  ? GridView.builder(
                      padding: const EdgeInsets.all(7),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 4 : 2,
                        crossAxisSpacing: isTablet ? 12 : 5,
                        mainAxisSpacing: isTablet ? 12 : 5,
                        childAspectRatio: isTablet ? 0.7 : 0.75,
                      ),
                      itemCount: isTablet ? 8 : 4, // number of shimmer boxes
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.all(4),
                        );
                      },
                    )
                  : noResults
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        subtitle,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
