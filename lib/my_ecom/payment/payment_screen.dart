

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services/checkout_payment.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_success.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String? productId;
  final String type;
  final String? offerId;
  final String? deliveryId;
  final String? quantity;
  const PaymentScreen({
    super.key,
    required this.totalAmount,
    this.productId,
    required this.type,
    this.deliveryId,
    required this.offerId,
    required this.quantity,
  });


  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  bool _isLoading = false;
  bool _paymentInitiated = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _animationController.dispose(); 
    super.dispose();
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isLoading = false);

    try {
      if (response.orderId == null ||
          response.paymentId == null ||
          response.signature == null) {
        throw Exception('Missing payment details from Razorpay.');
      }

      final success = await CheckoutPaymentService.confirmPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => OrderSuccessScreen(orderId: response.orderId!),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Payment verification failed: $e')),
      // );
      showTopSnackBar(context, 'Payment verification failed: $e');
    }
  }

  void handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message}",
      backgroundColor: Colors.red,
    );
    print(response.message);
  }


  Future<void> _startPayment() async {
  setState(() {
    _isLoading = true;
    _paymentInitiated = true;
  });

  try {
    if (widget.deliveryId == null || widget.deliveryId!.isEmpty) {
      throw Exception('Delivery address is required');
    }

    final Map<String, dynamic> requestBody = {
      'paymentMethod': 'online',
      'type': widget.type,
      'deliveryId': widget.deliveryId,
    };

    if (widget.type == 'buyNow') {
      final int qty = int.tryParse(widget.quantity ?? '1') ?? 1;
      requestBody['quantity'] = qty;
      
      if (widget.offerId != null) {
        requestBody['offerId'] = widget.offerId;
      } else if (widget.productId != null) {
        requestBody['productId'] = widget.productId;
      } else {
        throw Exception('Product information missing');
      }
    }

    debugPrint('Payment Request: ${jsonEncode(requestBody)}');

    final response = await CheckoutPaymentService.checkout(requestBody);
    debugPrint('Checkout Response: ${jsonEncode(response)}');

    if (response['paymentDetails']?['razorpayOrderId'] == null) {
      throw Exception('Failed to create payment order');
    }

    final options = {
      'key': response['key_id'] ?? 'rzp_test_w5BdYCzO09lwRx',
      'amount': (widget.totalAmount * 100).toStringAsFixed(0), 
      'order_id': response['paymentDetails']['razorpayOrderId'],
      'name': 'Your App Name',
      'description': widget.type == 'buyNow' ? 'Product Purchase' : 'Cart Checkout',
      'prefill': {
        'contact': '9876543210', 
        'email': 'user@example.com', 
      },
      'theme': {'color': '#0078FF'}
    };

    debugPrint('Razorpay Options: $options');
    _razorpay.open(options);

  } catch (e, stackTrace) {
    debugPrint('Payment Error: $e\n$stackTrace');
    setState(() {
      _isLoading = false;
      _paymentInitiated = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${e.toString()}'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _startPayment,
        ),
      ),
    );
  }
}




@override
Widget build(BuildContext context) {
  final bool isTablet = MediaQuery.of(context).size.width > 600;
  
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 196, 241, 250).withOpacity(0.9),
            const Color.fromARGB(255, 250, 250, 250),
            const Color.fromARGB(255, 196, 241, 250).withOpacity(0.9),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: isTablet 
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(255, 196, 241, 250).withOpacity(0.9),
                              const Color.fromARGB(255, 250, 250, 250),
                              const Color.fromARGB(255, 196, 241, 250).withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: _buildPaymentContent(),
                      ),
                    ),
                  ),
                )
              : _buildPaymentContent(),
        ),
      ),
    ),
  );
}

Widget _buildPaymentContent() {
  return Column(
    children: [
      AppBar(
        backgroundColor: const Color.fromARGB(0, 31, 156, 223),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (!_isLoading) Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Secure Payment Gateway",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 3, 67, 122),
          ),
        ),
        centerTitle: true,
      ),
      Expanded(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/json/pay.json',
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  'Complete Your Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Total Amount: ₹${widget.totalAmount. round()}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: const Color.fromARGB(255, 20, 80, 139).withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 38),
                
                if (_paymentInitiated)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'Please wait while we process your payment...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.blue.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                
                if (!_paymentInitiated)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _startPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey;
                            }
                            return Colors.white;
                          },
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment,
                            color: _isLoading ? Colors.grey : Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Proceed to Pay",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isLoading ? Colors.grey : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), 
                
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 16, 
                        color: const Color.fromARGB(255, 10, 4, 43).withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text(
                      'Secure 256-bit SSL encrypted payment',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 25, 68, 133).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    Image.asset('assets/images/rupay.png', height: 20),
                    Image.asset('assets/images/master.png', height: 20),
                    Image.asset('assets/images/upi.png', height: 20),
                    Image.asset('assets/images/visa.png', height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
}

