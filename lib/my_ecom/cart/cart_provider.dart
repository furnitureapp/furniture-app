
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';

class CartProvider with ChangeNotifier {
    int _cartCount = 0;
  int get cartCount => _cartCount;
  void addProduct() {
    _cartCount++;
    notifyListeners(); 
  }
   void setCartCount(int count) {
    _cartCount = count;
    notifyListeners(); 
  }
  
  void removeProduct() {
  if (_cartCount > 0) {
    _cartCount--;
        if (_cartCount == 0) {
      clearCart(); 
    } else {
      notifyListeners();
    }
  }
}

 Future<void> fetchCartCount() async {
  try {
    final cartData = await ApiService.getCartItems();
    debugPrint("Fetched cart items: $cartData");

    int count = cartData['cartItems']?.length ?? 0;
    debugPrint("New cart count: $count");

    if (_cartCount != count) {
      _cartCount = count;
      notifyListeners(); 
    }
  } catch (e) {
    debugPrint("Error Fetching Cart Count: $e");
    _cartCount = 0;
    notifyListeners();
  }
}



  void clearCart() {
    _cartCount = 0;
    notifyListeners(); 
  }
}