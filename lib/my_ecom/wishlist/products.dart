import 'package:flutter/material.dart';
import 'dart:async';

import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/result_screen.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';


class SearchScreens extends StatefulWidget {
  const SearchScreens({super.key});

  @override
  State<SearchScreens> createState() => _SearchScreensState();
}

class _SearchScreensState extends State<SearchScreens> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  List<Product> _suggestions = [];
  String _searchError = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    } else if (_searchController.text.isNotEmpty && _suggestions.isNotEmpty) {
      _showOverlay();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isNotEmpty) {
        _searchProducts(query);
      } else {
        setState(() => _suggestions = []);
        _removeOverlay();
      }
    });
  }

  Future<void> _searchProducts(String query) async {
    try {
      final results = await ApiService.searchWithRelated(query);
      setState(() => _suggestions = results);
      if (_focusNode.hasFocus && _suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (_) {
      setState(() => _suggestions = []);
      _removeOverlay();
    }
  }

  void _navigateToResultScreen(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchError = 'Please enter a search item to proceed..');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _searchError = '');
      });
    } else {
      _removeOverlay();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(query: query)),
      );
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 65),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
                minHeight: _suggestions.isEmpty ? 0 : 100,
              ),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: true,
                  overscroll: false,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 8,
                  radius: const Radius.circular(6),
                  interactive: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final product = _suggestions[index];
                      return ListTile(
                        leading: product.images.isNotEmpty
                            ? Image.network(
                                product.images[0],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image, size: 50),
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(
                          product.title,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '₹${product.offerPrice. round()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          _removeOverlay();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPagep(
                                product: product,
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      overlay.insert(_overlayEntry!);
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? const Color.fromARGB(255, 65, 138, 67)
                      : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
              ),
              child: TextField(
                cursorColor: Colors.grey,
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _navigateToResultScreen,
                decoration: InputDecoration(
                  hoverColor: Colors.grey,
                  hintText: 'Search for product title, category, subtypes ....',
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search,
                                  color: Color.fromARGB(255, 55, 55, 55)),
                              onPressed: () => _navigateToResultScreen(
                                  _searchController.text.trim()),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear,
                                  color: Color.fromARGB(255, 55, 55, 55)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _suggestions = [];
                                  _searchError = '';
                                });
                                _removeOverlay();
                              },
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(Icons.search,
                              color: Color.fromARGB(255, 55, 55, 55)),
                          onPressed: () => _navigateToResultScreen(
                              _searchController.text.trim()),
                        ),
                ),
              ),
            ),
            if (_searchError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchError,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 58, 57, 57),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/navbar/result_screen.dart';
// import 'package:model_app/product/product_detail.dart';

// class SearchScreens extends StatefulWidget {
//   const SearchScreens({super.key});

//   @override
//   State<SearchScreens> createState() => _SearchScreensState();
// }

// class _SearchScreensState extends State<SearchScreens> {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;
//   Timer? _debounce;

//   List<Product> _suggestions = [];
//   String _searchError = '';
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(_handleFocusChange);
//   }

//   void _handleFocusChange() {
//     if (!_focusNode.hasFocus) {
//       _removeOverlay();
//     } else if (_searchController.text.isNotEmpty && _suggestions.isNotEmpty) {
//       _showOverlay();
//     }
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (query.isNotEmpty) {
//         _searchProducts(query);
//       } else {
//         setState(() => _suggestions = []);
//         _removeOverlay();
//       }
//     });
//   }

//   Future<void> _searchProducts(String query) async {
//     try {
//       final results = await ApiService.searchWithRelated(query);
//       setState(() => _suggestions = results);
//       if (_focusNode.hasFocus && _suggestions.isNotEmpty) {
//         _showOverlay();
//       } else {
//         _removeOverlay();
//       }
//     } catch (_) {
//       setState(() => _suggestions = []);
//       _removeOverlay();
//     }
//   }

//   void _navigateToResultScreen(String query) {
//     if (query.trim().isEmpty) {
//       setState(() => _searchError = 'Please enter a search item to proceed..');
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) setState(() => _searchError = '');
//       });
//     } else {
//       _removeOverlay();
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => ResultScreen(query: query)),
//       );
//     }
//   }

//   void _showOverlay() {
//     _removeOverlay();
//     final overlay = Overlay.of(context);

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         width: 600,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: const Offset(0, 65),
//           child: Material(
//             elevation: 4,
//             borderRadius: BorderRadius.circular(8),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.4,
//               ),
//               child: Scrollbar(
//                 controller: _scrollController,
//                 thickness: 8,
//                 trackVisibility: true,
//                 radius: const Radius.circular(8),
//                 child: ListView.builder(
//                   controller: _scrollController,
//                   padding: EdgeInsets.zero,
//                   itemCount: _suggestions.length,
//                   itemBuilder: (context, index) {
//                     final product = _suggestions[index];
//                     return ListTile(
//                       leading: product.images.isNotEmpty
//                           ? Image.network(
//                               product.images[0],
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const Icon(Icons.image, size: 50),
//                             )
//                           : const Icon(Icons.image, size: 50),
//                       title: Text(
//                         product.title,
//                         style: const TextStyle(
//                             fontSize: 12, fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text(
//                         '₹${product.offerPrice. round()}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onTap: () {
//                         _removeOverlay();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => ProductDetailPagep(
//                               product: product,
//                               productId: product.id,
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       overlay.insert(_overlayEntry!);
//     });
//   }

//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _scrollController.dispose();

//     _debounce?.cancel();
//     _focusNode.dispose();
//     _removeOverlay();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: _focusNode.hasFocus
//                       ? const Color.fromARGB(255, 65, 138, 67)
//                       : const Color(0xFFE0E0E0),
//                   width: 1.5,
//                 ),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 focusNode: _focusNode,
//                 onChanged: _onSearchChanged,
//                 onSubmitted: _navigateToResultScreen,
//                 decoration: InputDecoration(
//                   hintText: 'Search for product title, category, subtypes ....',
//                   hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
//                   border: InputBorder.none,
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                   suffixIcon: _searchController.text.isNotEmpty
//                       ? Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.search,
//                                   color: Color.fromARGB(255, 55, 55, 55)),
//                               onPressed: () => _navigateToResultScreen(
//                                   _searchController.text.trim()),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.clear,
//                                   color: Color.fromARGB(255, 55, 55, 55)),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 setState(() {
//                                   _suggestions = [];
//                                   _searchError = '';
//                                 });
//                                 _removeOverlay();
//                               },
//                             ),
//                           ],
//                         )
//                       : IconButton(
//                           icon: const Icon(Icons.search,
//                               color: Color.fromARGB(255, 55, 55, 55)),
//                           onPressed: () => _navigateToResultScreen(
//                               _searchController.text.trim()),
//                         ),
//                 ),
//               ),
//             ),
//             if (_searchError.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     _searchError,
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 58, 57, 57),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/navbar/result_screen.dart';
// import 'package:model_app/product/product_detail.dart';

// class SearchScreens extends StatefulWidget {
//   const SearchScreens({super.key});

//   @override
//   State<SearchScreens> createState() => _SearchScreensState();
// }

// class _SearchScreensState extends State<SearchScreens> {
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   List<Product> _suggestions = [];
//   String _searchError = '';
//   bool _isFocused = false;
//   final FocusNode _focusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(() {
//       setState(() {
//         _isFocused = _focusNode.hasFocus;
//       });
//     });
//   }

//   void _navigateToResultScreen(String query) {
//     if (query.trim().isEmpty) {
//       setState(() {
//         _searchError = 'Please enter a search item to proceed..';
//       });
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           setState(() {
//             _searchError = '';
//           });
//         }
//       });
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResultScreen(query: query),
//         ),
//       );
//     }
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (query.isNotEmpty) {
//         _searchProducts(query);
//       } else {
//         setState(() {
//           _suggestions = [];
//         });
//       }
//     });
//   }

//   Future<void> _searchProducts(String query) async {
//     try {
//       final results = await ApiService.searchWithRelated(query);
//       setState(() {
//         _suggestions = results;
//       });
//     } catch (e) {
//       setState(() {
//         _suggestions = [];
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _debounce?.cancel();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: _isFocused
//                         ? const Color.fromARGB(255, 65, 138, 67)
//                         : const Color(0xFFE0E0E0),
//                     width: 1.5,
//                   ),
//                 ),
//                 child: TextField(
//                   cursorColor: Colors.grey,
//                   focusNode: _focusNode,
//                   controller: _searchController,
//                   onChanged: _onSearchChanged,
//                   decoration: InputDecoration(
//                     hintText:
//                         'Search for product title, category, subtypes ....',
//                     hintStyle:
//                         const TextStyle(fontSize: 12, color: Colors.grey),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 14),
//                     suffixIcon: _searchController.text.isNotEmpty
//                         ? SizedBox(
//                             width: 96,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.search,
//                                       color: Color.fromARGB(255, 55, 55, 55)),
//                                   onPressed: () {
//                                     final query = _searchController.text.trim();
//                                     _navigateToResultScreen(query);
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.clear,
//                                       color: Color.fromARGB(255, 55, 55, 55)),
//                                   onPressed: () {
//                                     _searchController.clear();
//                                     setState(() {
//                                       _suggestions = [];
//                                       _searchError = '';
//                                     });
//                                   },
//                                 ),
//                               ],
//                             ),
//                           )
//                         : IconButton(
//                             icon: const Icon(Icons.search,
//                                 color: Color.fromARGB(255, 55, 55, 55)),
//                             onPressed: () {
//                               final query = _searchController.text.trim();
//                               _navigateToResultScreen(query);
//                             },
//                           ),
//                   ),
//                 ),
//               ),
//               if (_searchError.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       _searchError,
//                       style: const TextStyle(
//                           color: Color.fromARGB(255, 58, 57, 57),
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         if (_searchController.text.isNotEmpty && _suggestions.isNotEmpty)
//           Material(
//             elevation: 4,
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 5,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               constraints: BoxConstraints(
//                 maxHeight: MediaQuery.of(context).size.height * 0.4,
//               ),
//               child: Scrollbar(
//                 thickness: 8,
//                 thumbVisibility: true,
//                 trackVisibility: true,
//                 radius: const Radius.circular(8),
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   shrinkWrap: true,
//                   itemCount: _suggestions.length,
//                   itemBuilder: (context, index) {
//                     final product = _suggestions[index];
//                     return ListTile(
//                       leading: product.images.isNotEmpty
//                           ? Image.network(
//                               product.images[0],
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   const Icon(Icons.image, size: 50),
//                             )
//                           : const Icon(Icons.image, size: 50),
//                       title: Text(
//                         product.title,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Text(
//                         '₹${product.offerPrice. round()}',
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ProductDetailPagep(
//                               product: product,
//                               productId: product.id,
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
