import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/model/model_file.dart';
import 'package:furniture_ecom_app/core/services/orders_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/new_appbar.dart';
import 'package:furniture_ecom_app/my_ecom/orders/order_detail.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  Future<List<Order>>? _orderHistory;
  bool _isLoggedIn = false;
  bool _isLoading = true;

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
      _isLoading = false;
    });

    if (_isLoggedIn) {
      _fetchOrders();
    }
  }

  void _fetchOrders() {
    setState(() {
      _orderHistory = OrderService.fetchOrderHistory();
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    if (_isLoading) {
      return const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: NewAppbar(title: 'My Orders'),
        ),
        body: Center(child: AnimationPage1()),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: NewAppbar(title: 'My Orders'),
        ),
        body: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  isTablet
                      ? 'assets/images/theme.png'
                      : 'assets/images/theme.png',
                  fit: BoxFit.cover,
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
                        color: mythemecolor1,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Lottie.asset(
                            'assets/json/em.json',
                            width: 130,
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                          if (!isTablet) const SizedBox(height: 5),
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
                            "Stay Logged to See Your Orders!",
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
                              await prefs.setString(
                                'redirectRoute',
                                '/myorders',
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mythemecolor,
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 40 : 30,
                                vertical: isTablet ? 14 : 12,
                              ),
                              textStyle: TextStyle(
                                fontSize: isTablet ? 18 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                              foregroundColor: Colors.white,
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
        ),
      );
    }
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: NewAppbar(title: 'My Orders'),
      ),
      body: RefreshIndicator(
        color: mythemecolor,
        backgroundColor: const Color.fromARGB(255, 245, 240, 242),
        displacement: 40,
        strokeWidth: 2.5,
        onRefresh: () async {
          _fetchOrders();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: FutureBuilder<List<Order>>(
          future: _orderHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AnimationPage1());
            } else if (snapshot.hasError) {
              return SizedBox.expand(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        isTablet
                            ? 'assets/images/theme.png'
                            : 'assets/images/theme.png',
                        fit: BoxFit.cover,
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
                              color: mythemecolor1.withOpacity(0.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Lottie.asset(
                                  'assets/json/em.json',
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.contain,
                                ),
                                if (!isTablet) const SizedBox(height: 5),
                                Text(
                                  "Issues in fetching orders!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isTablet ? 24 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Retry or place your Orders!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 25),
                                ElevatedButton(
                                  onPressed: _fetchOrders,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mythemecolor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 40 : 30,
                                      vertical: isTablet ? 14 : 12,
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: isTablet ? 18 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Retry!"),
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
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return noitemsOrdered();
            } else if (snapshot.hasData) {
              return buildOrderListView(snapshot.data!);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget buildOrderListView(List<Order> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return buildOrderItemTablet(orders[index]);
            },
          );
        } else {
          // Mobile View (List)
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return buildOrderItem(orders[index]);
            },
          );
        }
      },
    );
  }

  Widget buildOrderItem(Order order) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: order.orderId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  order.items.isNotEmpty
                      ? order.items[0].productImage
                      : 'https://via.placeholder.com/80',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${order.orderId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: mythemecolor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${order.status} on ${formatDate(order.orderDate)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      order.items.isNotEmpty
                          ? order.items[0].productTitle
                          : 'No items in order',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 30, color: mythemecolor),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderItemTablet(Order order) {
    return Flexible(
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailsScreen(orderId: order.orderId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    order.items.isNotEmpty
                        ? order.items[0].productImage
                        : 'https://via.placeholder.com/120',
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Order ID: ${order.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color.fromARGB(255, 93, 95, 93),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  order.items.isNotEmpty
                      ? order.items[0].productTitle
                      : 'No items in order',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 43, 42, 42),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Status',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color.fromARGB(255, 93, 95, 93),
                      ),
                    ),
                    Text(
                      '${order.status} ➡️',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 9, 112, 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Placed on ${formatDate(order.orderDate)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 93, 95, 93),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget noitemsOrdered() {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isTablet ? 'assets/images/theme.png' : 'assets/images/theme.png',
              fit: BoxFit.cover,
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
                    color: mythemecolor1,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Lottie.asset(
                        'assets/json/em.json',
                        width: isTablet ? 150 : 130,
                        height: isTablet ? 150 : 130,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No orders found!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Please do Shop & place your orders!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/myhome');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTablet
                              ? Colors.white
                              : mythemecolor,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 40 : 30,
                            vertical: isTablet ? 14 : 12,
                          ),
                          textStyle: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                          foregroundColor: isTablet
                              ? mythemecolor
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
      ),
    );
  }
}



    // if (!_isLoggedIn) {
    //   return Scaffold(
    //     appBar: const PreferredSize(
    //       preferredSize: Size.fromHeight(60),
    //       child: MyAppbar(title: 'Your Orders'),
    //     ),
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const Text(
    //             'Hey!',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(fontSize: 20),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           const Text(
    //             'Stay Logged to See Your Orders!',
    //             textAlign: TextAlign.center,
    //             style: TextStyle(fontSize: 20),
    //           ),
    //           Lottie.asset(
    //             'assets/json/emptyorder.json',
    //             width: 200,
    //             height: 200,
    //             fit: BoxFit.contain,
    //           ),
    //           ElevatedButton(

    //             onPressed: () async {
    //               SharedPreferences prefs =
    //                   await SharedPreferences.getInstance();
    //               await prefs.setString('redirectRoute', '/myorders');

    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) => const LoginScreen(),
    //                 ),
    //               );
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: const Color.fromARGB(255, 236, 208, 125),
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    //               shape: const RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.zero,
    //               ),
    //             ),
    //             child: const Text(
    //               "Login Now",
    //               style: TextStyle(
    //                 color: Color.fromARGB(255, 2, 57, 4),
    //                 fontSize: 14,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
