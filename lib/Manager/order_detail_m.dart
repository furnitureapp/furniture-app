import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/Manager/manager_home.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/models/order_history.dart';

bool isSameDate(DateTime d1, DateTime d2) =>
    d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

List<FurnitureOrder> filterOrders(
  List<FurnitureOrder> orders,
  String filterType, {
  DateTime? from,
  DateTime? to,
}) {
  DateTime today = DateTime.now();
  DateTime startOfToday = DateTime(today.year, today.month, today.day);

  switch (filterType) {
    case 'All Dates':
      return orders;

    case 'Today':
      return orders.where((o) => isSameDate(o.orderDate, today)).toList();

    case 'Last 7 Days':
      DateTime weekAgo = startOfToday.subtract(const Duration(days: 6));
      return orders.where(
        (o) =>
            !o.orderDate.isBefore(weekAgo) && // >= weekAgo
            !o.orderDate.isAfter(startOfToday), // <= today
      ).toList();

    case 'Specific Date':
      if (from != null) {
        return orders.where((o) => isSameDate(o.orderDate, from)).toList();
      }
      return orders;

    case 'From-To':
      if (from != null && to != null) {
        DateTime fromDay = DateTime(from.year, from.month, from.day);
        DateTime toDay = DateTime(to.year, to.month, to.day);
        return orders.where(
          (o) =>
              !o.orderDate.isBefore(fromDay) && // >= from
              !o.orderDate.isAfter(toDay),      // <= to
        ).toList();
      }
      return orders;

    default:
      return orders;
  }
}


Widget buildOrderCard(FurnitureOrder order) {
  Color borderColor;
  Color statusColor;

  switch (order.status) {
    case 'Placed':
      borderColor = adminPrimaryColor;
      statusColor = Colors.orange;
      break;
    case 'Delivered':
      borderColor = adminPrimaryColor;
      statusColor = Colors.green;
      break;
    case 'Cancelled':
      borderColor = adminPrimaryColor;
      statusColor = Colors.red;
      break;
    default:
      borderColor = Colors.grey;
      statusColor = Colors.grey;
  }

  return Card(
    shape: RoundedRectangleBorder(
      side: BorderSide(color: borderColor, width: 3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: statusColor),
              const SizedBox(width: 8),
              Text(
                order.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Order Date: ${order.orderDate.month}/${order.orderDate.day}/${order.orderDate.year}',
          ),
          Text('Order Quantity: ${order.quantity}'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${order.username}'),
                Text('Phone: ${order.phone}'),
                Text('Address: ${order.address}'),
                Text('Product: ${order.productName}'),
                Text('Price: ₹${order.price}'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ₹${order.totalAmount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

class ManagerOrdersPage extends StatefulWidget {
  const ManagerOrdersPage({super.key});

  @override
  State<ManagerOrdersPage> createState() => _ManagerOrdersPageState();
}

class _ManagerOrdersPageState extends State<ManagerOrdersPage> {
  String selectedFilter = 'All Dates';
  DateTime? specificDate;
  DateTime? fromDate;
  DateTime? toDate;

  Future<DateTime?> _pickDate(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: adminPrimaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: adminPrimaryColor, // CANCEL/OK button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FurnitureOrder> filteredOrders = filterOrders(
      dummyOrders,
      selectedFilter,
      from: selectedFilter == 'Specific Date' ? specificDate : fromDate,
      to: toDate,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: managerPrimaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Orders Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      drawer: const ManagerDrawer(currentPage: "Orders Overview"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      items:
                          [
                                'All Dates',
                                'Today',
                                'Last 7 Days',
                                'Specific Date',
                                'From-To',
                              ]
                              .map(
                                (filter) => DropdownMenuItem(
                                  value: filter,
                                  child: Text(filter),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                  if (selectedFilter == 'Specific Date')
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await _pickDate(
                          context,
                          specificDate,
                        );
                        if (picked != null) {
                          setState(() => specificDate = picked);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: adminPrimaryColor,
                      ),
                      child: Text(
                        specificDate == null
                            ? 'Pick Date'
                            : '${specificDate!.month}/${specificDate!.day}/${specificDate!.year}',
                      ),
                    ),
                  if (selectedFilter == 'From-To') ...[
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await _pickDate(context, fromDate);
                        if (picked != null) setState(() => fromDate = picked);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: adminPrimaryColor,
                      ),
                      child: Text(
                        fromDate == null
                            ? 'From'
                            : '${fromDate!.month}/${fromDate!.day}/${fromDate!.year}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await _pickDate(context, toDate);
                        if (picked != null) setState(() => toDate = picked);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: adminPrimaryColor,
                      ),
                      child: Text(
                        toDate == null
                            ? 'To'
                            : '${toDate!.month}/${toDate!.day}/${toDate!.year}',
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Order list
              Expanded(
                child: filteredOrders.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) =>
                            buildOrderCard(filteredOrders[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
