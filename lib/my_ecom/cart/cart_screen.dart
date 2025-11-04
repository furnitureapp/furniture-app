import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/cart_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation2.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_summary.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });

    if (_isLoggedIn) {
      await _fetchCartItems();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCartItems() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final cartData = await CartService.getCartItems();
      log('Cart Data: $cartData');
      if (!mounted) return;
      setState(() {
        Provider.of<CartProvider>(context, listen: false).fetchCartCount();
        _cartItems = cartData['cartItems'] ?? [];
        _totalAmount = cartData['quote']['totalAmount']?.toDouble() ?? 0.0;
      });
    } catch (e, stackTrace) {
      log('Error fetching cart: $e', stackTrace: stackTrace);
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('No Items in cart')),
        // );
        showTopSnackBar(context, 'No Items in cart');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeItemFromCart(String productId) async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      log('Removing product with ID: $productId');
      await CartService.removeFromCart(productId);
      if (!mounted) return;

      Provider.of<CartProvider>(context, listen: false).fetchCartCount();
      setState(() {
        _cartItems.removeWhere((item) => item.productId == productId);
        _totalAmount = _cartItems.fold(
            0.0, (sum, item) => sum + item.offerPrice * item.quantity);
        Provider.of<CartProvider>(context, listen: false).fetchCartCount();
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Item removed from cart')),
      // );
      showTopSnackBar(context, 'Item removed from cart');
    } catch (e, stackTrace) {
      log('Error removing item from cart: $e', stackTrace: stackTrace);
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Failed to remove item from cart')),
        // );
        showTopSnackBar(context, 'Failed to remove item from cart');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0 || !mounted) return;

    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index == -1) return;

    final item = _cartItems[index];

    if (newQuantity > item.stock) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Only ${item.stock} items are in stock.')),
      // );
      showTopSnackBar(context, 'Only ${item.stock} items are in stock.');
      return;
    }
    setState(() {
      final perItemGSTTotal = item.offerPrice * (1 + item.gstPercentage / 100);

      _cartItems[index] = item.copyWith(
        quantity: newQuantity,
        isUpdating: true,
        totalWithGST: perItemGSTTotal * newQuantity,
      );

      _totalAmount = _cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalWithGST,
      );
    });

    try {
      await CartService.updateCartQuantity(productId, newQuantity);

      final cartData = await CartService.getCartItems();
      final updatedItems = cartData['cartItems'] as List<CartItem>;
      final quote = cartData['quote'] as Map<String, dynamic>;

      setState(() {
        _cartItems = updatedItems;
        _totalAmount = (quote['totalAmount'] ?? 0.0).toDouble();
      });

      Provider.of<CartProvider>(context, listen: false).fetchCartCount();
    } catch (e, stackTrace) {
      log('Error updating quantity: $e', stackTrace: stackTrace);

      showTopSnackBar(context, 'Failed to update quantity. Please try again.');

      setState(() {
        _cartItems[index] = item.copyWith(quantity: item.quantity); // revert
      });
    } finally {
      if (mounted) {
        setState(() {
          _cartItems[index] =
              _cartItems[index].copyWith(isUpdating: false); // remove loader
        });
      }
    }
  }

  bool _hasOutOfStockItems() {
    return _cartItems.any((item) => item.stock == 0);
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    if (_isLoading) {
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
                "My Cart",
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
        body: const Center(child: AnimationPage2()),
      );
    }

    if (!_isLoggedIn) {
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
                "My Cart",
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
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                isTablet ? 'assets/images/bbc.png' : 'assets/images/bbc.png',
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 40 : 20),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 30 : 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green.shade100,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!isTablet) const SizedBox(height: 5),
                        Image.asset(
                          'assets/images/emt.png',
                          height: isTablet ? 210 : 150,
                          width: isTablet ? 190 : 130,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          "You are not logged in!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Stay Logged to see your Cart Items!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('redirectRoute', '/cart');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isTablet ? Colors.white : Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 40 : 30,
                              vertical: isTablet ? 14 : 12,
                            ),
                            textStyle: TextStyle(
                              fontSize: isTablet ? 18 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                            foregroundColor:
                                isTablet ? Colors.green.shade700 : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Go To Login"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
              "My Cart",
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
      body: _cartItems.isEmpty
          ? Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    isTablet
                        ? 'assets/images/bbc.png'
                        : 'assets/images/bbc.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 40 : 20),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 30 : 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green.shade100,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/emt.png',
                              height: 210,
                              width: 190,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Your Cart is Empty!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Please do shop & add items to cart!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BottomNavBar(),
                                ),
                                (route) => false,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isTablet ? Colors.white : Colors.green,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 40 : 30,
                                  vertical: isTablet ? 14 : 12,
                                ),
                                textStyle: TextStyle(
                                  fontSize: isTablet ? 18 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                foregroundColor: isTablet
                                    ? Colors.green.shade700
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Go To Shop"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : isTablet
              ? _buildCartUITablet()
              : _buildCartUI(),
    );
  }

  Widget _buildCartUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchCartItems(),
              color: const Color.fromARGB(255, 13, 75, 15),
              backgroundColor: const Color.fromARGB(255, 245, 240, 242),
              displacement: 40,
              strokeWidth: 2.5,
              child: ListView.builder(
                itemCount: _cartItems.length,
                itemBuilder: (context, index) {
                  final item = _cartItems[index];
                  return Card(
                    elevation: 6,
                    color: const Color.fromARGB(255, 242, 254, 242),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPagep(
                                    productId: item.productId,
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    item.productImages,
                                    width: 130,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                if (item.originalPrice > item.offerPrice)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 249, 48, 21),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${(((item.originalPrice - item.offerPrice) / item.originalPrice) * 100).round()}% OFF',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.productTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color:
                                              Color.fromARGB(255, 62, 61, 61),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_sweep,
                                          size: 24,
                                          color:
                                              Color.fromARGB(255, 90, 89, 89)),
                                      onPressed: () =>
                                          _removeItemFromCart(item.productId),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Original Price: ₹${item.offerPrice. round()}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 8, 69, 8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gst Percentage: ${item.gstPercentage. round()}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 8, 69, 8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${(item.offerPrice * item.quantity). round()} + ₹${item.gstAmount. round()} = ₹${item.totalWithGST. round()}',

                                  // '₹${item.offerPrice. round()} + ₹${item.gstAmount. round()} = ₹${item.totalWithGST. round()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Total Amount with Gst: ₹${item.totalWithGST. round()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 8, 69, 8),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    item.stock == 0
                                        ? const Text(
                                            'Out of Stock',
                                            style: TextStyle(color: Colors.red),
                                          )
                                        : Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.red,
                                                    size: 30),
                                                onPressed: item.isUpdating ||
                                                        item.quantity <= 1
                                                    ? null
                                                    : () {
                                                        _updateQuantity(
                                                            item.productId,
                                                            item.quantity - 1);
                                                      },
                                              ),
                                              const SizedBox(width: 10),
                                              item.isUpdating
                                                  ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: mythemecolor,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                              const SizedBox(width: 10),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.add_circle,
                                                    color: Colors.green,
                                                    size: 30),
                                                onPressed: item.isUpdating
                                                    ? null
                                                    : () {
                                                        if (item.quantity >=
                                                            item.stock) {
                                                          showTopSnackBar(
                                                              context,
                                                              'Only ${item.stock} items are in stock.');
                                                        } else {
                                                          _updateQuantity(
                                                              item.productId,
                                                              item.quantity +
                                                                  1);
                                                        }
                                                      },

                                                // onPressed: item.isUpdating ||
                                                //         item.quantity >=
                                                //             item.stock
                                                //     ? null
                                                //     : () {
                                                //         _updateQuantity(
                                                //             item.productId,
                                                //             item.quantity + 1);
                                                //       },
                                              ),
                                            ],
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            bottom: true,
            child: Column(
              children: [
                if (_hasOutOfStockItems())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                    child: Text(
                      "Some items in your cart are out of stock.\n Please remove them to proceed!!",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 104, 102, 102),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${_totalAmount. round()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 10, 70, 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _hasOutOfStockItems()
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrderSummary(),
                                ),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("CONTINUE"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartUITablet() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: _cartItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 20,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return Stack(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(35.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPagep(
                                      productId: item.productId,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.productImages,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.productTitle,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Original Price: ₹${item.offerPrice. round()}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gst Percentage: ${item.gstPercentage. round()}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${(item.offerPrice * item.quantity). round()} + ₹${item.gstAmount. round()} = ₹${item.totalWithGST. round()}',

                                    // '₹${item.offerPrice. round()} + ₹${item.gstAmount. round()} = ₹${item.totalWithGST. round()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Total Amount with Gst: ₹${item.totalWithGST. round()}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 8, 69, 8),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Save: ₹${item.savings. round()}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  item.stock == 0
                                      ? const Text(
                                          'Out of Stock',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 225, 115, 12),
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 14),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (item.quantity > 1) {
                                                        _updateQuantity(
                                                            item.productId,
                                                            item.quantity - 1);
                                                      }
                                                    },
                                                    child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 28),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Text(
                                                    '${item.quantity}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _updateQuantity(
                                                          item.productId,
                                                          item.quantity + 1);
                                                    },
                                                    child: const Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 28),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (item.originalPrice >
                                                item.offerPrice)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 249, 48, 21),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  '${(((item.originalPrice - item.offerPrice) / item.originalPrice) * 100).round()}% OFF',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 40,
                      child: GestureDetector(
                        onTap: () => _removeItemFromCart(item.productId),
                        child: const Icon(
                          Icons.delete_sweep,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                if (_hasOutOfStockItems())
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      "Some items in your cart are out of stock. Please remove them to proceed!",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 248, 103, 93),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${_totalAmount. round()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: _hasOutOfStockItems()
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrderSummary(),
                                ),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("CONTINUE"),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


  


   // child: Center(
                  //   child: Card(
                  //     elevation: 10,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     margin: EdgeInsets.symmetric(
                  //       horizontal: isTablet ? 40 : 20,
                  //       vertical: isTablet ? 20 : 0,
                  //     ),
                  //     child: Container(
                  //       padding: EdgeInsets.all(isTablet ? 30 : 20),
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(20),
                  //         color: isTablet ? null : Colors.green.shade100,
                  //         gradient: isTablet
                  //             ? LinearGradient(
                  //                 colors: [
                  //                   Colors.green.shade300,
                  //                   Colors.green.shade700
                  //                 ],
                  //                 begin: Alignment.topLeft,
                  //                 end: Alignment.bottomRight,
                  //               )
                  //             : null,
                  //       ),
                  //       child: Column(
                  //         mainAxisSize: MainAxisSize.min,
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           Image.asset(
                  //             'assets/images/cc.png',
                  //             width: isTablet ? 450 : 250,
                  //             height: isTablet ? 350 : 250,
                  //           ),
                  //           const SizedBox(height: 20),
                  //           Text(
                  //             "You are not logged in!",
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(
                  //               fontSize: isTablet ? 24 : 18,
                  //               fontWeight: FontWeight.bold,
                  //               color: isTablet ? Colors.white : Colors.black,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 10),
                  //           Text(
                  //             "Login to see your Cart Items",
                  //             textAlign: TextAlign.center,
                  //             style: TextStyle(
                  //               fontSize: isTablet ? 18 : 14,
                  //               color: isTablet
                  //                   ? Colors.white70
                  //                   : Colors.grey.shade700,
                  //             ),
                  //           ),
                  //           const SizedBox(height: 20),
                  //           ElevatedButton(
                  //             onPressed: () async {
                  //               SharedPreferences prefs =
                  //                   await SharedPreferences.getInstance();
                  //               await prefs.setString('redirectRoute', '/cart');

                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) => const LoginScreen(),
                  //                 ),
                  //               );
                  //             },
                  //             style: ElevatedButton.styleFrom(
                  //               backgroundColor:
                  //                   isTablet ? Colors.white : Colors.green,
                  //               padding: EdgeInsets.symmetric(
                  //                 horizontal: isTablet ? 40 : 30,
                  //                 vertical: isTablet ? 14 : 12,
                  //               ),
                  //               textStyle: TextStyle(
                  //                 fontSize: isTablet ? 18 : 16,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //               foregroundColor: isTablet
                  //                   ? Colors.green.shade700
                  //                   : Colors.white,
                  //               shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(10),
                  //               ),
                  //             ),
                  //             child: const Text("Go To Login"),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),