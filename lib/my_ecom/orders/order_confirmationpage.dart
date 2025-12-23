import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services_ecom/delivery_service.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/provider/del_address_provider.dart';
import 'package:provider/provider.dart';

import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/settings_service.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/orders/update_address.dart';
import 'package:furniture_ecom_app/my_ecom/payment/payment_options.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Product product;
  final bool refresh;
  final String? offerId;

  const OrderConfirmationPage({
    super.key,
    required this.product,
    this.offerId,
    this.refresh = false,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  int quantity = 1;
  int? _minOrderAmount;

  double totalAmount = 0.0;
  bool _isLoading = true;
  double _gstAmount = 0.0;
  double _baseAmount = 0.0;

  String? selectedDeliveryId;
  String _userName = "";
  String _userPhone = "";
  String _houseNo = "";
  String _streetName = "";
  String _city = "";
  String _state = "";
  String _pinCode = "";

  @override
  void initState() {
    super.initState();
    calculateTotalAmount();
    _fetchSettings();
    _loadAddressFromProvider();
    _storeBuyNowSummaryForPayment();
    _validateAddressOnStart();

    _isLoading = false;
  }

  /// ✅ stays unchanged (used for payment summary only)
  Future<void> _storeBuyNowSummaryForPayment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final product = widget.product;

    String itemSummary =
        "${product.title}|$quantity|${totalAmount.round()}|${product.gstPercentage}";

    await prefs.setStringList('cart_summary_items', [itemSummary]);
    await prefs.setDouble('total_amount', totalAmount);
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

  void _updateQuantity(int newQuantity) {
    if (newQuantity < 1) return;

    if (newQuantity > widget.product.stock) {
      showTopSnackBar(
        context,
        "Only ${widget.product.stock} items left in stock.",
      );
      return;
    }

    setState(() {
      quantity = newQuantity;
      calculateTotalAmount();
    });
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

  Future<bool> isDeliveryIdValid(String id) async {
    try {
      final list = await DeliveryService.mygetDeliveryDetails();
      return list.any((item) => item['_id'] == id);
    } catch (e) {
      return false;
    }
  }

  void calculateTotalAmount() {
    _baseAmount = widget.product.offerPrice * quantity;
    final gstRate = widget.product.gstPercentage / 100;
    _gstAmount = _baseAmount * gstRate;
    totalAmount = _baseAmount + _gstAmount;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isBelowMin =
        _minOrderAmount != null && totalAmount < _minOrderAmount!;

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
              "Order Confirmation",
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 22 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBelowMin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: isTablet
                      ? Text(
                          "⚠ Your total amount is ₹${totalAmount.round()}, "
                          "but the minimum order required to proceed is ₹$_minOrderAmount. "
                          "Please add more items to continue.",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 67, 66, 66),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "⚠ Your total amount is ₹${totalAmount.round()}, "
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
              isTablet
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ₹${totalAmount.round()}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isBelowMin
                                ? null
                                : () async {
                                    // 1. No provider address
                                    if (selectedDeliveryId == null) {
                                      showTopSnackBar(
                                        context,
                                        "Please select a delivery address.",
                                      );
                                      return;
                                    }

                                    // 2. Validate with DB
                                    final isValid = await isDeliveryIdValid(
                                      selectedDeliveryId!,
                                    );

                                    if (!isValid) {
                                      showTopSnackBar(
                                        context,
                                        "Selected address no longer exists. Please select another!",
                                      );

                                      // Clear provider
                                      context
                                          .read<SelectedAddressProvider>()
                                          .clear();

                                      // 🚨 Very important: update UI immediately
                                      setState(() {
                                        _loadAddressFromProvider();
                                      });

                                      return;
                                    }

                                    // 3. If everything is valid → Go to payment
                                    await _storeBuyNowSummaryForPayment();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ExpansionTileControllers(
                                              totalAmount: totalAmount,
                                              type: 'buyNow',
                                              productId: widget.product.id,
                                              selectedDeliveryId:
                                                  selectedDeliveryId,
                                              quantity: quantity.toString(),
                                              offerId: widget.offerId,
                                            ),
                                      ),
                                    );
                                  },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: mythemecolor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
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
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: ₹${totalAmount.round()}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isBelowMin
                              ? null
                              : () async {
                                  // 1. No provider address
                                  if (selectedDeliveryId == null) {
                                    showTopSnackBar(
                                      context,
                                      "Please select a delivery address.",
                                    );
                                    return;
                                  }

                                  // 2. Validate with DB
                                  final isValid = await isDeliveryIdValid(
                                    selectedDeliveryId!,
                                  );

                                  if (!isValid) {
                                    showTopSnackBar(
                                      context,
                                      "Selected address no longer exists. Please select another!",
                                    );

                                    // Clear provider
                                    context
                                        .read<SelectedAddressProvider>()
                                        .clear();

                                    // 🚨 Very important: update UI immediately
                                    setState(() {
                                      _loadAddressFromProvider();
                                    });

                                    return;
                                  }

                                  // 3. If everything is valid → Go to payment
                                  await _storeBuyNowSummaryForPayment();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ExpansionTileControllers(
                                        totalAmount: totalAmount,
                                        type: 'buyNow',
                                        productId: widget.product.id,
                                        selectedDeliveryId: selectedDeliveryId,
                                        quantity: quantity.toString(),
                                        offerId: widget.offerId,
                                      ),
                                    ),
                                  );
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: mythemecolor,
                            padding: const EdgeInsets.all(10),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: mythemecolor))
          : isTablet
          ? _buildTabletView(context, product)
          : _buildMobileView(context, product),
    );
  }

  Widget _buildTabletView(BuildContext context, Product product) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadAddressFromProvider();
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
                      "Item to Purchase:",
                      style: TextStyle(
                        color: mythemecolor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: const Color.fromARGB(255, 228, 215, 226),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 800),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Container(
                                  width: 255, // Reduced width
                                  height: 230, // Square aspect ratio
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        product.images.isNotEmpty
                                            ? product.images.first
                                            : 'https://via.placeholder.com/150',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Original Price: ₹${product.offerPrice.round()}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: mythemecolor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (product.price >
                                              product.offerPrice)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: mythemecolor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${(((product.price - product.offerPrice) / product.price) * 100).round()}% OFF',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      Text(
                                        'Gst Percentage: ${product.gstPercentage}%',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: mythemecolor,
                                        ),
                                      ),

                                      const SizedBox(height: 12),
                                      Text(
                                        '₹${_baseAmount.round()} + ₹${_gstAmount.round()} = ₹${totalAmount.round()}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Total Amount with GST: ₹${totalAmount.round()}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: mythemecolor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          const Text(
                                            "Quantity:",
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: mythemecolor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: mythemecolor1,
                                              size: 35,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              if (quantity > 1) {
                                                _updateQuantity(quantity - 1);
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: mythemecolor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                fontSize: 22,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle,
                                              color: mythemecolor,
                                              size: 35,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              _updateQuantity(quantity + 1);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                      size: 30,
                                      color: mythemecolor,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "No Delivery Address Selected",
                                      style: TextStyle(
                                        fontSize: 22,
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
                                    fontSize: 18,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateAddressScreen(
                                              product: product,
                                            ),
                                      ),
                                    );

                                    if (result == true && mounted) {
                                      // ✅ Load the updated address from Provider
                                      _loadAddressFromProvider();
                                      setState(() {
                                        calculateTotalAmount();
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
                      Center(
                        child: SizedBox(
                          width: 800,
                          child: Card(
                            color: Colors.white,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
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
                                          fontSize: 20,
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
                                                  UpdateAddressScreen(
                                                    product: product,
                                                  ),
                                            ),
                                          );

                                          if (result == true && mounted) {
                                            _loadAddressFromProvider();
                                            setState(() {
                                              calculateTotalAmount();
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit_location_alt,
                                          size: 20,
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
                                          minimumSize: const Size(50, 45),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
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
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: mythemecolor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Name     :   $_userName",
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: mythemecolor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Phone    :   $_userPhone",
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: mythemecolor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Address :   $_houseNo, $_streetName,\n$_city, $_state - $_pinCode",
                                          style: const TextStyle(fontSize: 18),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileView(BuildContext context, Product product) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadAddressFromProvider();
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
                      "Item to Purchase:",
                      style: TextStyle(
                        color: mythemecolor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: const Color.fromARGB(255, 228, 215, 226),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPagep(
                                      productId: product.id,
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      product.images.first,
                                      width: 130,
                                      height: 200,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  if (product.price > product.offerPrice)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: mythemecolor,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '${(((product.price - product.offerPrice) / product.price) * 100).round()}% OFF',
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
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Original Price: ₹${product.offerPrice.round()}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Gst Percentage: ${product.gstPercentage}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: mythemecolor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${_baseAmount.round()} + ₹${_gstAmount.round()} = ₹${totalAmount.round()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Total Amount with GST: ₹${totalAmount.round()}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: mythemecolor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: mythemecolor1,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          if (quantity > 1) {
                                            _updateQuantity(quantity - 1);
                                          }
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '$quantity',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: mythemecolor,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          _updateQuantity(quantity + 1);
                                        },
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
                    const SizedBox(height: 20),
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
                                            UpdateAddressScreen(
                                              product: product,
                                            ),
                                      ),
                                    );

                                    if (result == true && mounted) {
                                      // ✅ Load the updated address from Provider
                                      _loadAddressFromProvider();
                                      setState(() {
                                        calculateTotalAmount();
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
                                                  UpdateAddressScreen(
                                                    product: product,
                                                  ),
                                            ),
                                          );

                                          if (result == true && mounted) {
                                            _loadAddressFromProvider();
                                            setState(() {
                                              calculateTotalAmount();
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/core/model/model_file.dart';
// import 'package:furniture_ecom_app/core/services/settings_service.dart';
// import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
// import 'package:furniture_ecom_app/my_ecom/orders/update_address.dart';
// import 'package:furniture_ecom_app/my_ecom/payment/payment_options.dart';
// import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class OrderConfirmationPage extends StatefulWidget {
//   final Product product;
//   final bool refresh;
//   final String? offerId;
//   const OrderConfirmationPage({
//     super.key,
//     required this.product,
//     this.offerId,
//     this.refresh = false,
//   });

//   @override
//   State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
// }

// class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
//   int quantity = 1;
//   int? _minOrderAmount;

//   double totalAmount = 0.0;
//   bool _isLoggedIn = false;
//   bool _isLoading = true;
//   double _gstAmount = 0.0;
//   double _baseAmount = 0.0;

//   String? selectedDeliveryId;
//   String _userName = "";
//   String _userPhone = "";
//   String _houseNo = "";
//   String _streetName = "";
//   String _city = "";
//   String _state = "";
//   String _pinCode = "";

//   @override
//   void initState() {
//     super.initState();
//     calculateTotalAmount();
//     _fetchSettings();
//     _checkLoginStatus();
//     _storeBuyNowSummaryForPayment();
//   }

//   Future<void> _storeBuyNowSummaryForPayment() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     final product = widget.product;

//     String itemSummary =
//         "${product.title}|$quantity|${totalAmount.round()}|${product.gstPercentage}";

//     await prefs.setStringList('cart_summary_items', [itemSummary]);
//     await prefs.setDouble('total_amount', totalAmount);
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

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('auth_token');

//     if (token != null && token.isNotEmpty) {
//       setState(() => _isLoggedIn = true);
//       await _fetchSelectedAddress();
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     }
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _fetchSelectedAddress() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _userName = prefs.getString('selectedUsername') ?? "No Name";
//       _userPhone = prefs.getString('selectedPhoneNo') ?? "No Phone";
//       _houseNo = prefs.getString('selectedHouseNo') ?? "No HouseNo";
//       _streetName = prefs.getString('selectedStreetName') ?? "No StreetName";
//       _city = prefs.getString('selectedCity') ?? "No City";
//       _state = prefs.getString('selectedState') ?? "No State";
//       _pinCode = prefs.getString('selectedPinCode') ?? "No PinCode";

//       selectedDeliveryId = prefs.getString('selectedAddressId');
//     });
//   }

//   void _updateQuantity(int newQuantity) {
//     if (newQuantity < 1) return;

//     // ✅ Check available stock (assuming widget.product.stock exists)
//     if (newQuantity > widget.product.stock) {
//       showTopSnackBar(
//         context,
//         "Only ${widget.product.stock} items left in stock.",
//       );
//       return;
//     }

//     setState(() {
//       quantity = newQuantity;
//       calculateTotalAmount();
//     });
//   }

//   void calculateTotalAmount() {
//     _baseAmount = widget.product.offerPrice * quantity;
//     final gstRate = widget.product.gstPercentage / 100;
//     _gstAmount = _baseAmount * gstRate;
//     totalAmount = _baseAmount + _gstAmount;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final product = widget.product;
//     final isTablet = MediaQuery.of(context).size.width > 600;
//     final isBelowMin =
//         _minOrderAmount != null && totalAmount < _minOrderAmount!;

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
//               "Order Confirmation",
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

// bottomNavigationBar: SafeArea(
//   child: Container(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//     color: Colors.white,
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (isBelowMin)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: isTablet
//                 ? Text(
//                     "⚠ Your total amount is ₹${totalAmount.round()}, "
//                     "but the minimum order required to proceed is ₹$_minOrderAmount. "
//                     "Please add more items to continue.",
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 67, 66, 66),
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     textAlign: TextAlign.center,
//                   )
//                 : Text(
//                     "⚠ Your total amount is ₹${totalAmount.round()}, "
//                     "\n but the minimum order amount required to proceed is ₹$_minOrderAmount. "
//                     "\n Please add a few more items to continue...",
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 67, 66, 66),
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//           ),
//         isTablet
//             ? Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Total: ₹${totalAmount.round()}",
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: isBelowMin
//                           ? null
//                           : () async {
//                               if (selectedDeliveryId == null ||
//                                   _houseNo == "No HouseNo") {
//                                 showTopSnackBar(
//                                   context,
//                                   "Please select a delivery address.",
//                                 );
//                                 return;
//                               }
//                               await _storeBuyNowSummaryForPayment();
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ExpansionTileControllers(
//                                         totalAmount: totalAmount,
//                                         type: 'buyNow',
//                                         productId: widget.product.id,
//                                         selectedDeliveryId:
//                                             selectedDeliveryId,
//                                         quantity: quantity.toString(),
//                                         offerId: widget.offerId,
//                                       ),
//                                 ),
//                               );
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: mythemecolor,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 12,
//                         ),
//                         textStyle: const TextStyle(
//                           fontSize: 18,
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
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Total: ₹${totalAmount.round()}",
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: isBelowMin
//                         ? null
//                         : () async {
//                             if (selectedDeliveryId == null ||
//                                 _houseNo == "No HouseNo") {
//                               showTopSnackBar(
//                                 context,
//                                 "Please select a delivery address.",
//                               );
//                               return;
//                             }
//                             await _storeBuyNowSummaryForPayment();
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ExpansionTileControllers(
//                                       totalAmount: totalAmount,
//                                       type: 'buyNow',
//                                       productId: widget.product.id,
//                                       selectedDeliveryId:
//                                           selectedDeliveryId,
//                                       quantity: quantity.toString(),
//                                       offerId: widget.offerId,
//                                     ),
//                               ),
//                             );
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: mythemecolor,
//                       padding: const EdgeInsets.all(10),
//                       textStyle: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text("CONTINUE"),
//                   ),
//                 ],
//               ),
//       ],
//     ),
//   ),
// ),

//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: mythemecolor))
//           : _isLoggedIn
//           ? isTablet
//                 ? _buildTabletView(context, product)
//                 : _buildMobileView(context, product)
//           : const Center(child: Text("User not Authenticated")),
//     );
//   }
