// orders_page_manager.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/api_management_service/admin_api_service.dart';
import '../core/models_ecom/orders_model.dart';

class OrdersPageManager extends StatefulWidget {
  const OrdersPageManager({super.key});
  @override
  State<OrdersPageManager> createState() => _OrdersPageManagerState();
}

class _OrdersPageManagerState extends State<OrdersPageManager>
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

  double computeTodaysAmount(List<OrderModel> orders) {
    final today = DateTime.now();
    return orders
        .where(
          (o) =>
              o.orderDate.year == today.year &&
              o.orderDate.month == today.month &&
              o.orderDate.day == today.day,
        )
        .fold<double>(0.0, (sum, o) => sum + o.overallTotal);
  }

  // static Future<double> fetchTodaysOrderAmount() async {
  //   try {
  //     final orderResponse = await AdminApiService.fetchOrders(
  //       filterType: '1day',
  //     );
  //     // Sum up overallTotal from all fetched orders
  //     final totalAmount = orderResponse.orders.fold<double>(
  //       0.0,
  //       (sum, order) => sum + (order.overallTotal),
  //     );

  //     return totalAmount;
  //   } catch (e) {
  //     print("Error fetching today's total amount: $e");
  //     return 0.0;
  //   }
  // }

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

                    value: computeTodaysAmount(list).toStringAsFixed(2),
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
          delegate: SliverChildBuilderDelegate((context, index) {
            final o = list[index];
            return _orderTile(o); // your existing tile
          }, childCount: list.length),
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
      drawer: const ManagerDrawer(currentPage: "Orders Management"),
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

                  labelColor: mythemecolor, // ✔ selected text color
                  unselectedLabelColor:
                      Colors.grey[600], // ✔ unselected text color

                  labelStyle: GoogleFonts.poppins(
                    fontSize: isTablet ? 16 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: isTablet ? 16 : 10,
                    fontWeight: FontWeight.w500,
                  ),

                  tabs: [
                    Tab(child: Text('ALL DEALERS')),
                    Tab(child: Text('TYPE 1')),
                    Tab(child: Text('TYPE 2')),
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
