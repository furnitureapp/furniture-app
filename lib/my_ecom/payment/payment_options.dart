import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services/checkout_payment.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_success.dart';
import 'package:furniture_ecom_app/my_ecom/payment/payment_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ExpansionTileControllers extends StatefulWidget {
  final double totalAmount;
  final String type;
  final String? productId;
  final String? offerId;
  final String? selectedDeliveryId;
  final String? quantity;

  const ExpansionTileControllers(
      {super.key,
      required this.totalAmount,
      required this.type,
      this.productId,
      this.quantity,
      this.offerId,
      this.selectedDeliveryId});

  @override
  _ExpansionTileControllersState createState() =>
      _ExpansionTileControllersState();
}

class _ExpansionTileControllersState extends State<ExpansionTileControllers> {
  bool _isLoading = false;
  bool _isButtonDisabled = false;
  bool _isExpanded = false;
  List<Map<String, dynamic>> _cartSummary = [];

  @override
  void initState() {
    super.initState();
    _loadCartSummary();
  }

  Future<void> _loadCartSummary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList('cart_summary_items');

    if (data != null) {
      _cartSummary = data.map((line) {
        final parts = line.split('|');
        return {
          'title': parts[0],
          'quantity': int.parse(parts[1]),
          'totalWithGST': double.parse(parts[2]),
          'gst': double.parse(parts[3]),
        };
      }).toList();
    }

    setState(() {});
  }

  Future<void> _handleCheckout(String paymentMethod) async {
    setState(() => _isLoading = true);

    try {
      String mappedType = (widget.type == 'cartNow') ? 'cartNow' : 'buyNow';

      final Map<String, dynamic> requestBody = {
        'paymentMethod': paymentMethod,
        'type': mappedType,
        'deliveryId': widget.selectedDeliveryId,
        'totalAmount': widget.totalAmount,
      };

      if (mappedType == 'buyNow') {
        final int qty = int.tryParse(widget.quantity ?? '1') ?? 1;
        requestBody['productId'] = widget.productId;
        requestBody['quantity'] = qty;
        if (widget.offerId != null && widget.offerId!.isNotEmpty) {
          requestBody['offerId'] = widget.offerId;
        }
      }

      print("Checkout Payload: ${jsonEncode(requestBody)}");

      if (paymentMethod == 'online') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              type: mappedType,
              productId: widget.productId,
              offerId: widget.offerId,
              deliveryId: widget.selectedDeliveryId,
              quantity: widget.quantity,
              totalAmount: widget.totalAmount,
            ),
          ),
        );
      } else {
        final result = await CheckoutPaymentService.checkout(requestBody);
        final orderId = result['order']['orderId']; // ✅ fixed extraction
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderId: orderId)),
          (route) => false,
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content: Text('Error during checkout: $e'),
      //       backgroundColor: Colors.red),
      // );
      showTopSnackBar(context, 'Error during checkout: $e');
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showBottomAlert(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    "Confirm Cash on Delivery order?",
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 14,
                      fontWeight: FontWeight.bold,
                      color: mythemecolor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/confirm.png',
                    height:  isTablet ? 200 : 120,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 5,),
                  SafeArea(
                    bottom: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                mythemecolor1,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child:  Text(
                            "CANCEL",
                            style: TextStyle(
                              fontSize:  isTablet ? 20 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isButtonDisabled
                              ? null // Disable the button after click
                              : () {
                                  setState(() {
                                    _isButtonDisabled =
                                        true; // Disable after click
                                  });
                                  _handleCheckout(
                                      'cod'); // Handle the payment process
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isButtonDisabled
                                ? Colors.grey // Change to grey when disabled
                                : mythemecolor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            _isButtonDisabled ? "CONFIRMED" : "CONFIRM",
                            style:  TextStyle(
                              fontSize: isTablet ? 20 :  12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                  mythemecolor1,
               mythemecolor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "Mode of Payment",
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
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isTablet ? _buildPayTab(context) : _buildPayMob(context);
                });
              },
              color: const Color.fromARGB(255, 13, 75, 15),
              backgroundColor: const Color.fromARGB(255, 245, 240, 242),
              displacement: 40,
              strokeWidth: 2.5,
              child: isTablet ? _buildPayTab(context) : _buildPayMob(context),
            ),
    );
  }

  Widget _buildBuyNowSummary() {
    if (_cartSummary.isEmpty) {
      return Text("No summary available.");
    }

    final item = _cartSummary[0]; // Only one item in buy now
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['title'],
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Quantity: ${item['quantity']}",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        Text(
          "Price + GST: ₹${item['totalWithGST']. round()}",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        Text(
          "GST: ${item['gst']. round()}%",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCartSummary() {
    if (_cartSummary.isEmpty) {
      return Text("No summary available.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _cartSummary.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Quantity: ${item['quantity']}",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              Text(
                "Price + GST: ₹${item['totalWithGST']. round()}",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              Text(
                "GST: ${item['gst']. round()}%",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPayMob(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                iconColor: Colors.grey,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '₹${widget.totalAmount. round()}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                children: [
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: widget.type == 'buyNow'
                        ? _buildBuyNowSummary()
                        : _buildCartSummary(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isExpanded = expanded;
                    });
                  },
                  leading: Icon(
                    Icons.money,
                    color: _isExpanded
                        ? Colors.black87
                        : const Color.fromARGB(255, 41, 41, 41),
                  ),
                  title: Text(
                    'Cash On Delivery',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _showBottomAlert(context),
                        label: Text(
                          "PLACE ORDER",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              mythemecolor1
,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isExpanded = expanded;
                    });
                  },
                  leading: Icon(
                    Icons.payment,
                    color: _isExpanded
                        ? Colors.black87
                        : Color.fromARGB(255, 41, 41, 41),
                  ),
                  title: Text(
                    'Online Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: () => _handleCheckout('online'),
                        label: Text(
                          "PROCEED FOR TRANSACTION",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              mythemecolor1
,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock,
                    size: 16,
                    color:
                        const Color.fromARGB(255, 10, 4, 43).withOpacity(0.7)),
                const SizedBox(width: 8),
                Text(
                  'Secure 256-bit SSL encrypted payment',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        const Color.fromARGB(255, 81, 81, 81).withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 10,
                children: [
                  Image.asset('assets/images/rupay.png', height: 14),
                  Image.asset('assets/images/master.png', height: 14),
                  Image.asset('assets/images/upi.png', height: 16),
                  Image.asset('assets/images/visa.png', height: 14),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white.withOpacity(0.5),
              margin: EdgeInsets.all(16.0),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 95, 95, 94),
                            Color.fromARGB(255, 168, 167, 166)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.lock_outline,
                          size: 20, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "100% Secure Transactions",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "We guarantee secure payments and trustable delivery options.",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  // Widget _buildPayTab(BuildContext context) {
  //   return SingleChildScrollView(
  //     physics: AlwaysScrollableScrollPhysics(),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
  //       child: Column(
  //         children: <Widget>[
  //           const SizedBox(height: 20),

  //           Card(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20)),
  //             margin: const EdgeInsets.symmetric(vertical: 12),
  //             elevation: 12,
  //             child: Container(
  //               padding: const EdgeInsets.all(24),
  //               decoration: BoxDecoration(
  //                 gradient: const LinearGradient(
  //                   colors: [
  //                     Color.fromARGB(255, 217, 254, 228),
  //                     Color.fromARGB(255, 198, 239, 200),
  //                   ],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const Text(
  //                     'Total Amount:',
  //                     style:
  //                         TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //                   ),
  //                   Text(
  //                     '₹${widget.totalAmount. round()}',
  //                     style: const TextStyle(
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color.fromARGB(255, 2, 57, 4),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),

  //           const SizedBox(height: 40),
  //           ExpansionTile(
  //             leading: const Icon(Icons.money,
  //                 color: Color.fromARGB(255, 20, 115, 22), size: 32),
  //             title: const Text(
  //               'Cash On Delivery',
  //               style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color.fromARGB(221, 54, 54, 54)),
  //             ),
  //             children: <Widget>[
  //               Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  //                 child: ElevatedButton.icon(
  //                   onPressed: () => _showBottomAlert(context),
  //                   icon: const Icon(Icons.shopping_bag, color: Colors.white),
  //                   label: const Text(
  //                     "PLACE ORDER",
  //                     style: TextStyle(
  //                         fontSize: 20,
  //                         color: Colors.black87,
  //                         fontWeight: FontWeight.bold),
  //                   ),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color.fromARGB(255, 151, 225, 252),
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 28, vertical: 16),
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(15)),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //             ],
  //           ),

  //           const SizedBox(height: 40),

  //           ExpansionTile(
  //             leading:
  //                 const Icon(Icons.credit_card, color: Colors.blue, size: 32),
  //             title: const Text(
  //               'Online Payment',
  //               style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color.fromARGB(221, 54, 54, 54)),
  //             ),
  //             children: <Widget>[
  //               Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  //                 child: ElevatedButton.icon(
  //                   onPressed: () => _handleCheckout('online'),
  //                   icon: const Icon(Icons.payment, color: Colors.white),
  //                   label: const Text(
  //                     "Proceed for Transaction",
  //                     style: TextStyle(
  //                         fontSize: 20,
  //                         color: Colors.black87,
  //                         fontWeight: FontWeight.bold),
  //                   ),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color.fromARGB(255, 151, 225, 252),
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 28, vertical: 16),
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(15)),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //             ],
  //           ),

  //           const SizedBox(height: 40),

  //           // Secure Transaction Card
  //           const Card(
  //             color: Color.fromARGB(255, 198, 239, 200),
  //             margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //             elevation: 8,
  //             child: Padding(
  //               padding: EdgeInsets.all(24.0),
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.lock, color: Colors.green, size: 30),
  //                   SizedBox(width: 20),
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           "100% Secure Transactions",
  //                           style: TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.black),
  //                         ),
  //                         SizedBox(height: 10),
  //                         Text(
  //                           "We guarantee secure payments and trustable delivery options.",
  //                           style:
  //                               TextStyle(fontSize: 18, color: Colors.black54),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPayTab(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          widget.type == 'buyNow'
                              ? _buildBuyNowSummary()
                              : _buildCartSummary(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '₹${widget.totalAmount. round()}',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(35),
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 500,
                        height: 200,
                        child: Card(
                          color: const Color.fromARGB(255, 206, 228, 207),
                          elevation: 3,
                          margin: const EdgeInsets.only(right: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money_rounded,
                                    size: 36, color: Colors.grey[700]),
                                const SizedBox(height: 12),
                                Text(
                                  'Cash on Delivery',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => _showBottomAlert(context),
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text("PLACE ORDER"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 227, 231, 227),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                    textStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 500,
                        height: 200,
                        child: Card(
                          color: const Color.fromARGB(255, 206, 228, 207),
                          elevation: 3,
                          margin: const EdgeInsets.only(left: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment,
                                    size: 36, color: Colors.grey[700]),
                                const SizedBox(height: 12),
                                Text(
                                  'Online Payment',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => _handleCheckout('online'),
                                  icon: const Icon(Icons.credit_card),
                                  label: const Text("PROCEED TO PAY"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 227, 231, 227),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                    textStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Secure 256-bit SSL encrypted payment',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment logos
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 25,
              children: [
                Image.asset('assets/images/rupay.png', height: 22),
                Image.asset('assets/images/master.png', height: 22),
                Image.asset('assets/images/upi.png', height: 26),
                Image.asset('assets/images/visa.png', height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



  // Future<void> _handleCheckout(String paymentMethod) async {
  //   setState(() => _isLoading = true);

  //   try {
  //     final Map<String, dynamic> requestBody = {
  //       'paymentMethod': paymentMethod,
  //       'type': widget.type,
  //       'deliveryId': widget.selectedDeliveryId,
  //       'totalAmount': widget.totalAmount,
  //     };

  //     if (widget.type == 'buyNow') {
  //       final int qty = int.tryParse(widget.quantity ?? '1') ?? 1;
  //       requestBody['productId'] = widget.productId;
  //       requestBody['quantity'] = qty;
  //       if (widget.offerId != null && widget.offerId!.isNotEmpty) {
  //         requestBody['offerId'] = widget.offerId;
  //       }
  //     }

  //     print("Checkout Payload: ${jsonEncode(requestBody)}");

  //     if (paymentMethod == 'online') {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => PaymentScreen(
  //             type: widget.type,
  //             productId: widget.productId,
  //             offerId: widget.offerId,
  //             deliveryId: widget.selectedDeliveryId,
  //             quantity: widget.quantity,
  //             totalAmount: widget.totalAmount,
  //           ),
  //         ),
  //       );
  //     } else {
  //       final result = await ApiService.checkout(requestBody);
  //       final orderId = result['orderId'];
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //             builder: (_) => OrderSuccessScreen(orderId: orderId)),
  //         (route) => false,
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text('Error during checkout: $e'),
  //           backgroundColor: Colors.red),
  //     );
  //     print(e);
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }



  // Future<void> _handleCheckout(String paymentMethod) async {
  //   setState(() => _isLoading = true);
 
  //   try {
  //     if (paymentMethod == 'cod') {
  //       Map<String, dynamic> requestBody = {
  //         'paymentMethod': 'cod',
  //         'type': widget.type,
  //         'totalAmount': widget.totalAmount,
  //         'deliveryId': widget.selectedDeliveryId,
  //       };
 
  //       if (widget.type == 'buyNow' && widget.productId != null) { 
  //         requestBody['productId'] = widget.productId;
  //         requestBody['deliveryId'] = widget.selectedDeliveryId;
  //         requestBody['quantity'] = widget.quantity;
  //       }
 
  //       final result = await ApiService.checkout(requestBody);
  //       final orderId = result['orderId'];
 
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => OrderSuccessScreen(orderId: orderId),
  //         ),
  //         (route) => false,
  //       );
  //     } else {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => PaymentScreen(
  //             offerId: widget.offerId,
  //             totalAmount: widget.totalAmount,
  //             type: widget.type,
  //             productId: widget.productId,
  //             deliveryId: widget.selectedDeliveryId,
  //             quantity:   widget.quantity,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error during checkout: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     print(e);
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // } 