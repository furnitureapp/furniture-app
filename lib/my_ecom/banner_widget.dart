import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  late Future<List<BannerModel>> _banners;
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _banners = ApiService().fetchBanners();
    _startAutoScroll();
  }

  void _startAutoScroll() async {
    final images = await _banners;
    if (images.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double bannerHeight = isTablet ? screenWidth / 4.5 : screenWidth / 2.64;

    return FutureBuilder<List<BannerModel>>(
      future: _banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildBannerPlaceholder(bannerHeight);
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No banner images found'));
        } else {
          final banners = snapshot.data!;

          return Column(
            children: [
              SizedBox(
                width: screenWidth,
                height: bannerHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return GestureDetector(
                      onTap: () {
                        if (banner.page.isNotEmpty) {
                          Navigator.pushNamed(context, banner.page);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: CachedNetworkImage(
                            imageUrl: banner.image,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => _buildBannerPlaceholder(bannerHeight),
                            errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                          ),
                        ),
                      ),
                    );
                  },
                  onPageChanged: (index) {
                    _currentPage = index;
                  },
                ),
              ),
              const SizedBox(height: 5),
              SmoothPageIndicator(
                controller: _pageController,
                count: banners.length,
                effect: WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Colors.green,
                  dotColor: Colors.grey.shade400,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildBannerPlaceholder(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}
















  // // 🔵 **Skeleton Loader for Banner**
  // Widget _buildBannerPlaceholder(double height) {
  //   return Container(
  //     width: double.infinity,
  //     height: height,
  //     margin: const EdgeInsets.symmetric(horizontal: 8.0),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[300],
  //       borderRadius: BorderRadius.circular(16.0),
  //     ),
  //   );
  // }



// import 'dart:async';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:model_app/authentication/api_service.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// class BannerWidget extends StatefulWidget {
//   const BannerWidget({super.key});

//   @override
//   _BannerWidgetState createState() => _BannerWidgetState();
// }

// class _BannerWidgetState extends State<BannerWidget> {
//   late Future<List<String>> _bannerImages;
//   final PageController _pageController = PageController();
//   Timer? _timer;
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _bannerImages = ApiService().fetchBannerImages();
//     _startAutoScroll();
//   }

//   void _startAutoScroll() async {
//     final images = await _bannerImages;
//     if (images.isEmpty) return;
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (_pageController.hasClients) {
//         _currentPage = (_currentPage + 1) % images.length;
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final bool isTablet = screenWidth >= 600;
//     final double bannerHeight = isTablet ? screenWidth / 4.5 : screenWidth / 2.64;

//     return FutureBuilder<List<String>>(
//       future: _bannerImages,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildBannerPlaceholder(bannerHeight);
//         } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('No banner images found'));
//         } else {
//           final images = snapshot.data!;

//           return Column(
//             children: [
//               SizedBox(
//                 width: screenWidth,
//                 height: bannerHeight,
//                 child: PageView.builder(
//                   controller: _pageController,
//                   itemCount: images.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16.0),
//                         child: CachedNetworkImage(
//                           imageUrl: images[index],
//                           fit: BoxFit.fill,
//                           placeholder: (context, url) => _buildBannerPlaceholder(bannerHeight),
//                           errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
//                         ),
//                       ),
//                     );
//                   },
//                   onPageChanged: (index) {
//                     _currentPage = index;
//                   },
//                 ),
//               ),
//               const SizedBox(height: 5),
//               SmoothPageIndicator(
//                 controller: _pageController,
//                 count: images.length,
//                 effect: WormEffect(
//                   dotHeight: 8,
//                   dotWidth: 8,
//                   activeDotColor: Colors.green,
//                   dotColor: Colors.grey.shade400,
//                 ),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }
// Widget _buildBannerPlaceholder(double height) {
//   return Shimmer.fromColors(
//     baseColor: Colors.grey[300]!,
//     highlightColor: Colors.grey[100]!,
//     child: Container(
//       width: double.infinity,
//       height: height,
//       margin: const EdgeInsets.symmetric(horizontal: 8.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//     ),
//   );
// }


















//   // // 🔵 **Skeleton Loader for Banner**
//   // Widget _buildBannerPlaceholder(double height) {
//   //   return Container(
//   //     width: double.infinity,
//   //     height: height,
//   //     margin: const EdgeInsets.symmetric(horizontal: 8.0),
//   //     decoration: BoxDecoration(
//   //       color: Colors.grey[300],
//   //       borderRadius: BorderRadius.circular(16.0),
//   //     ),
//   //   );
//   // }
// }
