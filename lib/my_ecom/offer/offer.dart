import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_detail.dart';

class OfferGridWidget extends StatefulWidget {
  const OfferGridWidget({super.key});

  @override
  _OfferGridWidgetState createState() => _OfferGridWidgetState();
}

class _OfferGridWidgetState extends State<OfferGridWidget> {
  late Future<List<Offer>> _offersFuture;
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  int _offersLength = 0;
  double _cardWidth = 0;
  final double _horizontalPadding = 8.0;
  final double _verticalPadding = 8.0;

  @override
  void initState() {
    super.initState();
    _offersFuture = ApiService().fetchOffers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _scrollToIndex(_currentIndex);
    }
  }

  void _scrollRight() {
    if (_currentIndex < _offersLength - 1) {
      setState(() {
        _currentIndex++;
      });
      _scrollToIndex(_currentIndex);
    }
  }

  void _scrollToIndex(int index) {
    final double offset = index * (_cardWidth + _horizontalPadding * 2);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        _cardWidth = isTablet ? 405 : constraints.maxWidth - 32;

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const NetworkImage(
                'https://static.vecteezy.com/system/resources/previews/020/621/774/original/green-vegetable-seamless-pattern-organic-food-background-fresh-doodle-wallpaper-vector.jpg',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
          child: FutureBuilder<List<Offer>>(
            future: _offersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: isTablet ? 380 : 270, 
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _horizontalPadding),
                        child: Container(
                          width: _cardWidth,
                          height: isTablet ? 380 : 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                BorderRadius.circular(8), 
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No offers found'));
              } else {
                final offers = snapshot.data!;
                _offersLength = offers.length;

                return SizedBox(
                  height: isTablet ? 400 : 250, 
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: _horizontalPadding,
                                vertical: _verticalPadding),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailPage(offer: offer),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: _cardWidth,
                                child: _OfferCard(offer: offer),
                              ),
                            ),
                          );
                        },
                      ),
                      if (_currentIndex > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: _scrollLeft,
                                icon: const Icon(Icons.arrow_back_ios),
                                color: const Color(0xFF085B0D),
                                iconSize: 20, 
                              ),
                            ),
                          ),
                        ),
                      if (_currentIndex < _offersLength - 1)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(-2, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: _scrollRight,
                                icon: const Icon(Icons.arrow_forward_ios),
                                color: const Color(0xFF085B0D),
                                iconSize: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final discountPercentage =
        ((offer.actualPrice - offer.offerPrice) / offer.actualPrice) * 100;

    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      color: const Color.fromARGB(255, 246, 252, 246),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                  child: Image.network(
                    offer.images.isNotEmpty ? offer.images[0] : '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                if (offer.actualPrice > offer.offerPrice)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(135, 18, 16, 16)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₹ ${offer.offerPrice. round()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromARGB(255, 26, 100, 28),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  offer.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 132, 131, 131),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


























// import 'package:flutter/material.dart';
// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/cart/cart_provider.dart';
// import 'package:model_app/constants/snackbar.dart';
// import 'package:model_app/offer/offer_detail.dart';
// import 'package:provider/provider.dart';

// class OfferGridWidget extends StatefulWidget {
//   const OfferGridWidget({super.key});

//   @override
//   _OfferGridWidgetState createState() => _OfferGridWidgetState();
// }

// class _OfferGridWidgetState extends State<OfferGridWidget> {
//   late Future<List<Offer>> _offersFuture;
//   final ScrollController _scrollController = ScrollController();

//   int _currentIndex = 0;
//   int _offersLength = 0;

//   @override
//   void initState() {
//     super.initState();
//     _offersFuture = ApiService().fetchOffers();
//   }

//   void _scrollLeft() {
//     setState(() {
//       _currentIndex = (_currentIndex - 1).clamp(0, _maxScrollIndex());
//     });
//     _scrollToIndex(_currentIndex);
//   }

//   void _scrollRight() {
//     setState(() {
//       _currentIndex = (_currentIndex + 1).clamp(0, _maxScrollIndex());
//     });
//     _scrollToIndex(_currentIndex);
//   }

//   void _scrollToIndex(int index) {
//     final double offset = index * _getScrollAmount();
//     _scrollController.animateTo(
//       offset,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   int _maxScrollIndex() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final cardWidth = _getScrollAmount();
//     return (_offersLength - (screenWidth / cardWidth).floor())
//         .clamp(0, _offersLength - 1);
//   }

//   double _getScrollAmount() {
//     bool isTablet = MediaQuery.of(context).size.width > 600;
//     double cardWidth = isTablet ? 270 : MediaQuery.of(context).size.width - 40;
//     double cardPadding = 20;
//     return cardWidth + cardPadding;
//   }

//   Future<void> addToCartItem(Product product, BuildContext context) async {
//     try {
//       final response = await ApiService.addToCart(product, context);
//       await Provider.of<CartProvider>(context, listen: false).fetchCartCount();

//       if (response.containsKey('error')) {
//         showTopSnackBar(context, response['error']);
//       } else {
//         showTopSnackBar(context, "Product Added to Cart!!");
//       }
//     } catch (e) {
//       debugPrint('Error adding item to cart: \$e');
//       showTopSnackBar(context, "An unexpected error occurred");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         bool isTablet = constraints.maxWidth > 600;
//         return Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: const NetworkImage(
//                 'https://static.vecteezy.com/system/resources/previews/020/621/774/original/green-vegetable-seamless-pattern-organic-food-background-fresh-doodle-wallpaper-vector.jpg',
//               ),
//               fit: BoxFit.cover,
//               alignment: isTablet ? Alignment.topCenter : Alignment.center,
//               colorFilter: ColorFilter.mode(
//                 Colors.black.withOpacity(0.5),
//                 BlendMode.darken,
//               ),
//             ),
//           ),
//           child: FutureBuilder<List<Offer>>(
//             future: _offersFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return SizedBox(
//                   height: 350,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: 5,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Container(
//                           width: 270,
//                           height: 350,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: \${snapshot.error}'));
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(child: Text('No offers found'));
//               } else {
//                 final offers = snapshot.data!;
//                 _offersLength = offers.length;

//                 return Stack(
//                   children: [
//                     SizedBox(
//                       height: isTablet
//                           ? MediaQuery.of(context).size.height * 0.5
//                           : 350,
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         scrollDirection: Axis.horizontal,
//                         itemCount: offers.length,
//                         itemBuilder: (context, index) {
//                           final offer = offers[index];
//                           return Padding(
//                             padding: const EdgeInsets.all(10),
//                             child: GestureDetector(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         ProductDetailPage(offer: offer),
//                                   ),
//                                 );
//                               },
//                               child: _OfferCard(offer: offer),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
                  
//                     Positioned(
//                       left: 10,
//                       top: 0,
//                       bottom: 0,
//                       child: Center(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.85),
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black26,
//                                 blurRadius: 4,
//                                 offset: Offset(2, 2),
//                               ),
//                             ],
//                           ),
//                           child: IconButton(
//                             onPressed: _scrollLeft,
//                             icon: const Icon(Icons.arrow_back_ios),
//                             color: const Color(0xFF085B0D),
//                             iconSize: 28,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10,
//                       top: 0,
//                       bottom: 0,
//                       child: Center(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.85),
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black26,
//                                 blurRadius: 4,
//                                 offset: Offset(-2, 2),
//                               ),
//                             ],
//                           ),
//                           child: IconButton(
//                             onPressed: _scrollRight,
//                             icon: const Icon(Icons.arrow_forward_ios),
//                             color: const Color(0xFF085B0D),
//                             iconSize: 28,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _OfferCard extends StatelessWidget {
//   final Offer offer;

//   const _OfferCard({required this.offer});

//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 600;

//     return Card(
//       elevation: 9,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(0),
//       ),
//       color: const Color.fromARGB(255, 246, 252, 246),
//       child: Container(
//         width: isMobile ? MediaQuery.of(context).size.width - 40 : 270,
//         margin: const EdgeInsets.all(0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.all(Radius.circular(0)),
//                 child: Image.network(
//                   offer.images.isNotEmpty ? offer.images[0] : '',
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   errorBuilder: (context, error, stackTrace) => const Center(
//                     child:
//                         Icon(Icons.broken_image, size: 50, color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     offer.title,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     offer.description,
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 132, 131, 131),
//                       fontSize: 12,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '₹${offer.offerPrice. round()}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                       Text(
//                         '₹${offer.price. round()}',
//                         style: const TextStyle(
//                           decoration: TextDecoration.lineThrough,
//                           decorationColor: Color.fromARGB(255, 81, 81, 81),
//                           decorationThickness: 2.5,
//                           color: Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
