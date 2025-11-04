
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services/wishlist_service.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WishlistManager extends ChangeNotifier {
  final Set<String> _wishlist = {};
  final Set<String> _loadingItems = {};
  Set<String> get wishlist => _wishlist;
  Set<String> get loadingItems => _loadingItems;

  bool isLoadingFor(String productId) => _loadingItems.contains(productId);
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await _loadWishlistFromPreferences();
    await _fetchWishlistFromAPI();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchWishlistFromAPI() async {
    try {
      final wishlistItems = await WishlistService.getWishlistItems();
      _wishlist.clear();
      _wishlist.addAll(wishlistItems.map((item) => item['_id'] as String));
      await _saveWishlist(); // Save to local storage
      notifyListeners();
    } catch (e) {
      print('Error fetching wishlist from API: $e');
    }
  }

  /// Save wishlist locally in SharedPreferences
  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist', _wishlist.toList());
  }

  /// Load wishlist from SharedPreferences
  Future<void> _loadWishlistFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWishlist = prefs.getStringList('wishlist') ?? [];
    _wishlist.clear();
    _wishlist.addAll(savedWishlist);
    notifyListeners();
  }

  bool isInWishlist(String productId) {
    return _wishlist.contains(productId);
  }

  Future<void> toggleWishlist(String productId, BuildContext context) async {
    if (_loadingItems.contains(productId)) return; // prevent multiple taps
    _loadingItems.add(productId);
    notifyListeners();

    final alreadyInWishlist = isInWishlist(productId);

    try {
      if (alreadyInWishlist) {
        await WishlistService.removeFromWishlist(productId);
        _wishlist.remove(productId);
        showTopSnackBar(context, "Removed from wishlist");
      } else {
        await WishlistService.addToWishlist(productId);
        _wishlist.add(productId);
        showTopSnackBar(context, "Added to wishlist");
      }

      await _saveWishlist();
    } catch (e) {
      print("Error updating wishlist: $e");
      showTopSnackBar(context, "Error updating wishlist");
      // 👆 state not changed if API fails
    } finally {
      _loadingItems.remove(productId);
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(
      String productId, BuildContext context) async {
    try {
      await WishlistService.removeFromWishlist(productId);
      _wishlist.remove(productId);
      await _saveWishlist();
      notifyListeners();
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  Future<void> clearWishlist() async {
    _wishlist.clear();
    await _saveWishlist(); // Save the cleared state locally
    notifyListeners();
  }
}
