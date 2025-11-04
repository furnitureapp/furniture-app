import 'dart:async';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/search_service.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/result_screen.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String? _errorText;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  List<Product> _searchSuggestions = [];
  Timer? _debounceTimer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchController.text.isNotEmpty) {
        _fetchSearchSuggestions(searchController.text);
      } else {
        setState(() {
          _searchSuggestions = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await SearchService.searchProductsWithRelated(query);
      setState(() {
        _searchSuggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchSuggestions = [];
        _isLoading = false;
        _errorText = "";
      });
    }
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      _searchSuggestions = [];
      _errorText = null;
    });
    _focusNode.unfocus();
  }

  void navigateToResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _errorText = null;
        _searchSuggestions = [];
      });
      _focusNode.unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(query: query)),
      ).then((_) {
        searchController.clear();
      });
    } else {
      setState(() {
        _errorText = "Please enter a search item and proceed!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? mythemecolor
                      : Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                ),
              ],
              border: Border.all(
                color: _isFocused
                    ? mythemecolor
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Search by Products, category, title, price..',
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 102, 104, 102),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String query = searchController.text.trim();
                    navigateToResults(query);
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 28,
                    color: mythemecolor
                  ),
                ),
              ],
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                _errorText!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 246, 95, 85),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_searchSuggestions.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: _searchSuggestions.length,
                itemBuilder: (context, index) {
                  final product = _searchSuggestions[index];

                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '₹${product.offerPrice.round()}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        print("Tapped product ID: ${product.id}");

                        _focusNode.unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPagep(
                              product: product,
                              productId: product.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
