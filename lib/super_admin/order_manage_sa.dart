// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/constants/colors.dart';
// import 'package:furniture_ecom_app/models/order_history.dart';
// import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';
// bool isSameDate(DateTime d1, DateTime d2) =>
//     d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

// List<FurnitureOrder> filterOrders(
//   List<FurnitureOrder> orders,
//   String filterType, {
//   DateTime? from,
//   DateTime? to,
// }) {
//   DateTime today = DateTime.now();
//   DateTime startOfToday = DateTime(today.year, today.month, today.day);

//   switch (filterType) {
//     case 'All Dates':
//       return orders;

//     case 'Today':
//       return orders.where((o) => isSameDate(o.orderDate, today)).toList();

//     case 'Last 7 Days':
//       DateTime weekAgo = startOfToday.subtract(const Duration(days: 6));
//       return orders.where(
//         (o) =>
//             !o.orderDate.isBefore(weekAgo) && // >= weekAgo
//             !o.orderDate.isAfter(startOfToday), // <= today
//       ).toList();

//     case 'Specific Date':
//       if (from != null) {
//         return orders.where((o) => isSameDate(o.orderDate, from)).toList();
//       }
//       return orders;

//     case 'From-To':
//       if (from != null && to != null) {
//         DateTime fromDay = DateTime(from.year, from.month, from.day);
//         DateTime toDay = DateTime(to.year, to.month, to.day);
//         return orders.where(
//           (o) =>
//               !o.orderDate.isBefore(fromDay) && // >= from
//               !o.orderDate.isAfter(toDay),      // <= to
//         ).toList();
//       }
//       return orders;

//     default:
//       return orders;
//   }
// }

// Widget buildOrderCard(FurnitureOrder order) {
//   Color borderColor;
//   Color statusColor;

//   switch (order.status) {
//     case 'Placed':
//       borderColor = kPrimaryColor;
//       statusColor = Colors.orange;
//       break;
//     case 'Delivered':
//       borderColor = kPrimaryColor;
//       statusColor = Colors.green;
//       break;
//     case 'Cancelled':
//       borderColor = kPrimaryColor;
//       statusColor = Colors.red;
//       break;
//     default:
//       borderColor = Colors.grey;
//       statusColor = Colors.grey;
//   }

//   return Card(
//     shape: RoundedRectangleBorder(
//       side: BorderSide(color: borderColor, width: 3),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.shopping_cart, color: statusColor),
//               const SizedBox(width: 8),
//               Text(
//                 order.status,
//                 style: TextStyle(
//                   color: statusColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Order Date: ${order.orderDate.month}/${order.orderDate.day}/${order.orderDate.year}',
//           ),
//           Text('Order Quantity: ${order.quantity}'),
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.all(8),
//             color: Colors.grey[200],
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Username: ${order.username}'),
//                 Text('Phone: ${order.phone}'),
//                 Text('Address: ${order.address}'),
//                 Text('Product: ${order.productName}'),
//                 Text('Price: ₹${order.price}'),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Total: ₹${order.totalAmount}',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// class OrdersPage extends StatefulWidget {
//   const OrdersPage({super.key});

//   @override
//   State<OrdersPage> createState() => _OrdersPageState();
// }

// class _OrdersPageState extends State<OrdersPage> {
//   String selectedFilter = 'All Dates';
//   DateTime? specificDate;
//   DateTime? fromDate;
//   DateTime? toDate;

//   Future<DateTime?> _pickDate(
//     BuildContext context,
//     DateTime? initialDate,
//   ) async {
//     return await showDatePicker(
//       context: context,
//       initialDate: initialDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: kPrimaryColor, // header background color
//               onPrimary: Colors.white, // header text color
//               onSurface: Colors.black, // body text color
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: kPrimaryColor, // CANCEL/OK button color
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<FurnitureOrder> filteredOrders = filterOrders(
//       dummyOrders,
//       selectedFilter,
//       from: selectedFilter == 'Specific Date' ? specificDate : fromDate,
//       to: toDate,
//     );

//     double totalRevenue = dummyOrders.fold(0, (sum, o) => sum + o.totalAmount);
//     double filteredRevenue = filteredOrders.fold(
//       0,
//       (sum, o) => sum + o.totalAmount,
//     );

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: kPrimaryColor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             title: Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Text(
//                 'Order Details with Revenue',
//                 style: AppTextStyles.heading,
//               ),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//           ),
//         ),
//       ),
//       drawer: const SuperAdminDrawer(currentPage: "Order Details with Amount"),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: DropdownButton<String>(
//                       value: selectedFilter,
//                       items:
//                           [
//                                 'All Dates',
//                                 'Today',
//                                 'Last 7 Days',
//                                 'Specific Date',
//                                 'From-To',
//                               ]
//                               .map(
//                                 (filter) => DropdownMenuItem(
//                                   value: filter,
//                                   child: Text(filter),
//                                 ),
//                               )
//                               .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedFilter = value!;
//                         });
//                       },
//                     ),
//                   ),
//                   if (selectedFilter == 'Specific Date')
//                     TextButton(
//                       onPressed: () async {
//                         DateTime? picked = await _pickDate(
//                           context,
//                           specificDate,
//                         );
//                         if (picked != null) {
//                           setState(() => specificDate = picked);
//                         }
//                       },
//                       style: TextButton.styleFrom(
//                         foregroundColor: kPrimaryColor,
//                       ),
//                       child: Text(
//                         specificDate == null
//                             ? 'Pick Date'
//                             : '${specificDate!.month}/${specificDate!.day}/${specificDate!.year}',
//                       ),
//                     ),
//                   if (selectedFilter == 'From-To') ...[
//                     TextButton(
//                       onPressed: () async {
//                         DateTime? picked = await _pickDate(context, fromDate);
//                         if (picked != null) setState(() => fromDate = picked);
//                       },
//                       style: TextButton.styleFrom(
//                         foregroundColor: kPrimaryColor, // Text color
//                       ),
//                       child: Text(
//                         fromDate == null
//                             ? 'From'
//                             : '${fromDate!.month}/${fromDate!.day}/${fromDate!.year}',
//                       ),
//                     ),

//                     TextButton(
//                       onPressed: () async {
//                         DateTime? picked = await _pickDate(context, toDate);
//                         if (picked != null) setState(() => toDate = picked);
//                       },
//                       style: TextButton.styleFrom(
//                         foregroundColor: kPrimaryColor, // Text color
//                       ),
//                       child: Text(
//                         toDate == null
//                             ? 'To'
//                             : '${toDate!.month}/${toDate!.day}/${toDate!.year}',
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               const SizedBox(height: 12),
//               // Totals
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 color: Colors.blueGrey[50],
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Total Revenue (All Orders): ₹$totalRevenue',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Revenue for Selected Filter: ₹$filteredRevenue',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Order list
//               Expanded(
//                 child: filteredOrders.isEmpty
//                     ? const Center(child: Text('No orders found'))
//                     : ListView.builder(
//                         itemCount: filteredOrders.length,
//                         itemBuilder: (context, index) =>
//                             buildOrderCard(filteredOrders[index]),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// orders_page_manager.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/api/admin_api_service.dart';
import '../../core/model/orders_model.dart';

class OrdersPageSuperAdmin extends StatefulWidget {
  const OrdersPageSuperAdmin({super.key});
  @override
  State<OrdersPageSuperAdmin> createState() => _OrdersPageSuperAdminState();
}

class _OrdersPageSuperAdminState extends State<OrdersPageSuperAdmin>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  List<OrderModel> _orders = [];

  // Filters
  String _search = '';
  String _selectedDateFilter = 'All'; // All, Today, Specific, Last7, Range
  DateTime? _specificDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedStatus = 'All'; // All, Placed, Shipped, Delivered, Cancelled
  String _selectedPayment = 'All'; // All, cod, online
  double? _minAmount;
  double? _maxAmount;

  late TabController _tabs;

  // debounce helper (very simple)
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _fetchOrders();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final resp = await AdminApiService.fetchOrders(
        status: _selectedStatus != 'All' ? _selectedStatus : null,
        paymentMethod: _selectedPayment != 'All'
            ? _selectedPayment.toLowerCase()
            : null,
        search: _search.isNotEmpty ? _search : null,
        filterType: _selectedDateFilter == 'Today'
            ? '1day'
            : _selectedDateFilter == 'Last 7 Days'
            ? '7day'
            : _selectedDateFilter == 'Specific'
            ? 'specific'
            : _selectedDateFilter == 'Range'
            ? 'range'
            : null,
        specificDate: _selectedDateFilter == 'Specific' && _specificDate != null
            ? DateFormat('yyyy-MM-dd').format(_specificDate!)
            : null,
        fromDate: _selectedDateFilter == 'Range' && _fromDate != null
            ? DateFormat('yyyy-MM-dd').format(_fromDate!)
            : null,
        toDate: _selectedDateFilter == 'Range' && _toDate != null
            ? DateFormat('yyyy-MM-dd').format(_toDate!)
            : null,
        minTotal: _minAmount,
        maxTotal: _maxAmount,
      );

      if (!mounted) return;
      setState(() {
        _orders = resp.orders;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _orders = [];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch orders: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Filter locally for the tab (dealer type)
  List<OrderModel> _ordersForTab(int tabIndex) {
    if (tabIndex == 0) return _orders; // All
    if (tabIndex == 1) {
      return _orders.where((o) => o.dealer.dealerType == 1).toList();
    }
    return _orders.where((o) => o.dealer.dealerType == 2).toList();
  }

  Map<String, dynamic> _computeTotals(List<OrderModel> list) {
    final count = list.length;
    final totalAmount = list.fold<double>(0, (a, b) => a + (b.overallTotal));
    return {'count': count, 'amount': totalAmount};
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initial) async {
    return showDatePicker(
      barrierColor: mythemecolor,

      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
  }

  Widget _filtersPanel({required bool isCompact}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------- SEARCH BOX --------------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: Icon(Icons.search, color: mythemecolor),
                hintText: 'Search order ID, dealer, product…',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: mythemecolor1, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: mythemecolor, width: 3),
                ),
              ),
              onChanged: (v) {
                _search = v;
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 600), () {
                  if (mounted) _fetchOrders();
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // ------------------- DROPDOWNS --------------------
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: _customDropdown(
                    label: "Date Filter",
                    value: _selectedDateFilter,
                    items: ['All', 'Today', 'Specific', 'Last7', 'Range'],
                    onChanged: (v) => setState(() => _selectedDateFilter = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _customDropdown(
                    label: "Status",
                    value: _selectedStatus,
                    items: [
                      'All',
                      'Placed',
                      'Shipped',
                      'Delivered',
                      'Cancelled',
                    ],
                    onChanged: (v) => setState(() => _selectedStatus = v),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: _customDropdown(
                    label: "Payment",
                    value: _selectedPayment,
                    items: ['All', 'cod', 'online'],
                    onChanged: (v) => setState(() => _selectedPayment = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: SizedBox()),
              ],
            ),
          ),

          const SizedBox(height: 10),
          // ------------------- DATE PICKER UI --------------------
          if (_selectedDateFilter == 'Specific') ...[
            TextButton(
              onPressed: () async {
                final picked = await _pickDate(context, _specificDate);
                if (picked != null) {
                  setState(() => _specificDate = picked);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: mythemecolor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _specificDate == null
                    ? " PICK "
                    : "   ${DateFormat('dd MMM yyyy').format(_specificDate!)}   ",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],

          if (_selectedDateFilter == 'Range') ...[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await _pickDate(context, _fromDate);
                        if (picked != null) {
                          setState(() => _fromDate = picked);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: mythemecolor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _fromDate == null
                            ? "From Date"
                            : "From: ${DateFormat('dd MMM').format(_fromDate!)}",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await _pickDate(context, _toDate);
                        if (picked != null) {
                          setState(() => _toDate = picked);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: mythemecolor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _toDate == null
                            ? "To Date"
                            : "To: ${DateFormat('dd MMM').format(_toDate!)}",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],

          // ------------------- MIN / MAX --------------------
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: _minAmount?.toString() ?? "",
                    ),
                    keyboardType: TextInputType.number,
                    decoration: _amountDecoration("Min Amount"),
                    onChanged: (v) => _minAmount = double.tryParse(v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: _maxAmount?.toString() ?? "",
                    ),
                    keyboardType: TextInputType.number,
                    decoration: _amountDecoration("Max Amount"),
                    onChanged: (v) => _maxAmount = double.tryParse(v),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ------------------- BUTTONS --------------------
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _fetchOrders,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mythemecolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "APPLY",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _search = '';
                      _selectedDateFilter = 'All';
                      _specificDate = null;
                      _fromDate = null;
                      _toDate = null;
                      _selectedStatus = 'All';
                      _selectedPayment = 'All';
                      _minAmount = null;
                      _maxAmount = null;
                    });
                    _fetchOrders();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: mythemecolor1, width: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Color.fromARGB(255, 221, 197, 251),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "RESET",
                    style: GoogleFonts.poppins(
                      color: mythemecolor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Please click apply after changing filters!",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mythemecolor, width: 3),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => onChanged(v!),
    );
  }

  InputDecoration _amountDecoration(String text) {
    return InputDecoration(
      labelText: text,
      labelStyle: GoogleFonts.poppins(fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade100,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mythemecolor, width: 3),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mythemecolor1, width: 2),
      ),
    );
  }

  Widget _orderTile(OrderModel o) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          o.dealer.companyName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: isTablet(context) ? 18 : 14,

            color: mythemecolor,
          ),
        ),
        subtitle: Text(
          "Order id: ${o.orderId}",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: isTablet(context) ? 18 : 12,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...o.items.map(
                  (it) => ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        it.productImage,
                        width: isTablet(context) ? 100 : 55,
                        height: isTablet(context) ? 100 : 55,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      it.productTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet(context) ? 18 : 12,
                      ),
                    ), 
                    subtitle: Text(
                      "Qty: ${it.quantity}  |  ₹${it.offerPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: isTablet(context) ? 18 : 12),
                    ),
                    trailing: Text(
                      "₹${it.totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: isTablet(context) ? 16 : 12),
                    ),
                  ),
                ),

                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹${o.overallTotal.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: isTablet(context) ? 18 : 14,
                        fontWeight: FontWeight.bold,
                      ),
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

  

  Widget _buildKpiMiniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: const Color.fromARGB(255, 227, 211, 244),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }


Widget _buildOrdersListView(
  List<OrderModel> list,
  Map<String, dynamic> totals,
) {
  if (_isLoading) return const Center(child: CircularProgressIndicator());
  if (list.isEmpty) {
    return Center(
      child: Text('No orders found', style: GoogleFonts.poppins()),
    );
  }

  return CustomScrollView(
    slivers: [
      // 🔹 KPI Row
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildKpiMiniCard(
                  title: "Total Orders",
                  value: "${totals['count']}",
                  icon: Icons.shopping_cart,
                  color: const Color.fromARGB(255, 16, 51, 79),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiMiniCard(
                  title: "Total Amount",
                  value: totals['amount'].toStringAsFixed(2),
                  icon: Icons.currency_rupee,
                  color: const Color.fromARGB(255, 101, 57, 161),
                ),
              ),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // 🔹 Orders List
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final o = list[index];
            return _orderTile(o); // your existing tile
          },
          childCount: list.length,
        ),
      ),
    ],
  );
}

  
  @override
  Widget build(BuildContext context) {
    final allList = _ordersForTab(0);
    final type1List = _ordersForTab(1);
    final type2List = _ordersForTab(2);

    final t1Totals = _computeTotals(type1List);
    final t2Totals = _computeTotals(type2List);

    // FIXED ↓
    final allTotals = {
      'count': t1Totals['count'] + t2Totals['count'],
      'amount': t1Totals['amount'] + t2Totals['amount'],
    };

    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      drawer: const SuperAdminDrawer(currentPage: "Orders Management"),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 221, 197, 251),
                Colors.white,
                Color.fromARGB(255, 221, 197, 251),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: mythemecolor),
            title: Text(
              'ORDERS MANAGEMENT!',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 22 : 12,
                fontWeight: FontWeight.w600,
                color: mythemecolor,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicatorColor: mythemecolor,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: isTablet ? 18 : 14,
                    color: mythemecolor,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: '  All DEALERS  '),
                    Tab(text: '  TYPE 1  '),
                    Tab(text: '  TYPE 2  '),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: mythemecolor,
        strokeWidth: 3,
        onRefresh: () => _fetchOrders(),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _filtersPanel(isCompact: !isTablet),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabs,
              children: [
                _buildOrdersListView(allList, allTotals),
                _buildOrdersListView(type1List, t1Totals),
                _buildOrdersListView(type2List, t2Totals),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
