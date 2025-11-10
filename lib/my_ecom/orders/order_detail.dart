import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/invoice_service.dart';
import 'package:furniture_ecom_app/core/services/offers_service.dart';
import 'package:furniture_ecom_app/core/services/orders_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<double> offerPrices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOfferPrices();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.forward();
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
        // _scaffoldMessenger.showSnackBar(
        //   SnackBar(content: Text(response['message'])),
        // );
        showTopSnackBar(
          context,
          response['message'] ?? 'Failed to cancel order',
        );
      } else {
        // _scaffoldMessenger.showSnackBar(
        //   const SnackBar(content: Text('Order cancelled successfully.')),
        // );
        showTopSnackBar(context, 'Order cancelled successfully.');
        setState(() {});
      }
    } catch (e) {
      // _scaffoldMessenger.showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
      showTopSnackBar(context, 'Error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // String formatDate(DateTime date) {
  //   return DateFormat('yyyy-MM-dd HH:mm').format(date);
  // }
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
    List<Map<String, String>> statuses = [
      {'status': 'Placed', 'icon': '✅'},
      {'status': 'Shipped', 'icon': '🚚'},
      {'status': 'Delivered', 'icon': '📦'},
    ];

    if (currentStatus == 'Cancelled') {
      statuses = [
        {'status': 'Placed', 'icon': '✅'},
        {'status': 'Cancelled', 'icon': '❌'},
      ];
    } else if (currentStatus == 'Failed') {
      statuses = [
        {'status': 'Placed', 'icon': '✅'},
        {'status': 'Failed', 'icon': '⚠️'},
      ];
    }

    final currentIndex = statuses.indexWhere(
      (element) => element['status'] == currentStatus,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: isTablet
              ? Column(
                  children: [
                    Row(
                      children: List.generate(statuses.length * 2 - 1, (i) {
                        if (i.isEven) {
                          int index = i ~/ 2;
                          bool isActive = index <= currentIndex;
                          bool isCancelled =
                              currentStatus == 'Cancelled' &&
                              index == currentIndex;
                          bool isFailed =
                              currentStatus == 'Failed' &&
                              index == currentIndex;

                          return Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: 55,
                                  height: 55,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: (isCancelled || isFailed)
                                        ? const Color.fromARGB(
                                            255,
                                            249,
                                            149,
                                            142,
                                          )
                                        : (isActive
                                              ? mythemecolor
                                              : Colors.grey.shade300),
                                    shape: BoxShape.circle,
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: mythemecolor,
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    statuses[index]['icon']!,
                                    style: const TextStyle(fontSize: 27),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          int leftIndex = i ~/ 2;
                          bool isActive = leftIndex < currentIndex;

                          return Expanded(
                            flex: 2,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 800),
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isActive
                                      ? [mythemecolor, mythemecolor]
                                      : [
                                          Colors.grey.shade300,
                                          Colors.grey.shade400,
                                        ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Status text & updated time
                    Row(
                      children: List.generate(statuses.length * 2 - 1, (i) {
                        if (i.isEven) {
                          int index = i ~/ 2;
                          bool isActive = index <= currentIndex;

                          final matchingEntry = statusHistory.firstWhere(
                            (entry) =>
                                entry.status == statuses[index]['status'],
                            orElse: () => OrderStatusEntry(
                              status: '',
                              timestamp: DateTime(2000),
                            ),
                          );

                          final updatedText = matchingEntry.status.isNotEmpty
                              ? formatDate(matchingEntry.timestamp.toLocal())
                              //  formatDate(matchingEntry.timestamp)
                              : '—';
                          final status = statuses[index]['status'] ?? '';

                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isActive
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Updated: $updatedText",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Expanded(child: SizedBox());
                        }
                      }),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(statuses.length, (index) {
                    bool isActive = index <= currentIndex;
                    bool isCancelled =
                        currentStatus == 'Cancelled' && index == currentIndex;
                    bool isFailed =
                        currentStatus == 'Failed' && index == currentIndex;

                    // final OrderStatusEntry? matchingEntry = statusHistory
                    //     .firstWhereOrNull(
                    //       (entry) => entry.status == statuses[index]['status'],
                    //     );
                    final OrderStatusEntry? matchingEntry =
                        statusHistory.isNotEmpty
                        ? statusHistory.firstWhere(
                            (entry) =>
                                entry.status == statuses[index]['status'],
                            orElse: () => OrderStatusEntry(
                              status: '',
                              timestamp: DateTime(2000),
                            ),
                          )
                        : null;

                    Text(
                      "Updated: ${matchingEntry != null ? formatDate(matchingEntry.timestamp) : '—'}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    );

                    final icon = statuses[index]['icon'] ?? '';
                    final status = statuses[index]['status'] ?? '';

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: (isCancelled || isFailed)
                                      ? const Color.fromARGB(255, 249, 149, 142)
                                      : (isActive
                                            ? mythemecolor
                                            : Colors.grey.shade300),
                                  shape: BoxShape.circle,
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: mythemecolor,
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              if (index != statuses.length - 1)
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 800),
                                  width: 5,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: index < currentIndex
                                          ? [
                                              mythemecolor,
                                              mythemecolor,
                                            ]
                                          : [
                                              Colors.grey.shade300,
                                              Colors.grey.shade400,
                                            ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: isActive ? 1.0 : 0.6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.black
                                            : Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Updated: ${matchingEntry != null ? formatDate(matchingEntry.timestamp) : '—'}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
                _animationController = AnimationController(
                  vsync: this,
                  duration: const Duration(seconds: 2),
                );
                _animationController.forward();
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
                              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 600,
                                    child: Card(
                                      color: const Color.fromARGB(
                                        255,
                                        244,
                                        245,
                                        245,
                                      ),
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(" 📍 "),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Shipping Address",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                      255,
                                                      6,
                                                      40,
                                                      100,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              height: 24,
                                              color: Color.fromARGB(
                                                255,
                                                28,
                                                117,
                                                20,
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: mythemecolor,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  order.username,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  color: mythemecolor,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  order.phoneNo,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),

                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.home,
                                                  color: mythemecolor,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${order.houseNo}, ${order.streetName}, ${order.city}, ${order.state} - ${order.pinCode}',
                                                    maxLines: 5,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.grey[800],
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
                                  SizedBox(
                                    width: 600,
                                    child: Card(
                                      color: const Color.fromARGB(
                                        255,
                                        244,
                                        245,
                                        245,
                                      ),
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.all(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text("🚚"),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Order Status",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                      255,
                                                      6,
                                                      40,
                                                      100,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Status of the Order  : ${order.status}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Date of the Order     : ${formatDate(order.orderDate)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Payment Method     : ${order.paymentMethod}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Row(
                                              children: [
                                                const Text(" 📍 "),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Shipping Address",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              height: 20,
                                              color: Color.fromARGB(
                                                255,
                                                232,
                                                231,
                                                231,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.black87,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    order.username,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.phone,
                                                  color: Colors.black87,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    order.phoneNo,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.black87,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    '${order.houseNo}, ${order.streetName}, ${order.city},\n ${order.state} - ${order.pinCode}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      height: 20,
                                      color: Color.fromARGB(255, 232, 231, 231),
                                    ),
                                    SizedBox(
                                      width: 600,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text("🚚"),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Status of Order",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Status of Order      : ${order.status}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Date of the Order   : ${formatDate(order.orderDate)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Payment Method   : ${order.paymentMethod}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                                    'Original Price: ₹${order.items[index].offerPrice.round()}', // ✅ This is correct
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
                                                'Original Price: ₹${(offerPrices.length > index ? offerPrices[index] : 0.0).round()}',
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
