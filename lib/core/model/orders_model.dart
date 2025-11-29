class OrderResponse {
  final int totalOrders;
  final int overallDealerOrderAmount;
  final int page;
  final int limit;
  final List<OrderModel> orders;

  OrderResponse({
    required this.totalOrders,
    required this.overallDealerOrderAmount,
    required this.page,
    required this.limit,
    required this.orders,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      totalOrders: json['totalOrders'] ?? 0,
      overallDealerOrderAmount: json['overallDealerOrderAmount'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      orders: (json['orders'] as List? ?? [])
          .map((e) => OrderModel.fromJson(e))
          .toList(),
    );
  }
}

class OrderModel {
  final String orderId;
  final DealerModel dealer;
  final List<OrderItem> items;
  final int totalProducts;
  final DateTime orderDate;
  final int overallTotal;
  final String paymentMethod;
  final String status;

  OrderModel({
    required this.orderId,
    required this.dealer,
    required this.items,
    required this.totalProducts,
    required this.orderDate,
    required this.overallTotal,
    required this.paymentMethod,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      dealer: DealerModel.fromJson(json['dealer']),
      items: (json['items'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      totalProducts: json['totalProducts'] ?? 0,
      orderDate: DateTime.parse(json['orderDate']),
      overallTotal: json['overallTotal'] ?? 0,
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class DealerModel {
  final String companyName;
  final String email;
  final String phoneNumber;
  final String address;
  final int dealerType;

  DealerModel({
    required this.companyName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.dealerType,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      companyName: json['companyName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      dealerType: json['dealerType'] ?? 0,
    );
  }
}

class OrderItem {
  final String productTitle;
  final String productImage;
  final int offerPrice;
  final int originalPrice;
  final int quantity;
  final int totalPrice;
  final int typeOfProduct;
  final String categoryName;
  final String subCategoryName;
  final String deliveryId;
  final String address;
  final String phoneNo;
  final String dealerName;

  OrderItem({
    required this.productTitle,
    required this.productImage,
    required this.offerPrice,
    required this.originalPrice,
    required this.quantity,
    required this.totalPrice,
    required this.typeOfProduct,
    required this.categoryName,
    required this.subCategoryName,
    required this.deliveryId,
    required this.address,
    required this.phoneNo,
    required this.dealerName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      offerPrice: json['offerPrice'] ?? 0,
      originalPrice: json['originalPrice'] ?? 0,
      quantity: json['quantity'] ?? 0,
      totalPrice: json['totalPrice'] ?? 0,
      typeOfProduct: json['typeOfProduct'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      subCategoryName: json['subCategoryName'] ?? '',
      deliveryId: json['deliveryId'] ?? '',
      address: json['address'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      dealerName: json['dealername'] ?? '',
    );
  }
}
