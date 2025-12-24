import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/cart_service.dart';
import 'package:furniture_ecom_app/core/services_ecom/delivery_service.dart';
import 'package:furniture_ecom_app/core/services_ecom/settings_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/orders/update_address.dart';
import 'package:furniture_ecom_app/my_ecom/payment/payment_options.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider import (your file)
import 'package:furniture_ecom_app/my_ecom/authentication/provider/del_address_provider.dart';

class OrderSummary extends StatefulWidget {
  final bool refresh;
  const OrderSummary({super.key, this.refresh = false});

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  // removed login flag as requested
  List<CartItem> _cartItems = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;

  // Address fields (kept as before for UI)
  String? selectedDeliveryId;
  String _userName = "";
  String _userPhone = "";
  String _houseNo = "";
  String _streetName = "";
  String _city = "";
  String _state = "";
  String _pinCode = "";
  int? _minOrderAmount;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
    _fetchCartItems();
    _loadAddressFromProvider();
    _validateAddressOnStart();
  }

  void _loadAddressFromProvider() {
    final address = context.read<SelectedAddressProvider>().selectedAddress;

    if (address == null) {
      _clearAddress();
      return;
    }

    setState(() {
      selectedDeliveryId = address['id'];
      _userName = address['dealername'] ?? "No Name";
      _userPhone = address['phoneNo'] ?? "No Phone";
      _houseNo = address['houseNo'] ?? "No HouseNo";
      _streetName = address['streetName'] ?? "No StreetName";
      _city = address['city'] ?? "No City";
      _state = address['state'] ?? "No State";
      _pinCode = address['pinCode'] ?? "No PinCode";
    });
  }

  void _clearAddress() {
    selectedDeliveryId = null;
    _userName = "No Name";
    _userPhone = "No Phone";
    _houseNo = "No HouseNo";
    _streetName = "No StreetName";
    _city = "No City";
    _state = "No State";
    _pinCode = "No PinCode";
  }

  Future<void> _fetchSettings() async {
    try {
      final settings = await SettingsService.getSettings();
      setState(() {
        _minOrderAmount = settings['minOrderAmount'];
      });
    } catch (e) {
      showTopSnackBar(context, "Failed to load settings");
    }
  }

  // fetch cart items (unchanged)
  Future<void> _fetchCartItems() async {
    setState(() => _isLoading = true);
    try {
      final cartData = await CartService.getCartItems();
      await Provider.of<CartProvider>(context, listen: false).fetchCartCount();

      setState(() {
        _cartItems = cartData['cartItems'] ?? [];
        _totalAmount = cartData['quote']['totalAmount']?.toDouble() ?? 0.0;
      });
    } catch (e) {
      showTopSnackBar(context, 'No Items in cart');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> isDeliveryIdValid(String id) async {
    try {
      final list = await DeliveryService.mygetDeliveryDetails();
      return list.any((item) => item['_id'] == id);
    } catch (e) {
      return false;
    }
  }

  Future<void> _validateAddressOnStart() async {
    final address = context.read<SelectedAddressProvider>().selectedAddress;

    if (address == null) return; // nothing to validate

    final id = address['id'];

    final isValid = await isDeliveryIdValid(id);

    if (!isValid) {
      // clear provider
      context.read<SelectedAddressProvider>().clear();

      // update UI immediately
      setState(() {
        _clearAddress(); // your existing method
      });
    }
  }

  String get _formattedAddress {
    return '$_houseNo, $_streetName, $_city, $_state - $_pinCode';
  }

  // store cart summary (unchanged)
  void _storeCartSummaryForPayment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> itemSummaries = _cartItems.map((item) {
      return "${item.productTitle}|${item.quantity}|${item.totalWithGST}|${item.gstPercentage}";
    }).toList();

    await prefs.setStringList('cart_summary_items', itemSummaries);
    await prefs.setDouble('total_amount', _totalAmount);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    context.watch<SelectedAddressProvider>();

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
              "Order Summary",
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
      body: _isLoading
          ? const Center(child: AnimationPage1())
          : (isTablet ? buildTabletView(context) : buildMobileView(context)),
    );
  }

  // ---------------- Mobile view (kept same, only address flows use provider) ----------------
  Widget buildMobileView(BuildContext context) {
    final isBelowMin =
        _minOrderAmount != null && _totalAmount < _minOrderAmount!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadAddressFromProvider();
              _fetchCartItems();
            },
            color: mythemecolor,
            backgroundColor: const Color.fromARGB(255, 245, 240, 242),
            displacement: 40,
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Deliver To:",
                      style: TextStyle(
                        color: mythemecolor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_userName == "No Name" || selectedDeliveryId == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 20,
                                      color: mythemecolor,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "No Delivery Address Selected",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Please select a delivery address to proceed with your order.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateAddressScreen(),
                                      ),
                                    );

                                    if (result == true && mounted) {
                                      _loadAddressFromProvider();
                                      setState(() {
                                        _fetchCartItems();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mythemecolor,
                                    minimumSize: const Size(200, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.edit_location_alt,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Add Delivery Details",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    // if (!_isAddressSelected)
                    //   Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16.0,
                    //       vertical: 10.0,
                    //     ),
                    //     child: Card(
                    //       color: Colors.white,
                    //       elevation: 10,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(16.0),
                    //         child: Column(
                    //           children: [
                    //             Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Icon(
                    //                   Icons.location_on,
                    //                   size: 20,
                    //                   color: mythemecolor,
                    //                 ),
                    //                 const SizedBox(width: 10),
                    //                 Text(
                    //                   "No Delivery Address Selected",
                    //                   style: TextStyle(
                    //                     fontSize: 12,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.black87,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //             const SizedBox(height: 12),
                    //             Text(
                    //               "Please select a delivery address to proceed with your order.",
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //                 color: Colors.grey[700],
                    //               ),
                    //               textAlign: TextAlign.center,
                    //             ),
                    //             const SizedBox(height: 16),
                    //             ElevatedButton.icon(
                    //               onPressed: () async {
                    //                 final result = await Navigator.push(
                    //                   context,
                    //                   MaterialPageRoute(
                    //                     builder: (context) =>
                    //                         const UpdateAddressScreen(),
                    //                   ),
                    //                 );
                    //                 // after returning from update address screen, sync from provider
                    //                 if (result == true) {
                    //                  _loadAddressFromProvider();
                    //                 }
                    //               },
                    //               style: ElevatedButton.styleFrom(
                    //                 backgroundColor: mythemecolor1,
                    //                 minimumSize: const Size(200, 40),
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(8),
                    //                 ),
                    //               ),
                    //               icon: const Icon(
                    //                 Icons.edit_location_alt,
                    //                 color: Colors.white,
                    //               ),
                    //               label: const Text(
                    //                 "Add Delivery Details",
                    //                 style: TextStyle(
                    //                   fontSize: 12,
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   )
                    else
                      Center(
                        child: SizedBox(
                          child: Card(
                            color: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Delivery Address",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: mythemecolor,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateAddressScreen(),
                                            ),
                                          );

                                          if (result == true && mounted) {
                                            _loadAddressFromProvider();
                                            setState(() {
                                              _fetchCartItems();
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit_location_alt,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Change Address",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mythemecolor,

                                          minimumSize: const Size(50, 35),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: mythemecolor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Name     :   $_userName",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: mythemecolor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Phone    :   $_userPhone",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: mythemecolor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Address :   $_houseNo, $_streetName,\n$_city, $_state - $_pinCode",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // else
                    //   Center(
                    //     child: SizedBox(
                    //       child: Card(
                    //         color: Colors.white,
                    //         elevation: 10,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(15.0),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   const Text(
                    //                     "Delivery Address",
                    //                     style: TextStyle(
                    //                       fontSize: 12,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: mythemecolor,
                    //                     ),
                    //                   ),
                    //                   ElevatedButton.icon(
                    //                     onPressed: () async {
                    //                       bool? refresh = await Navigator.push(
                    //                         context,
                    //                         MaterialPageRoute(
                    //                           builder: (context) =>
                    //                               const UpdateAddressScreen(),
                    //                         ),
                    //                       );
                    //                       if (refresh == true && mounted) {
                    //                         // sync provider -> local UI
                    //                         _loadAddressFromProvider();
                    //                       }
                    //                     },
                    //                     icon: const Icon(
                    //                       Icons.edit_location_alt,
                    //                       size: 12,
                    //                       color: Colors.white,
                    //                     ),
                    //                     label: const Text(
                    //                       "Change Address",
                    //                       style: TextStyle(
                    //                         fontSize: 12,
                    //                         color: Colors.white,
                    //                       ),
                    //                     ),
                    //                     style: ElevatedButton.styleFrom(
                    //                       backgroundColor: mythemecolor,
                    //                       minimumSize: const Size(50, 35),
                    //                       padding: const EdgeInsets.symmetric(
                    //                         horizontal: 15,
                    //                         vertical: 10,
                    //                       ),
                    //                       shape: RoundedRectangleBorder(
                    //                         borderRadius: BorderRadius.circular(
                    //                           8,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               const SizedBox(height: 10),
                    //               Row(
                    //                 children: [
                    //                   const Icon(
                    //                     Icons.person,
                    //                     color: mythemecolor,
                    //                     size: 18,
                    //                   ),
                    //                   const SizedBox(width: 8),
                    //                   Expanded(
                    //                     child: Text(
                    //                       "Name     :   $_userName",
                    //                       style: const TextStyle(
                    //                         fontSize: 12,
                    //                         fontWeight: FontWeight.bold,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               const SizedBox(height: 15),
                    //               Row(
                    //                 children: [
                    //                   const Icon(
                    //                     Icons.phone,
                    //                     color: mythemecolor,
                    //                     size: 18,
                    //                   ),
                    //                   const SizedBox(width: 8),
                    //                   Expanded(
                    //                     child: Text(
                    //                       "Phone    :   $_userPhone",
                    //                       style: const TextStyle(
                    //                         fontSize: 12,
                    //                         fontWeight: FontWeight.bold,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               const SizedBox(height: 15),
                    //               Row(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   const Icon(
                    //                     Icons.location_on,
                    //                     color: mythemecolor,
                    //                     size: 18,
                    //                   ),
                    //                   const SizedBox(width: 8),
                    //                   Expanded(
                    //                     child: Text(
                    //                       "Address :   $_formattedAddress",
                    //                       style: const TextStyle(
                    //                         fontSize: 12,
                    //                         fontWeight: FontWeight.bold,
                    //                       ),
                    //                       maxLines: 5,
                    //                       overflow: TextOverflow.ellipsis,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    const SizedBox(height: 20),
                    const Text(
                      "Items in Cart:",
                      style: TextStyle(
                        color: mythemecolor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return GestureDetector(
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
                          child: Card(
                            color: const Color.fromARGB(255, 228, 215, 226),
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Image.network(
                                    item.productImages,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.productTitle,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (item.originalPrice >
                                                item.offerPrice)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: mythemecolor1,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
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
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total Price + GST : ₹${item.totalWithGST.round()}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: mythemecolor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gst Percentage: ${item.gstPercentage.round()}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Quantity: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // bottom area: continue + total
        SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_minOrderAmount != null && _totalAmount < _minOrderAmount!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "⚠ Your total amount is ₹${_totalAmount.toString()}, "
                      "\n but the minimum order amount required to proceed is ₹$_minOrderAmount. "
                      "\n Please add a few more items to continue...",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 67, 66, 66),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total: ₹${_totalAmount.round()}",
                      style: const TextStyle(
                        color: mythemecolor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // onPressed:
                    //     (_minOrderAmount != null &&
                    //         _totalAmount < _minOrderAmount!)
                    //     ? null
                    //     : () {
                    //         if (!_isAddressSelected) {
                    //           showTopSnackBar(
                    //             context,
                    //             "Please select a delivery address.",
                    //           );
                    //           return;
                    //         }
                    ElevatedButton(
                      onPressed: isBelowMin
                          ? null
                          : () async {
                              if (selectedDeliveryId == null) {
                                showTopSnackBar(
                                  context,
                                  "Please select a delivery address.",
                                );
                                return;
                              }
                              final isValid = await isDeliveryIdValid(
                                selectedDeliveryId!,
                              );
                              if (!isValid) {
                                showTopSnackBar(
                                  context,
                                  "Selected address no longer exists. Please select another!",
                                );
                                context.read<SelectedAddressProvider>().clear();
                                setState(() {
                                  _loadAddressFromProvider();
                                });
                                return;
                              }
                              _storeCartSummaryForPayment();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ExpansionTileControllers(
                                        totalAmount: _totalAmount,
                                        type: 'cartNow',
                                        selectedDeliveryId: selectedDeliveryId,
                                      ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mythemecolor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 9,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("CONTINUE"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Tablet view (kept same other than provider-based address) ----------------
  Widget buildTabletView(BuildContext context) {
    final isBelowMin =
        _minOrderAmount != null && _totalAmount < _minOrderAmount!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadAddressFromProvider();
              _fetchCartItems();
            },
            color: mythemecolor,
            backgroundColor: const Color.fromARGB(255, 245, 240, 242),
            displacement: 40,
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Deliver To:",
                      style: TextStyle(
                        color: mythemecolor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_userName == "No Name" || selectedDeliveryId == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 40,
                                      color: mythemecolor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "No Delivery Address Selected",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Please select a delivery address to proceed with your order.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result =
                                        await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const UpdateAddressScreen(),
                                          ),
                                        );
                                    if (result == true && mounted) {
                                      _loadAddressFromProvider();
                                      setState(() {
                                        _fetchCartItems();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mythemecolor1,
                                    minimumSize: const Size(200, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.edit_location_alt,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Select Address",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 800,
                          child: Card(
                            color: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Delivery Address",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: mythemecolor,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateAddressScreen(),
                                            ),
                                          );

                                          if (result == true && mounted) {
                                            _loadAddressFromProvider();
                                            setState(() {
                                              _fetchCartItems();
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit_location_alt,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Change Address",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mythemecolor,
                                          minimumSize: const Size(50, 35),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: mythemecolor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Name     :   $_userName",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: mythemecolor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Phone    :   $_userPhone",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: mythemecolor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Address :   $_formattedAddress",
                                          style: const TextStyle(fontSize: 16),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      "Items in Cart:",
                      style: TextStyle(
                        color: mythemecolor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Card(
                              color: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: 300,
                                padding: const EdgeInsets.all(9.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        item.productImages,
                                        fit: BoxFit.cover,
                                        width: 250,
                                        height: 150,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productTitle,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color.fromARGB(
                                              255,
                                              83,
                                              82,
                                              82,
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Qty: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Price with GST: ₹${item.totalWithGST.round()}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: mythemecolor,
                                          ),
                                        ),
                                        if (item.originalPrice >
                                            item.offerPrice)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: mythemecolor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBelowMin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    "⚠ Your total amount is ₹${_totalAmount.round()}, "
                    "but the minimum order required to proceed is ₹$_minOrderAmount. "
                    "Please add more items to continue.",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 67, 66, 66),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total: ₹${_totalAmount.round()}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isBelowMin
                        ? null
                        : () async {
                            if (selectedDeliveryId == null) {
                              showTopSnackBar(
                                context,
                                "Please select a delivery address.",
                              );
                              return;
                            }
                            final isValid = await isDeliveryIdValid(
                              selectedDeliveryId!,
                            );
                            if (!isValid) {
                              showTopSnackBar(
                                context,
                                "Selected address no longer exists. Please select another!",
                              );
                              context.read<SelectedAddressProvider>().clear();
                              setState(() {
                                _loadAddressFromProvider();
                              });
                              return;
                            }
                            _storeCartSummaryForPayment();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpansionTileControllers(
                                  totalAmount: _totalAmount,
                                  type: 'cartNow',
                                  selectedDeliveryId: selectedDeliveryId,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mythemecolor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/core/model/model_file.dart';
// import 'package:furniture_ecom_app/core/services/cart_service.dart';
// import 'package:furniture_ecom_app/core/services/delivery_service.dart';
// import 'package:furniture_ecom_app/core/services/settings_service.dart';
// import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
// import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
// import 'package:furniture_ecom_app/my_ecom/cart/cart_provider.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
// import 'package:furniture_ecom_app/my_ecom/orders/update_address.dart';
// import 'package:furniture_ecom_app/my_ecom/payment/payment_options.dart';
// import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class OrderSummary extends StatefulWidget {
//   final bool refresh;
//   const OrderSummary({super.key, this.refresh = false});

//   @override
//   State<OrderSummary> createState() => _OrderSummaryState();
// }

// class _OrderSummaryState extends State<OrderSummary> {
//   bool _isLoggedIn = false;
//   List<CartItem> _cartItems = [];
//   double _totalAmount = 0.0;
//   bool _isLoading = true;
//   String? selectedDeliveryId;
//   String _userName = "";
//   String _userPhone = "";
//   String _userHouseNo = "";
//   String _userStreetName = "";
//   String _userCity = "";
//   String _userState = "";
//   String _userPinCode = "";
//   int? _minOrderAmount;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//     _fetchSettings();
//   }

//   Future<void> _fetchSettings() async {
//     try {
//       final settings = await SettingsService.getSettings();
//       setState(() {
//         _minOrderAmount = settings['minOrderAmount'];
//       });
//     } catch (e) {
//       showTopSnackBar(context, "Failed to load settings");
//     }
//   }

//   Future<void> _fetchCartItems() async {
//     setState(() => _isLoading = true);
//     try {
//       final cartData = await CartService.getCartItems();
//       await Provider.of<CartProvider>(context, listen: false).fetchCartCount();

//       setState(() {
//         _cartItems = cartData['cartItems'] ?? [];
//         _totalAmount = cartData['quote']['totalAmount']?.toDouble() ?? 0.0;
//       });
//     } catch (e) {
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   SnackBar(
//       //     content: Text('No Items in cart'),
//       //   ),
//       // );
//       showTopSnackBar(context, 'No Items in cart');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('auth_token');

//     if (token != null && token.isNotEmpty) {
//       setState(() => _isLoggedIn = true);
//       await _fetchSelectedAddress();
//       await _fetchCartItems();
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     }
//   }

//   Future<void> _fetchSelectedAddress() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final storedAddressId = prefs.getString('selectedAddressId');

//     try {
//       final addressList = await DeliveryService.mygetDeliveryDetails();

//       if (addressList.isEmpty) {
//         await _clearAddressFromPreferences();
//         _clearAddressData();
//         return;
//       }

//       if (storedAddressId == null || storedAddressId.isEmpty) {
//         await _clearAddressFromPreferences();
//         _clearAddressData();
//       } else {
//         setState(() {
//           selectedDeliveryId = storedAddressId;
//           _userName =
//               prefs.getString('selectedUsername') ?? "No Name Available";
//           _userPhone =
//               prefs.getString('selectedPhoneNo') ?? "No Phone Available";
//           _userHouseNo = prefs.getString('selectedHouseNo') ?? "";
//           _userStreetName = prefs.getString('selectedStreetName') ?? "";
//           _userCity = prefs.getString('selectedCity') ?? "";
//           _userState = prefs.getString('selectedState') ?? "";
//           _userPinCode = prefs.getString('selectedPinCode') ?? "";
//         });
//       }
//     } catch (e) {
//       print("Error fetching addresses: $e");
//     }
//   }

//   Future<void> _clearAddressFromPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('selectedAddressId');
//     await prefs.remove('selectedUsername');
//     await prefs.remove('selectedPhoneNo');
//     await prefs.remove('selectedHouseNo');
//     await prefs.remove('selectedStreetName');
//     await prefs.remove('selectedCity');
//     await prefs.remove('selectedState');
//     await prefs.remove('selectedPinCode');
//   }

//   void _clearAddressData() {
//     setState(() {
//       selectedDeliveryId = null;
//       _userName = "No Name Selected";
//       _userPhone = "No Phone Selected";
//       _userHouseNo = "";
//       _userStreetName = "";
//       _userCity = "";
//       _userState = "";
//       _userPinCode = "";
//     });
//   }

//   String get _formattedAddress {
//     return '$_userHouseNo, $_userStreetName, $_userCity, $_userState - $_userPinCode';
//   }

//   bool get _isAddressSelected {
//     return selectedDeliveryId != null &&
//         _userHouseNo.isNotEmpty &&
//         _userStreetName.isNotEmpty &&
//         _userCity.isNotEmpty &&
//         _userState.isNotEmpty &&
//         _userPinCode.isNotEmpty;
//   }

//   void _storeCartSummaryForPayment() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     List<String> itemSummaries = _cartItems.map((item) {
//       return "${item.productTitle}|${item.quantity}|${item.totalWithGST}|${item.gstPercentage}";
//     }).toList();

//     await prefs.setStringList('cart_summary_items', itemSummaries);
//     await prefs.setDouble('total_amount', _totalAmount);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [mythemecolor1, mythemecolor],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: Text(
//               "Order Summary",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             centerTitle: true,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: AnimationPage1())
//           : _isLoggedIn
//           ? isTablet
//                 ? buildTabletView(context)
//                 : buildMobileView(context)
//           : const Center(child: Text("User not Authenticated")),
//     );
//   }

//   Widget buildMobileView(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: () async {
//               setState(() {
//                 _fetchSelectedAddress();
//                 _fetchCartItems();
//               });
//             },
//             color: mythemecolor,
//             backgroundColor: const Color.fromARGB(255, 245, 240, 242),
//             displacement: 40,
//             strokeWidth: 2.5,
//             child: SingleChildScrollView(
//               physics: AlwaysScrollableScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Deliver To:",
//                       style: TextStyle(
//                         color: mythemecolor,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (!_isAddressSelected)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16.0,
//                           vertical: 10.0,
//                         ),
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 10,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.location_on,
//                                       size: 20,
//                                       color: mythemecolor,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       "No Delivery Address Selected",
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   "Please select a delivery address to proceed with your order.",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[700],
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 ElevatedButton.icon(
//                                   onPressed: () async {
//                                     final result = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             const UpdateAddressScreen(),
//                                       ),
//                                     );
//                                     if (result == true) {
//                                       await _fetchSelectedAddress();
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: mythemecolor1,
//                                     minimumSize: const Size(200, 40),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   icon: const Icon(
//                                     Icons.edit_location_alt,
//                                     color: Colors.white,
//                                   ),
//                                   label: const Text(
//                                     "Add Delivery Details",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     else
//                       Center(
//                         child: SizedBox(
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 10,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         "Delivery Address",
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: mythemecolor,
//                                         ),
//                                       ),
//                                       ElevatedButton.icon(
//                                         onPressed: () async {
//                                           bool? refresh = await Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   const UpdateAddressScreen(),
//                                             ),
//                                           );
//                                           if (refresh == true && mounted) {
//                                             _fetchSelectedAddress();
//                                           }
//                                         },
//                                         icon: const Icon(
//                                           Icons.edit_location_alt,
//                                           size: 12,
//                                           color: Colors.white,
//                                         ),
//                                         label: const Text(
//                                           "Change Address",
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: mythemecolor,

//                                           minimumSize: const Size(50, 35),
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 15,
//                                             vertical: 10,
//                                           ),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.person,
//                                         color: mythemecolor,
//                                         size: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           "Name     :   $_userName",
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 15),
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.phone,
//                                         color: mythemecolor,
//                                         size: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           "Phone    :   $_userPhone",
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 15),
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Icon(
//                                         Icons.location_on,
//                                         color: mythemecolor,
//                                         size: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           "Address :   $_formattedAddress",
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           maxLines: 5,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Items in Cart:",
//                       style: TextStyle(
//                         color: mythemecolor,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: _cartItems.length,
//                       itemBuilder: (context, index) {
//                         final item = _cartItems[index];
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ProductDetailPagep(
//                                   productId: item.productId,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Card(
//                             color: const Color.fromARGB(255, 228, 215, 226),

//                             elevation: 5,
//                             margin: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: Row(
//                                 children: [
//                                   Image.network(
//                                     item.productImages,
//                                     width: 90,
//                                     height: 90,
//                                     fit: BoxFit.cover,
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               item.productTitle,
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             if (item.originalPrice >
//                                                 item.offerPrice)
//                                               Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                       horizontal: 10,
//                                                       vertical: 6,
//                                                     ),
//                                                 decoration: BoxDecoration(
//                                                   color: mythemecolor1,
//                                                   borderRadius:
//                                                       BorderRadius.circular(6),
//                                                 ),
//                                                 child: Text(
//                                                   '${(((item.originalPrice - item.offerPrice) / item.originalPrice) * 100).round()}% OFF',
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 10,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text(
//                                               'Total Price + GST : ₹${item.totalWithGST.round()}',
//                                               style: const TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w500,
//                                                 color:mythemecolor
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           'Gst Percentage: ${item.gstPercentage.round()}%',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                             color: Colors.black54,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           'Quantity: ${item.quantity}',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Color.fromARGB(
//                                               255,
//                                               224,
//                                               129,
//                                               5,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         SafeArea(
//           bottom: true,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (_minOrderAmount != null && _totalAmount < _minOrderAmount!)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Text(
//                       "⚠ Your total amount is ₹${_totalAmount.toString()}, "
//                       "\n but the minimum order amount required to proceed is ₹$_minOrderAmount. "
//                       "\n Please add a few more items to continue...",
//                       style: const TextStyle(
//                         color: Color.fromARGB(255, 67, 66, 66),
//                         fontSize: 10,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Total: ₹${_totalAmount.round()}",
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed:
//                           (_minOrderAmount != null &&
//                               _totalAmount < _minOrderAmount!)
//                           ? null // ✅ disable button if total < min
//                           : () {
//                               if (!_isAddressSelected) {
//                                 showTopSnackBar(
//                                   context,
//                                   "Please select a delivery address.",
//                                 );
//                                 return;
//                               }
//                               _storeCartSummaryForPayment();
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ExpansionTileControllers(
//                                         totalAmount: _totalAmount,
//                                         type: 'cartNow',
//                                         selectedDeliveryId: selectedDeliveryId,
//                                       ),
//                                 ),
//                               );
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: mythemecolor,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 9,
//                         ),
//                         textStyle: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text("CONTINUE"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildTabletView(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: RefreshIndicator(
//             onRefresh: () async {
//               setState(() {
//                 _fetchSelectedAddress();
//                 _fetchCartItems();
//               });
//             },
//             color: mythemecolor,
//             backgroundColor: const Color.fromARGB(255, 245, 240, 242),
//             displacement: 40,
//             strokeWidth: 2.5,
//             child: SingleChildScrollView(
//               physics: AlwaysScrollableScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(40.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Deliver To:",
//                       style: TextStyle(
//                         color: mythemecolor,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (!_isAddressSelected)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16.0,
//                           vertical: 10.0,
//                         ),
//                         child: Card(
//                           elevation: 6,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.location_on,
//                                       size: 40,
//                                       color: mythemecolor,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       "No Delivery Address Selected",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 12),
//                                 Text(
//                                   "Please select a delivery address to proceed with your order.",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[700],
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 ElevatedButton.icon(
//                                   onPressed: () async {
//                                     final result = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             const UpdateAddressScreen(),
//                                       ),
//                                     );
//                                     if (result == true) {
//                                       await _fetchSelectedAddress();
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: mythemecolor1,
//                                     minimumSize: const Size(200, 40),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                   icon: const Icon(
//                                     Icons.edit_location_alt,
//                                     color: Colors.white,
//                                   ),
//                                   label: const Text(
//                                     "Select Address",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     else
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: SizedBox(
//                           width: 800,
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 10,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         "Delivery Address",
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: mythemecolor,
//                                         ),
//                                       ),
//                                       ElevatedButton.icon(
//                                         onPressed: () async {
//                                           bool? refresh = await Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   const UpdateAddressScreen(),
//                                             ),
//                                           );
//                                           if (refresh == true && mounted) {
//                                             _fetchSelectedAddress();
//                                           }
//                                         },
//                                         icon: const Icon(
//                                           Icons.edit_location_alt,
//                                           size: 16,
//                                           color: Colors.white,
//                                         ),
//                                         label: const Text(
//                                           "Change Address",
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: mythemecolor,
//                                           minimumSize: const Size(50, 35),
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 15,
//                                             vertical: 10,
//                                           ),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.person,
//                                         color: mythemecolor,
//                                         size: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           "Name     :   $_userName",
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.phone,
//                                         color: mythemecolor,
//                                         size: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           "Phone    :   $_userPhone",
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const Icon(
//                                         Icons.location_on,
//                                         color: mythemecolor,
//                                         size: 18,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Expanded(
//                                         child: Text(
//                                           "Address :   $_formattedAddress",
//                                           style: const TextStyle(fontSize: 16),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Items in Cart:",
//                       style: TextStyle(
//                         color: mythemecolor,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 300,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: _cartItems.length,
//                         itemBuilder: (context, index) {
//                           final item = _cartItems[index];
//                           return Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Card(
//                               color: Colors.white,
//                               elevation: 4,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Container(
//                                 width: 300,
//                                 padding: const EdgeInsets.all(9.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Expanded(
//                                       child: Image.network(
//                                         item.productImages,
//                                         fit: BoxFit.cover,
//                                         width: 250,
//                                         height: 150,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           item.productTitle,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             color: Color.fromARGB(
//                                               255,
//                                               83,
//                                               82,
//                                               82,
//                                             ),
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const Spacer(),
//                                         Text(
//                                           'Qty: ${item.quantity}',
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Total Price with GST: ₹${item.totalWithGST.round()}',
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w500,
//                                             color: mythemecolor,
//                                           ),
//                                         ),
//                                         if (item.originalPrice >
//                                             item.offerPrice)
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 10,
//                                               vertical: 6,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: mythemecolor,
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                             child: Text(
//                                               '${(((item.originalPrice - item.offerPrice) / item.originalPrice) * 100).round()}% OFF',
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 10,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         Padding(
//           padding: const EdgeInsets.all(30),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 🔴 Show warning if below min order
//               if (_minOrderAmount != null && _totalAmount < _minOrderAmount!)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 12.0),
//                   child: Text(
//                     "⚠ Your total amount is ₹${_totalAmount.round()}, "
//                     "but the minimum order required to proceed is ₹$_minOrderAmount. "
//                     "Please add more items to continue.",
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 67, 66, 66),
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Total: ₹${_totalAmount.round()}",
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed:
//                         (_minOrderAmount != null &&
//                             _totalAmount < _minOrderAmount!)
//                         ? null // ✅ Disable when below min
//                         : () {
//                             if (!_isAddressSelected) {
//                               showTopSnackBar(
//                                 context,
//                                 "Please select a delivery address.",
//                               );
//                               return;
//                             }

//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ExpansionTileControllers(
//                                   totalAmount: _totalAmount,
//                                   type: 'cartNow',
//                                   selectedDeliveryId: selectedDeliveryId,
//                                 ),
//                               ),
//                             );
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: mythemecolor,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                     ),
//                     child: const Text(
//                       "CONTINUE",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: mythemecolor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
