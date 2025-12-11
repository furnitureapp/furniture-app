import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/offers_service.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/offer/offer_detail.dart';
import 'package:shimmer/shimmer.dart';

class OfferGridWidget extends StatefulWidget {
  const OfferGridWidget({super.key});

  @override
  State<OfferGridWidget> createState() => _OfferGridWidgetState();
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

  Widget offerCardShimmer(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Shimmer.fromColors(
              baseColor: const Color.fromARGB(255, 230, 226, 226),
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
              ),
            ),
          ),

          // TEXT SHIMMER
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Price Row
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 50,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description Line 1
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Description Line 2
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        _cardWidth = isTablet ? 405 : constraints.maxWidth - 32;
        final double cardHeight = isTablet ? 400 : 250;

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/b.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: FutureBuilder<List<Offer>>(
            future: _offersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: cardHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _horizontalPadding,
                          vertical: _verticalPadding,
                        ),
                        child: SizedBox(
                          width: _cardWidth,
                          child: offerCardShimmer(context),
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
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No offers found'));
              } else {
                final offers = snapshot.data!;
                _offersLength = offers.length;
                print(_offersLength);
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
                                color: mythemecolor,
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
                                color: mythemecolor,
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
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: Colors.white,
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
                    fit: BoxFit.contain,
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
                        fontSize: 14,
                        color: mythemecolor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₹ ${offer.offerPrice.round()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: mythemecolor,
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
                    fontSize: 10,
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
