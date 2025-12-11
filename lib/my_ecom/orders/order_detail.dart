import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/invoice_service.dart';
import 'package:furniture_ecom_app/core/services_ecom/offers_service.dart';
import 'package:furniture_ecom_app/core/services_ecom/orders_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';
import 'package:furniture_ecom_app/my_ecom/product/product_detail.dart';
import 'package:intl/intl.dart';

import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<double> offerPrices = [];
  bool isLoading = true;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchOfferPrices();
  //   _animationController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 2),
  //   );
  //   _animationController.forward();
  // }

  @override
  void initState() {
    super.initState();
    fetchOfferPrices();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  void fetchOfferPrices() async {
    try {
      offerPrices = await OfferService.fetchOnlyOfferPrices(widget.orderId);
      print("Fetched Offer Prices: $offerPrices");

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching offer prices: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> requestManageStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (status.isGranted) {
      await _downloadInvoice(context);
    } else {
      if (status.isPermanentlyDenied) {
        openAppSettings();
        // _scaffoldMessenger.showSnackBar(
        //   const SnackBar(
        //       content: Text(
        //           'Storage permission permanently denied. Please enable it in settings.')),
        // );
        showTopSnackBar(
          context,
          'Storage permission permanently denied. Please enable it in settings.',
        );
      } else {
        // _scaffoldMessenger.showSnackBar(
        //   const SnackBar(
        //       content: Text(
        //           'Storage permission denied. Cannot download the invoice.')),
        // );
        showTopSnackBar(
          context,
          'Storage permission denied. Cannot download the invoice.',
        );
      }
    }
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    try {
      final result = await InvoiceDetailsService.downloadInvoice(
        widget.orderId,
      );
      if (result['success']) {
        final filePath = result['filePath'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 9),
            content: const Text('Invoice downloaded successfully'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                OpenFile.open(filePath);
              },
            ),
          ),
        );
        print('Invoice saved at: $filePath');
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(result['message']),
        //   ),
        // );
        showTopSnackBar(
          context,
          result['message'] ?? 'Failed to download invoice',
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Failed to download invoice: $e'),
      //   ),
      // );
      showTopSnackBar(context, 'Failed to download invoice: $e');
    }
  }

  void _showBottomAlert(BuildContext context, String orderId) {
    bool isButtonDisabled = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  const Text(
                    "Are you sure! \n You want to cancel this order?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/confirm.png',
                    height: 120,
                    fit: BoxFit.fitWidth,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text(
                          "NO",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: mythemecolor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isButtonDisabled
                            ? null
                            : () {
                                setState(() {
                                  isButtonDisabled = true;
                                });
                                _cancelOrder(context, orderId).then((_) {
                                  Navigator.pop(context);
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonDisabled
                              ? Colors.grey
                              : Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          isButtonDisabled ? "CANCELLING..." : "YES, CANCEL",
                          style: const TextStyle(
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
            );
          },
        );
      },
    );
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    try {
      final response = await OrderService.cancelOrder(orderId);
      if (response['error'] == true) {
       
        showTopSnackBar(
          context,
          response['message'] ?? 'Failed to cancel order',
        );
      } else {
        
        showTopSnackBar(context, 'Order cancelled successfully.');
        setState(() {});
      }
    } catch (e) {
     
      showTopSnackBar(context, 'Error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
  }

  Widget buildOrderItemsList(Order order) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;

        return isTablet
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  final offerPrice = offerPrices.length > index
                      ? offerPrices[index]
                      : 0.0;
                  return buildOrderItemCard(item, offerPrice);
                  // return buildOrderItemCard(item);
                },
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  // final item = order.items[index];

                  // return buildOrderItemCard(item);
                  final item = order.items[index];
                  final offerPrice = offerPrices.length > index
                      ? offerPrices[index]
                      : 0.0;
                  return buildOrderItemCard(item, offerPrice);
                },
              );
      },
    );
  }

  Widget buildOrderItemCard(item, double offerPrice) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.productImage,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹${offerPrice.round()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mythemecolor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeline(
    String currentStatus,
    List<OrderStatusEntry> statusHistory,
  ) {
    List<Map<String, dynamic>> statuses = [
      {'status': 'Placed', 'icon': Icons.check_circle},
      {'status': 'Shipped', 'icon': Icons.local_shipping_rounded},
      {'status': 'Delivered', 'icon': Icons.inventory_2_rounded},
    ];

    if (currentStatus == 'Cancelled') {
      statuses = [
        {'status': 'Placed', 'icon': Icons.check_circle},
        {'status': 'Cancelled', 'icon': Icons.cancel_rounded},
      ];
    } else if (currentStatus == 'Failed') {
      statuses = [
        {'status': 'Placed', 'icon': Icons.check_circle},
        {'status': 'Failed', 'icon': Icons.warning_rounded},
      ];
    }

    final currentIndex = statuses.indexWhere(
      (e) => e['status'] == currentStatus,
    );

    // OrderStatusEntry? getEntry(String s) {
    //   try {
    //     return statusHistory.firstWhere((e) => e.status == s);
    //   } catch (_) {
    //     return null;
    //   }
    // }

    OrderStatusEntry? getEntry(String status) {
  // real entry from backend
  final entry = statusHistory.cast<OrderStatusEntry?>().firstWhere(
        (e) => e?.status == status,
        orElse: () => null,
      );

  // ✅ Frontend fallback for Cancelled / Failed
  if (entry == null &&
      (status == 'Cancelled' || status == 'Failed') &&
      currentStatus == status) {
    return OrderStatusEntry(
      status: status,
      // best fallback: NOW or orderDate
      timestamp: DateTime.now(),
    );
  }

  return entry;
}


    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return Card(
          elevation: 12,
          shadowColor: mythemecolor.withOpacity(0.25),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),

            /// ================= TABLET =================
            child: isTablet
                ? Column(
                    children: [
                      Row(
                        children: List.generate(statuses.length * 2 - 1, (i) {
                          if (i.isEven) {
                            final index = i ~/ 2;
                            final isActive = index <= currentIndex;
                            final isCurrent = index == currentIndex;

                            return Expanded(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutBack,
                                scale: isCurrent ? 1.15 : 1.0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isActive
                                        ? LinearGradient(
                                            colors: [
                                              mythemecolor,
                                              mythemecolor.withOpacity(0.8),
                                            ],
                                          )
                                        : null,
                                    color: isActive
                                        ? null
                                        : Colors.grey.shade200,
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                              color: mythemecolor.withOpacity(
                                                0.35,
                                              ),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Icon(
                                    statuses[index]['icon'],
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            );
                          }

                          final active = (i ~/ 2) < currentIndex;
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 700),
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: active
                                      ? [
                                          mythemecolor,
                                          mythemecolor.withOpacity(0.7),
                                        ]
                                      : [
                                          Colors.grey.shade300,
                                          Colors.grey.shade300,
                                        ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: statuses.map((s) {
                          final entry = getEntry(s['status']);
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  s['status'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: Text(
                                    entry != null
                                        ? formatDate(entry.timestamp)
                                        : 'Pending',
                                    key: ValueKey(entry?.timestamp ?? 'x'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                /// ================= MOBILE =================
                : Column(
                    children: List.generate(statuses.length, (i) {
                      final isActive = i <= currentIndex;
                      final entry = getEntry(statuses[i]['status']);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutBack,
                                  height: 34,
                                  width: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isActive
                                        ? LinearGradient(
                                            colors: [
                                              mythemecolor,
                                              const Color.fromARGB(
                                                255,
                                                112,
                                                93,
                                                126,
                                              ).withOpacity(0.85),
                                            ],
                                          )
                                        : null,
                                    color: isActive
                                        ? null
                                        : const Color.fromARGB(
                                            255,
                                            112,
                                            110,
                                            110,
                                          ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              blurRadius: 10,
                                              color: mythemecolor.withOpacity(
                                                0.35,
                                              ),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Icon(
                                    statuses[i]['icon'],
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                if (i != statuses.length - 1)
                                  Container(
                                    height: 36,
                                    width: 3,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: isActive
                                          ? mythemecolor1
                                          : const Color.fromARGB(
                                              255,
                                              116,
                                              115,
                                              115,
                                            ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statuses[i]['status'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: Text(
                                    entry != null
                                        ? formatDate(entry.timestamp)
                                        : '',
                                    key: ValueKey(entry?.timestamp ?? 'x'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
          ),
        );
      },
    );
  }

  Widget buildAmountRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? mythemecolor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget premiumCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9FAFB), Color(0xFFF1F3F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget shippingAddressCard(BuildContext context, Order order) {
    return premiumCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: mythemecolor, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: mythemecolor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),

            _infoRow(Icons.person, order.dealername),
            const SizedBox(height: 8),
            _infoRow(Icons.phone, order.phoneNo),
            const SizedBox(height: 8),
            _infoRow(
              Icons.home_rounded,
              '${order.houseNo}, ${order.streetName},\n'
              '${order.city}, ${order.state} - ${order.pinCode}',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: mythemecolor, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black
            ),
          ),
        ),
      ],
    );
  }

  Widget orderStatusCard(Order order) {
    return premiumCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping_rounded,
                  color: mythemecolor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: mythemecolor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: const Color.fromARGB(255, 102, 100, 100)),
            const SizedBox(height: 12),

            _statusRow('Status', order.status),
            const SizedBox(height: 6),
            _statusRow('Ordered On', formatDate(order.orderDate)),
            const SizedBox(height: 6),
            _statusRow('Payment', order.paymentMethod),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
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
              "Order  Details",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: FutureBuilder<Order>(
        future: OrderService.fetchOrderDetail(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AnimationPage1());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No details found.'));
          } else {
            final order = snapshot.data!;
            final showCancelButton = order.status == 'Placed';
            final showInvoiceButton = order.status == 'Delivered';

            return RefreshIndicator(
              onRefresh: () async {
                fetchOfferPrices();
                _animationController.forward(from: 0);
              },

              color: mythemecolor,
              backgroundColor: const Color.fromARGB(255, 245, 240, 242),
              displacement: 40,
              strokeWidth: 2.5,
              child: SafeArea(
                bottom: true,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Order ID - ${order.orderId}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: mythemecolor,
                          ),
                        ),
                      ),
                      const Divider(
                        height: 24,
                        color: Color.fromARGB(255, 108, 109, 108),
                      ),
                      buildTimeline(order.status, order.statusHistory),
                      const Divider(
                        height: 24,
                        color: Color.fromARGB(255, 99, 100, 99),
                      ),
                      isTablet
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: shippingAddressCard(context, order),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(child: orderStatusCard(order)),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  shippingAddressCard(context, order),
                                  const SizedBox(height: 16),
                                  orderStatusCard(order),
                                ],
                              ),
                            ),
                      const SizedBox(height: 8),
                      const Divider(
                        height: 24,
                        color: Color.fromARGB(255, 224, 223, 223),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Paid:   ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'GST Inclusive Price',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '₹${order.overallTotal.round()}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: mythemecolor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ExpansionTile(
                        initiallyExpanded: false,
                        title: const Text(
                          "Payment Summary",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: mythemecolor,
                          ),
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                        backgroundColor: const Color.fromARGB(
                          255,
                          221,
                          215,
                          222,
                        ),
                        collapsedBackgroundColor: const Color.fromARGB(
                          255,
                          221,
                          215,
                          222,
                        ),
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        children: [
                          buildAmountRow(
                            "Payment Method:",
                            order.paymentMethod.toUpperCase(),
                          ),
                          buildAmountRow(
                            "Subtotal:",
                            "₹${(order.overallTotal - order.gstAmount).round()}",
                          ),
                          buildAmountRow("GST:", "₹${order.gstAmount.round()}"),
                          const Divider(),
                          buildAmountRow(
                            "Total Paid:",
                            "₹${order.overallTotal.round()}",
                            isTotal: true,
                          ),
                        ],
                      ),
                      const Divider(
                        height: 24,
                        color: Color.fromARGB(255, 224, 223, 223),
                      ),
                      const Text(
                        "Items Ordered:",
                        style: TextStyle(
                          color: mythemecolor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      isTablet
                          ? SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: order.items.length,
                                itemBuilder: (context, index) {
                                  final item = order.items[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailPagep(
                                                  productId: item.productId,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Container(
                                          width: 230,
                                          padding: const EdgeInsets.all(9.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 150,
                                                child: Image.network(
                                                  item.productImage,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.productTitle,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Color.fromARGB(
                                                          255,
                                                          83,
                                                          82,
                                                          82,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    'Qty: ${item.quantity}',
                                                    style: const TextStyle(
                                                      fontSize: 19,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Selling Price: ₹${order.items[index].offerPrice.round()}', // ✅ This is correct
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color.fromARGB(
                                                        255,
                                                        8,
                                                        69,
                                                        8,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.items.length,
                              itemBuilder: (context, index) {
                                final item = order.items[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailPagep(
                                              productId: item.productId,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          item.productImage,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productTitle,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Selling Price: ₹${(offerPrices.length > index ? offerPrices[index] : 0.0).round()}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Quantity: ${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color.fromARGB(
                                                    255,
                                                    134,
                                                    134,
                                                    133,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                      Center(
                        child: SafeArea(
                          bottom: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (showInvoiceButton)
                                if (order.status != 'Cancelled')
                                  ElevatedButton(
                                    onPressed: () =>
                                        requestManageStoragePermission(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: mythemecolor,
                                      padding: EdgeInsets.all(10),
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text("DOWNLOAD INVOICE"),
                                  ),
                              if (showCancelButton)
                                ElevatedButton(
                                  onPressed: () =>
                                      _showBottomAlert(context, order.orderId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mythemecolor,
                                    padding: EdgeInsets.all(10),
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text("CANCEL ORDER"),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
