import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/cart_service.dart';
import 'package:furniture_ecom_app/core/services/offers_service.dart';
import 'package:furniture_ecom_app/core/services/product_service.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_detail.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_confirmationpage.dart';
import 'package:furniture_ecom_app/my_ecom/product/reuasble_related_card.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailPagep extends StatefulWidget {
  final Product? product;
  final String? productId;

  // final Offer? offer;

  const ProductDetailPagep({super.key, this.product, this.productId});

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

  void _showLoginPrompt(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('redirectRoute', '/product/:productId');
    await prefs.setString('productId', widget.product?.id ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            width: isTablet ? screenWidth * 0.6 : double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40 : 20,
              vertical: isTablet ? 40 : 25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [mythemecolor1, mythemecolor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.lock_outline,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  "Login Required",
                  style: TextStyle(
                    fontSize: isTablet ? 26 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Please log in to continue adding items to your cart or wishlist.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                         mythemecolor1, mythemecolor
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 50 : 30,
                        vertical: isTablet ? 16 : 12,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Login Now",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SafeArea(
                  bottom: true,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Maybe later",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Future<void> addToCartItem(Product product, BuildContext context) async {
  //   if (isAddedToCart) return;

  //   setState(() {
  //     isAddedToCart = true;
  //   });

  //   try {
  //     final response = await ApiService.addToCart(product, context);

  //     if (response.containsKey('error') && response['error'] != null) {
  //       if (!mounted) return;
  //       if (response['error'] == 'Please Ensure Login') {
  //         _showLoginPrompt(context);
  //       } else {
  //         showTopSnackBar(context, response['error']);
  //       }

  //       setState(() {
  //         isAddedToCart = false;
  //       });
  //     } else {
  //       await cartProvider?.fetchCartCount();
  //       showTopSnackBar(
  //         context,
  //         response['message'] ?? "Product Added to Cart!!",
  //       );
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() {
  //       isAddedToCart = false;
  //     });
  //     showTopSnackBar(
  //       context,
  //       "Failed to add product to cart. Please try again.",
  //     );
  //   }
  // }

  Future<bool> addToCartItem(Product product, BuildContext context) async {
    if (isAddedToCart) return true; // Already added, treat as success

    try {
      final response = await CartService.addToCart(product, context);

      if (response.containsKey('error') && response['error'] != null) {
        if (!mounted) return false;

        if (response['error'] == 'Please Ensure Login') {
          _showLoginPrompt(context);
        } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(response['error']),
        //   ),
        // );
          showTopSnackBar(context, response['error']);
        }

        return false;
      } else {
        await cartProvider?.fetchCartCount();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text( response['message'] ?? "Product Added to Cart!!"),
        //   ),
        // );
        showTopSnackBar(
          context,
          response['message'] ?? "Product Added to Cart!!",
        );

        return true;
      }
    } catch (e) {
      if (!mounted) return false;
// ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to add product to cart. Please try again.",),
//           ),
//         );
      showTopSnackBar(
        context,
        "Failed to add product to cart. Please try again.",
      );

      return false;
    }
  }

  void handleBuyNow(Product product, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      _showLoginPrompt(context);
      return;
    }

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
                child: Text('Failed to load product: ${snapshot.error}'));
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
            color: const Color.fromARGB(255, 13, 75, 15),
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
                                fit: BoxFit.cover,
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
                        activeDotColor:mythemecolor,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(product.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildPriceSection(product),
                  const SizedBox(height: 16),
                  _buildOfferSection(product),
                  const SizedBox(height: 20),
                  const Text('Description:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 20),
                  _buildRelatedProducts(product, context),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: true,
          child: _buildActionButtons(product),
        )
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
      color: const Color.fromARGB(255, 13, 75, 15),
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
                                          fit: BoxFit.cover,
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
                                    activeDotColor: Colors.green,
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
                                Text(product.title,
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                _buildPriceSection(product),
                                const SizedBox(height: 10),
                                _buildOfferSection(product),
                                const SizedBox(height: 20),
                                const Text('Description:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Text(product.description,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 20),
                                _buildActionButtons(product),
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
                          Text(product.title,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildPriceSection(product),
                          const SizedBox(height: 10),
                          _buildOfferSection(product),
                          const SizedBox(height: 20),
                          const Text('Description:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(product.description,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 20),
                          _buildActionButtons(product),
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
    return Row(
      children: [
        Text('Offer Price : ₹${product.offerPrice. round()}',
            style: TextStyle(
                color: const Color.fromARGB(255, 70, 56, 83),
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 22 : 14)),
        const SizedBox(width: 20),
        Text(' ₹${product.price. round()}',
            style: TextStyle(
                color: const Color.fromARGB(255, 94, 90, 90),
                fontSize: isTablet ? 22 : 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.black)),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildOfferSection(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _discountTag(
            'SAVE ! ${(((product.price - product.offerPrice) / product.price) * 100).round()}%',
            mythemecolor),
        Text('Per Unit: ${product.unit}',
            style: TextStyle(
                fontSize: isTablet ? 18 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
        _discountTag(
            '₹${(product.price - product.offerPrice). round()} Saved',
            mythemecolor1),
      ],
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

                          final success = await addToCartItem(product, context);

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
                    : (product.stock > 0 ? const Color.fromARGB(255, 199, 180, 119) : Colors.grey),
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
                        fontSize: 14,
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
                backgroundColor: product.stock > 0 ? mythemecolor: Colors.grey,
                padding: const EdgeInsets.all(8),
              ),
              child: const Text(
                'BUY NOW',
                style: TextStyle(
                  fontSize: 14,
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

// Widget _buildActionButtons(Product product) {

//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     decoration: const BoxDecoration(
//       color: Colors.white,
//       border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
//     ),
//     child: Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: isAddedToCart
//                 ? () => Navigator.pushNamed(context, '/cart')
//                 : (product.stock > 0
//                     ? () => addToCartItem(product, context)
//                     : null),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: isAddedToCart
//                   ? const Color.fromARGB(255, 225, 204, 15)
//                   : (product.stock > 0 ? Colors.orange : Colors.grey),
//               padding: const EdgeInsets.all(14),
//             ),
//             child: Text(
//               isAddedToCart
//                   ? 'VIEW CART'
//                   : (product.stock > 0 ? 'ADD TO CART' : 'OUT OF STOCK'),
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: product.stock > 0
//                 ? () => handleBuyNow(product, context)
//                 : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: product.stock > 0 ? Colors.green : Colors.grey,
//               padding: const EdgeInsets.all(14),
//             ),
//             child: const Text(
//               'BUY NOW',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
  Widget _discountTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

Widget _buildRelatedOfferProducts(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth > 600;

  return FutureBuilder<List<Offer>>(
    future: OfferService.fetchOfferProductsAsOffers(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
            child: CircularProgressIndicator(
          color: mythemecolor,
        ));
      } else if (snapshot.hasError) {
        return Center(
          child: Text('Failed to load offers: ${snapshot.error}'),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No offer products available.'));
      }

      final offers = snapshot.data!;

      return SizedBox(
        height: isTablet ? 250 : 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            final discountPercentage =
                ((offer.actualPrice - offer.offerPrice) / offer.actualPrice) *
                    100;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(offer: offer),
                  ),
                );
              },
              child: Container(
                width: isTablet ? 180 : 190,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 224, 234, 224),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            offer.images.isNotEmpty
                                ? offer.images.first
                                : 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: isTablet ? 140 : 160,
                          ),
                        ),
                        if (offer.actualPrice > offer.offerPrice)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${discountPercentage.round()}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '₹${offer.offerPrice. round()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '₹${offer.actualPrice. round()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}



Widget _buildNoResultsUI(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth >= 600;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FutureBuilder<List<Product>>(
        future: ProductService.fetchAllProducts(),
        builder: (context, relatedSnapshot) {
          if (relatedSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: mythemecolor),
            );
          } else if (relatedSnapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load products: ${relatedSnapshot.error}',
              ),
            );
          } else if (!relatedSnapshot.hasData ||
              relatedSnapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final relatedProducts = relatedSnapshot.data!;

          return SizedBox(
            height: isTablet ? 420 : 220, // match card height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: relatedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = relatedProducts[index];

                return SizedBox(
                  width: isTablet ? 320 : 190, // fixed card width
                  child: MyrelatedproductWidget(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPagep(product: product),
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




Widget _buildRelatedProducts(Product product, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth >= 600;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'You Might Like These Products!',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      FutureBuilder<List<Product>>(
        future: ProductService.getRelatedProducts(product.id),
        builder: (context, relatedSnapshot) {
          if (relatedSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: mythemecolor),
            );
          } else if (relatedSnapshot.hasError) {
            return _buildRelatedOfferProducts(context);
          } else if (!relatedSnapshot.hasData ||
              relatedSnapshot.data!.isEmpty) {
            return _buildNoResultsUI(context);
          }

          final relatedProducts = relatedSnapshot.data!;

          return SizedBox(
            height: isTablet ? 420 : 300, // enough height for full card
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: relatedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final relatedProduct = relatedProducts[index];

                return SizedBox(
                  width: isTablet ? 320 : 190, // fixed width per card
                  child: MyrelatedproductWidget(
                    product: relatedProduct,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPagep(product: relatedProduct),
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





