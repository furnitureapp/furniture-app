import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/cart_service.dart';
import 'package:furniture_ecom_app/core/services/offers_service.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_reuable.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_confirmationpage.dart';

import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailPage extends StatefulWidget {
  final Offer offer;
  const ProductDetailPage({super.key, required this.offer});

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

  void _handleBuyNow(BuildContext context, Offer offer) async {
    final product = Product(
      id: offer.product.id,
      title: offer.title,
      price: offer.actualPrice,
      offerPrice: offer.offerPrice,
      description: offer.description,
      images: offer.images,
      stock: offer.product.stock,
      gstPercentage: offer.gstPercentage,
      measurement: offer.measurement,
      size: offer.size,
      weight: offer.weight,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderConfirmationPage(product: product, offerId: offer.id),
      ),
    );
  }

  Future<bool> _addToCart(BuildContext context, Offer offer) async {
    if (isAddedToCart) return true;

    setState(() {
      isAddedToCart = true;
    });

    try {
      final product = Product(
        id: offer.product.id,
        title: offer.title,
        price: offer.actualPrice,
        offerPrice: offer.offerPrice,
        description: offer.description,
        images: offer.images,
        stock: offer.product.stock,
        gstPercentage: offer.gstPercentage,
        measurement: offer.measurement,
        size: offer.size,
        weight: offer.weight,
      );

      final response = await CartService.addToCart(product, context);

      if (response.containsKey('error') && response['error'] != null) {
        if (!mounted) {
          return false;
        } else {
          showTopSnackBar(context, response['error']);
        }

        setState(() {
          isAddedToCart = false;
        });
        return false;
      } else {
        await Provider.of<CartProvider>(
          context,
          listen: false,
        ).fetchCartCount();

        showTopSnackBar(
          context,
          response['message'] ?? "Product Added to Cart!!",
        );
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
        context,
        "Failed to add product to cart. Please try again.",
      );
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
              colors: [mythemecolor1, mythemecolor],
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
              child: Text('Failed to load product: ${snapshot.error}'),
            );
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
                        activeDotColor: mythemecolor,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPriceSection(offer),
                  // const SizedBox(height: 16),
                  // _buildOfferSection(offer),
                  const SizedBox(height: 20),
                  _buildAttributesSection(offer),

                  const Text(
                    'DESCRIPTION:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color:  Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(offer.description, style: const TextStyle(fontSize: 12, color:  Colors.grey)),
                  const SizedBox(height: 20),
                  _buildRelatedProducts(context, widget.offer.product.id),
                ],
              ),
            ),
          ),
        ),
        SafeArea(bottom: true, child: _buildActionButtons(offer)),
      ],
    );
  }

  Widget _buildPriceSection(Offer offer) {
  final screenWidth = MediaQuery.of(context).size.width;
  final bool isTablet = screenWidth > 600;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // OFFER PRICE
      Row(
        children: [
          Text(
            "₹${offer.offerPrice.round()}",
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
              "${(((offer.actualPrice - offer.offerPrice) / offer.actualPrice) * 100).round()}% OFF",
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
            "MRP: ₹${offer.actualPrice.round()}",
            style: TextStyle(
              fontSize: isTablet ? 16 : 13,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "You Save ₹${(offer.actualPrice - offer.offerPrice).round()}",
            style: TextStyle(
              fontSize: isTablet ? 16 : 13,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 10),

      // PREMIUM TAGS
      Row(
        children: [
          _premiumTag(Icons.local_offer, "Best Price"),
          const SizedBox(width: 8),
          _premiumTag(Icons.shield, "100% Genuine"),
          const SizedBox(width: 8),
          _premiumTag(Icons.workspace_premium, "Premium Quality"),
        ],
      ),
    ],
  );
}

  Widget _premiumTag(IconData icon, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.black87),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}


  // Widget _buildPriceSection(Offer offer) {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final bool isTablet = screenWidth > 600;
  //   return Row(
  //     children: [
  //       Text(
  //         'Offer Price : ₹${offer.offerPrice.round()}',
  //         style: TextStyle(
  //           color: const Color.fromARGB(255, 70, 56, 83),
  //           fontWeight: FontWeight.bold,
  //           fontSize: isTablet ? 22 : 14,
  //         ),
  //       ),
  //       const SizedBox(width: 20),
  //       Text(
  //         ' ₹${offer.actualPrice.round()}',
  //         style: TextStyle(
  //           color: const Color.fromARGB(255, 94, 90, 90),
  //           fontSize: isTablet ? 22 : 14,
  //           fontWeight: FontWeight.bold,
  //           decoration: TextDecoration.lineThrough,
  //           decorationColor: Colors.black,
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //         _discountTag(
  //         'SAVE ! ${(((offer.actualPrice - offer.offerPrice) / offer.actualPrice) * 100).round()}%',
  //         mythemecolor,
  //       ),
  //       const SizedBox(width: 10),
  //       _discountTag(
  //         '₹${(offer.actualPrice - offer.offerPrice).round()} Saved',
  //         mythemecolor1,
  //       ),
  //     ],
  //   );
  // }


  // Widget _discountTag(String text, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.all(5),
  //     decoration: BoxDecoration(
  //       color: color,
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Text(
  //       text,
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 12,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAttributesSection(Offer offer) {
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
          offer.measurement.isNotEmpty ? offer.measurement : "N/A",
        ),
        _infoRow("Size", offer.size.isNotEmpty ? offer.size : "N/A"),
        _infoRow("Weight", offer.weight.isNotEmpty ? offer.weight : "N/A"),
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
                  : (offer.product.stock > 0
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
                    ? mythemecolor
                    : (offer.product.stock > 0
                          ? const Color.fromARGB(255, 199, 180, 119)
                          : Colors.grey),
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
                          : (offer.product.stock > 0
                                ? 'ADD TO CART'
                                : 'OUT OF STOCK'),
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
              onPressed: offer.product.stock > 0
                  ? () => _handleBuyNow(context, offer)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: offer.product.stock > 0
                    ? mythemecolor
                    : Colors.grey,
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
              height: isTablet ? 420 : 250,
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
                                  offer.title,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildPriceSection(offer),
                                // const SizedBox(height: 10),
                                // _buildOfferSection(offer),
                                const SizedBox(height: 20),
                                _buildAttributesSection(offer),

                                const Text(
                                  'Description:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  offer.description,
                                  style: const TextStyle(fontSize: 20, color:  Colors.grey),
                                ),
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
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildPriceSection(offer),
                          // const SizedBox(height: 10),
                          // _buildOfferSection(offer),
                          const SizedBox(height: 20),
                          const Text(
                            'DESCRIPTION:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            offer.description,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                          _buildActionButtons(offer),
                        ],
                      );
              },
            ),
            const SizedBox(height: 30),
            _buildRelatedProducts(context, widget.offer.product.id),
          ],
        ),
      ),
    );
  }
}
