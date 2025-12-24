import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/cart_service.dart';
import 'package:furniture_ecom_app/core/services_ecom/offers_service.dart';
import 'package:furniture_ecom_app/core/services_ecom/product_service.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_detail.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_reuable.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_confirmationpage.dart';
import 'package:furniture_ecom_app/my_ecom/product/reuasble_related_card.dart';

import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

const double _mobileCardWidth = 190;
const double widePhoneCardWidth = 250;
const double _tabletCardWidth = 300;
const double _listHeight = 250;
const EdgeInsets _horizontalPadding = EdgeInsets.symmetric(horizontal: 12);

class ProductDetailPagep extends StatefulWidget {
  final Product? product;
  final String? productId;
  final bool isPreview;

  const ProductDetailPagep({
    super.key,
    this.product,
    this.productId,
    this.isPreview = false,
  });

  @override
  State<ProductDetailPagep> createState() => _ProductDetailPagepState();
}

class _ProductDetailPagepState extends State<ProductDetailPagep> {
  late Future<Product> _productFuture;
  late PageController _pageController;

  Product? _loadedProduct;
  bool isAddedToCart = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.product != null) {
      _loadedProduct = widget.product;
      _productFuture = Future.value(widget.product);
    } else if (widget.productId != null) {
      _productFuture = _fetchProduct(widget.productId!);
    } else {
      _productFuture = Future.error("No product or productId provided");
    }
  }

  Future<Product> _fetchProduct(String productId) async {
    try {
      final productData = await ProductService.getProductById(productId);
      return Product.fromJson(productData);
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  CartProvider? cartProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartProvider ??= Provider.of<CartProvider>(context, listen: false);
  }

  Future<bool> addToCartItem(Product product, BuildContext context) async {
    if (isAddedToCart) return true; // Already added, treat as success

    try {
      final response = await CartService.addToCart(product, context);

      if (response.containsKey('error') && response['error'] != null) {
        if (!mounted) return false;

        if (response['error']) {
          showTopSnackBar(context, response['error']);
        }

        return false;
      } else {
        await cartProvider?.fetchCartCount();

        showTopSnackBar(
          context,
          response['message'] ?? "Product Added to Cart!!",
        );

        return true;
      }
    } catch (e) {
      if (!mounted) return false;

      showTopSnackBar(
        context,
        "Failed to add product to cart. Please try again.",
      );

      return false;
    }
  }

  void handleBuyNow(Product product, BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mythemecolor1, mythemecolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Product Details",
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
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load product: ${snapshot.error}'),
            );
            // return _buildErrorViewWithOffers(
            //     context, snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No product data available.'));
          }
          _loadedProduct = snapshot.data!;
          final product = _loadedProduct!;

          return isTablet
              ? _buildTabletView(product)
              : _buildMobileView(product);
        },
      ),
    );
  }

  Widget _buildMobileView(Product product) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadedProduct = widget.product;
                _productFuture = Future.value(widget.product);
                ProductService.getRelatedProducts(product.id);
              });
            },
            color: mythemecolor,
            backgroundColor: const Color.fromARGB(255, 245, 240, 242),
            displacement: 40,
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: product.images.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                product.images[index],
                                fit: BoxFit.contain,
                                width: double.infinity,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: product.images.length,
                      effect: const WormEffect(
                        dotWidth: 8,
                        dotHeight: 7,
                        activeDotColor: mythemecolor,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceSection(product),
                  const SizedBox(height: 20),
                  _buildAttributesSection(product),

                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  _buildRelatedProducts(product, context),
                ],
              ),
            ),
          ),
        ),
        if (!widget.isPreview)
          SafeArea(bottom: true, child: _buildActionButtons(product)),
      ],
    );
  }

  Widget _buildTabletView(Product product) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadedProduct = widget.product;
          _productFuture = Future.value(widget.product);
          ProductService.getRelatedProducts(product.id);
        });
      },
      color: mythemecolor,
      backgroundColor: const Color.fromARGB(255, 245, 240, 242),
      displacement: 40,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth > 600
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 400,
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: product.images.length,
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          product.images[index],
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SmoothPageIndicator(
                                  controller: _pageController,
                                  count: product.images.length,
                                  effect: const WormEffect(
                                    dotWidth: 8,
                                    dotHeight: 7,
                                    activeDotColor: mythemecolor,
                                    dotColor: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildPriceSection(product),
                                const SizedBox(height: 10),
                                const SizedBox(height: 20),
                                _buildAttributesSection(product),

                                const Text(
                                  'Description:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  product.description,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 20),
                                if (!widget.isPreview)
                                  SafeArea(
                                    bottom: true,
                                    child: _buildActionButtons(product),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 400, // Adjusted height
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: product.images.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    product.images[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: product.images.length,
                              effect: const WormEffect(
                                dotWidth: 8,
                                dotHeight: 7,
                                activeDotColor: Colors.green,
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildPriceSection(product),
                          const SizedBox(height: 20),
                          _buildAttributesSection(product),

                          const Text(
                            'Description:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product.description,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                          if (!widget.isPreview) _buildActionButtons(product),
                        ],
                      );
              },
            ),
            const SizedBox(height: 30),
            _buildRelatedProducts(product, context),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "₹${product.offerPrice.round()}",
              style: TextStyle(
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: mythemecolor1,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "${(((product.price - product.offerPrice) / product.price) * 100).round()}% OFF",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // ORIGINAL PRICE + SAVE AMOUNT
        Row(
          children: [
            Text(
              "MRP: ₹${product.price.round()}",
              style: TextStyle(
                fontSize: isTablet ? 16 : 13,
                color: Colors.grey[600],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "You Save ₹${(product.price - product.offerPrice).round()}",
              style: TextStyle(
                fontSize: isTablet ? 16 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),

        // PREMIUM TAGS
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _premiumTag(Icons.local_offer, "Best Price"),
              _premiumTag(Icons.shield, "100% Genuine"),
              _premiumTag(Icons.workspace_premium, "Top Quality"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _premiumTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        _infoRow(
          "Measurement",
          product.measurement.isNotEmpty ? product.measurement : "N/A",
        ),
        _infoRow("Size", product.size.isNotEmpty ? product.size : "N/A"),
        _infoRow("Weight", product.weight.isNotEmpty ? product.weight : "N/A"),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isAddedToCart
                  ? () => Navigator.pushNamed(context, '/cart')
                  : (product.stock > 0
                        ? () async {
                            setState(() => _isAddingToCart = true);

                            final success = await addToCartItem(
                              product,
                              context,
                            );

                            setState(() {
                              _isAddingToCart = false;
                              if (success) {
                                isAddedToCart = true;
                              }
                            });
                          }
                        : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAddedToCart
                    ? mythemecolor1
                    : (product.stock > 0
                          ? const Color.fromARGB(255, 199, 180, 119)
                          : Colors.grey),
                padding: const EdgeInsets.all(8),
              ),
              child: _isAddingToCart
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isAddedToCart
                          ? 'VIEW CART'
                          : (product.stock > 0
                                ? 'ADD TO CART'
                                : 'OUT OF STOCK'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: mythemecolor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: product.stock > 0
                  ? () => handleBuyNow(product, context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: product.stock > 0
                    ? adminPrimaryColor
                    : Colors.grey,
                padding: const EdgeInsets.all(8),
              ),
              child: const Text(
                'BUY NOW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedOfferProducts(BuildContext context, String productId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    final bool isWidePhone = screenWidth >= 360 && screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'You Might Like These Products!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Offer>>(
          future: OfferService.fetchOfferProductsAsOffers(),
          builder: (context, relatedSnapshot) {
            if (relatedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: mythemecolor),
              );
            } else if (relatedSnapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load related products: ${relatedSnapshot.error}',
                ),
              );
            } else if (!relatedSnapshot.hasData ||
                relatedSnapshot.data!.isEmpty) {
              return const Center(
                child: Text('No related products available.'),
              );
            }

            final relatedOffers = relatedSnapshot.data!;

            return SizedBox(
              height: isTablet
                  ? 420
                  : isWidePhone
                  ? 300
                  : 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: relatedOffers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final relatedOffer = relatedOffers[index];
                  return SizedBox(
                    width: isTablet
                        ? _tabletCardWidth
                        : isWidePhone
                        ? widePhoneCardWidth
                        : _mobileCardWidth,
                    child: MyOfferWidget(
                      offer: relatedOffer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              offer: relatedOffer,
                              isPreview: widget.isPreview,
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
        ),
      ],
    );
  }

  Widget _buildNoResultsUI(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final bool isWidePhone =
        MediaQuery.of(context).size.width >= 360 &&
        MediaQuery.of(context).size.width < 600;
    return FutureBuilder<List<Product>>(
      future: ProductService.fetchAllProducts(),
      builder: (context, relatedSnapshot) {
        if (relatedSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: mythemecolor),
          );
        }

        if (relatedSnapshot.hasError) {
          return Center(
            child: Text('Failed to load products: ${relatedSnapshot.error}'),
          );
        }

        if (!relatedSnapshot.hasData || relatedSnapshot.data!.isEmpty) {
          return const Center(child: Text('No products available.'));
        }

        final relatedProducts = relatedSnapshot.data!;

        return SizedBox(
          height: isTablet
              ? 450
              : isWidePhone
              ? 300
              : 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: _horizontalPadding,
            itemCount: relatedProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = relatedProducts[index];

              return SizedBox(
                width: isTablet
                    ? _tabletCardWidth
                    : isWidePhone
                    ? widePhoneCardWidth
                    : _mobileCardWidth,
                child: MyrelatedproductWidget(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPagep(
                          product: product,
                          isPreview: widget.isPreview,
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

  Widget _buildRelatedProducts(Product product, BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final bool isWidePhone =
        MediaQuery.of(context).size.width >= 360 &&
        MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'You Might Like These Products!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Product>>(
          future: ProductService.getRelatedProducts(product.id),
          builder: (context, relatedSnapshot) {
            if (relatedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: mythemecolor),
              );
            }

            if (relatedSnapshot.hasError) {
              return _buildRelatedOfferProducts(context, product.id);
            }

            if (!relatedSnapshot.hasData || relatedSnapshot.data!.isEmpty) {
              return _buildNoResultsUI(context);
            }

            final relatedProducts = relatedSnapshot.data!;

            return SizedBox(
              height: isTablet
                  ? 450
                  : isWidePhone
                  ? 300
                  : _listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: _horizontalPadding,
                itemCount: relatedProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final relatedProduct = relatedProducts[index];

                  return SizedBox(
                    width: isTablet
                        ? _tabletCardWidth
                        : isWidePhone
                        ? widePhoneCardWidth
                        : _mobileCardWidth,
                    child: MyrelatedproductWidget(
                      product: relatedProduct,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPagep(
                              product: relatedProduct,
                              isPreview: widget.isPreview,
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
        ),
      ],
    );
  }
}
