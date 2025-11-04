import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/offers_service.dart';
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
    _offersFuture = OfferService.fetchOffers();
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
              // image: const NetworkImage(
              //   'https://www.google.com/url?sa=i&url=https%3A%2F%2Fhtmlcolorcodes.com%2Fcolors%2Fdark-purple%2F&psig=AOvVaw2uPeRzx01OS8ZuCjvmwuTP&ust=1762086791480000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCPDngZX70JADFQAAAAAdAAAAABAE',
              // ),
              image: AssetImage('assets/images/offerback.png'),
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
                          horizontal: _horizontalPadding,
                        ),
                        child: Container(
                          width: _cardWidth,
                          height: isTablet ? 380 : 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/no_offer.jpg',
                        width: 200,
                        height: 200,
                        fit: BoxFit.fitWidth,
                      ),
                      // const SizedBox(height: 10),
                      // const Text(
                      //   'No offers available right now!',
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.grey,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ],
                  ),
                );
                // return Center(child: Text('Error: ${snapshot.error}'));
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
                              vertical: _verticalPadding,
                            ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: const Color.fromARGB(255, 246, 252, 246),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  child: Image.network(
                    offer.images.isNotEmpty ? offer.images[0] : '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (offer.actualPrice > offer.offerPrice)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
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
                        color: Color.fromARGB(135, 18, 16, 16),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₹ ${offer.offerPrice.round()}',
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
