import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/cart_service.dart';
import 'package:furniture_ecom_app/core/services/offers_service.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_reuable.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_confirmationpage.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailPage extends StatefulWidget {
  final Offer offer;
  const ProductDetailPage({
    super.key,
    required this.offer,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Offer> _offersFuture;
  Offer? _loadedOffer;
  late PageController _pageController;

  bool isAddedToCart = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _offersFuture = _fetchOffer();
  }

  Future<Offer> _fetchOffer() async {
    try {
      return widget.offer;
    } catch (e) {
      throw Exception("Failed to fetch offer details");
    }
  }

  void _showLoginPrompt(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

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
                      colors: [Colors.orangeAccent, Colors.deepOrange],
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
                          Color.fromARGB(255, 72, 181, 64),
                          Color.fromARGB(255, 13, 112, 4)
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

  void _handleBuyNow(BuildContext context, Offer offer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      _showLoginPrompt(context);
      return;
    }

    final product = Product(
        id: offer.productId,
        title: offer.title,
        price: offer.actualPrice,
        offerPrice: offer.offerPrice,
        description: offer.description,
        images: offer.images,
        stock: offer.stock,
        gstPercentage: offer.gstPercentage,
        unit: offer.unit);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationPage(
          product: product,
          offerId: offer.id,
        ),
      ),
    );
  }

  // Future<void> _addToCart(BuildContext context, Offer offer) async {
  //   if (isAddedToCart) return;

  //   setState(() {
  //     isAddedToCart = true;
  //   });

  //   try {
  //     final product = Product(
  //         id: offer.productId,
  //         title: offer.title,
  //         price: offer.actualPrice,
  //         offerPrice: offer.offerPrice,
  //         description: offer.description,
  //         images: offer.images,
  //         stock: offer.stock,
  //         gstPercentage: offer.gstPercentage,
  //         unit: offer.unit);

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
  //       await Provider.of<CartProvider>(context, listen: false)
  //           .fetchCartCount();
  //       showTopSnackBar(
  //           context, response['message'] ?? "Product Added to Cart!!");
  //     }
  //   } catch (e) {
  //     debugPrint('Error adding to cart: $e');
  //     showTopSnackBar(
  //         context, "Failed to add product to cart. Please try again.");
  //     setState(() {
  //       isAddedToCart = false;
  //     });
  //   }
  // }

  Future<bool> _addToCart(BuildContext context, Offer offer) async {
    if (isAddedToCart) return true;

    setState(() {
      isAddedToCart = true;
    });

    try {
      final product = Product(
        id: offer.productId,
        title: offer.title,
        price: offer.actualPrice,
        offerPrice: offer.offerPrice,
        description: offer.description,
        images: offer.images,
        stock: offer.stock,
        gstPercentage: offer.gstPercentage,
        unit: offer.unit,
      );

      final response = await CartService.addToCart(product, context);

      if (response.containsKey('error') && response['error'] != null) {
        if (!mounted) return false;
        if (response['error'] == 'Please Ensure Login') {
          _showLoginPrompt(context);
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(response['error']),
          //   ),
          // );
          showTopSnackBar(context, response['error']);
        }

        setState(() {
          isAddedToCart = false;
        });
        return false;
      } else {
        await Provider.of<CartProvider>(context, listen: false)
            .fetchCartCount();

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(response['message'] ?? "Product Added to Cart!!"),
        //   ),
        // );
        showTopSnackBar(
            context, response['message'] ?? "Product Added to Cart!!");
        return true;
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Failed to add product to cart. Please try again."),
      //   ),
      // );
      showTopSnackBar(
          context, "Failed to add product to cart. Please try again.");
      setState(() {
        isAddedToCart = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 149, 220, 124),
                Color.fromARGB(255, 41, 97, 67),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.offer.title,
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
      body: FutureBuilder<Offer>(
        future: _offersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load product: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No product data available.'));
          }

          _loadedOffer = snapshot.data!;
          final offer = _loadedOffer!;

          return isTablet ? _buildTabletView(offer) : _buildMobileView(offer);
        },
      ),
    );
  }

  Widget _buildMobileView(Offer offer) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _offersFuture = _fetchOffer();
                OfferService.fetchOfferProductsAsOffers();
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
                            itemCount: offer.images.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                offer.images[index],
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
                      count: offer.images.length,
                      effect: const WormEffect(
                        dotWidth: 8,
                        dotHeight: 7,
                        activeDotColor: Colors.green,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(offer.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildPriceSection(offer),
                  const SizedBox(height: 16),
                  _buildOfferSection(offer),
                  const SizedBox(height: 20),
                  const Text('Description:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(offer.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  _buildRelatedProducts(context, widget.offer.productId),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: true,
          child: _buildActionButtons(offer),
        )
      ],
    );
  }

  Widget _buildTabletView(Offer offer) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _offersFuture = _fetchOffer();
          OfferService.fetchOfferProductsAsOffers();
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
                                      itemCount: offer.images.length,
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          offer.images[index],
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SmoothPageIndicator(
                                  controller: _pageController,
                                  count: offer.images.length,
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
                                Text(offer.title,
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                _buildPriceSection(offer),
                                const SizedBox(height: 10),
                                _buildOfferSection(offer),
                                const SizedBox(height: 20),
                                const Text('Description:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Text(offer.description,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(height: 20),
                                _buildActionButtons(offer),
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
                              height: 400,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: offer.images.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    offer.images[index],
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
                              count: offer.images.length,
                              effect: const WormEffect(
                                dotWidth: 8,
                                dotHeight: 7,
                                activeDotColor: Colors.green,
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(offer.title,
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildPriceSection(offer),
                          const SizedBox(height: 10),
                          _buildOfferSection(offer),
                          const SizedBox(height: 20),
                          const Text('Description:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(offer.description,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 20),
                          _buildActionButtons(offer),
                        ],
                      );
              },
            ),
            const SizedBox(height: 30),
            _buildRelatedProducts(context, widget.offer.productId),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(Offer offer) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    return Row(
      children: [
        Text('Offer Price : ₹${offer.offerPrice. round()}',
            style: TextStyle(
                color: Color.fromARGB(255, 28, 79, 30),
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 22 : 14)),
        const SizedBox(width: 20),
        Text(' ₹${offer.actualPrice. round()}',
            style: TextStyle(
                color: Colors.red,
                fontSize: isTablet ? 22 : 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.black)),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildOfferSection(Offer offer) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _discountTag(
            'SAVE ! ${(((offer.actualPrice - offer.offerPrice) / offer.actualPrice) * 100).round()}%',
            Colors.green),
        Text('Per Unit: ${offer.unit}',
            style: TextStyle(
                fontSize: isTablet ? 18 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
        _discountTag(
            '₹${(offer.actualPrice - offer.offerPrice). round()} Saved',
            Colors.red),
      ],
    );
  }

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

  Widget _buildActionButtons(Offer offer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isAddedToCart
                  ? () => Navigator.pushNamed(context, '/cart')
                  : (offer.stock > 0
                      ? () async {
                          setState(() => _isAddingToCart = true);

                          final success = await _addToCart(context, offer);

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
                    ? const Color.fromARGB(255, 225, 204, 15)
                    : (offer.stock > 0 ? Colors.orange : Colors.grey),
                padding: const EdgeInsets.all(14),
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
                          : (offer.stock > 0 ? 'ADD TO CART' : 'OUT OF STOCK'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  offer.stock > 0 ? () => _handleBuyNow(context, offer) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: offer.stock > 0 ? Colors.green : Colors.grey,
                padding: const EdgeInsets.all(14),
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

  Widget _buildRelatedProducts(BuildContext context, String productId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

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
                child: CircularProgressIndicator(color: Colors.green),
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
              height: isTablet ? 420 : 220, // allow space for full card
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: relatedOffers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final relatedOffer = relatedOffers[index];

                  return SizedBox(
                    width: isTablet ? 300 : 190,
                    child: MyOfferWidget(
                      offer: relatedOffer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(offer: relatedOffer),
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
