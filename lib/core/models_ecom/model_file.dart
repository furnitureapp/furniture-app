class Delivery {
  final String id;
  final String username;
  final String phoneNo;
  final String houseNo;
  final String streetName;
  final String city;
  final String state;
  final String pinCode;

  Delivery({
    required this.id,
    required this.username,
    required this.phoneNo,
    required this.houseNo,
    required this.streetName,
    required this.city,
    required this.state,
    required this.pinCode,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['_id'],
      username: json['username'],
      phoneNo: json['phoneNo'],
      houseNo: json['houseNo'],
      streetName: json['streetName'],
      city: json['city'],
      state: json['state'],
      pinCode: json['pinCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phoneNo': phoneNo,
      'houseNo': houseNo,
      'streetName': streetName,
      'city': city,
      'state': state,
      'pinCode': pinCode,
    };
  }
}

class RelatedProducts {
  final Product product;
  final List<Product> related;

  RelatedProducts({required this.product, required this.related});

  factory RelatedProducts.fromJson(Map<String, dynamic> json) {
    return RelatedProducts(
      product: Product.fromJson(json['product']),
      related: (json['related'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

// class Product {
//   final String id;
//   final String title;
//   final double price;
//   final double offerPrice;
//   final String description;
//   final List<String> images;
//   final int stock;
//   final double gstPercentage;
//   final String unit;

//   Product({
//     required this.id,
//     required this.title,
//     required this.price,
//     required this.description,
//     required this.images,
//     required this.offerPrice,
//     required this.stock,
//     required this.gstPercentage,
//     required this.unit,
//   });
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['_id'] ?? '',
//       title: json['title'],
//       price: json['price'].toDouble(),
//       offerPrice: json['offerPrice'].toDouble(),
//       description: json['description'] ?? '',
//       images: List<String>.from(json['images'] ?? []),
//       stock: json['stock'] != null ? json['stock'] as int : 0,
//       gstPercentage: (json['gstPercentage'] != null)
//           ? double.tryParse(json['gstPercentage'].toString()) ?? 0.0
//           : 0.0,
//       unit: json['unit'] ?? '',
//     );
//   }
// }

class Product {
  final String id;
  final String title;
  final double price;
  final double offerPrice;
  final String description;
  final List<String> images;
  final int stock;
  final double gstPercentage;
  final String measurement;
  final String size;
  final String weight;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.offerPrice,
    required this.description,
    required this.images,
    required this.stock,
    required this.gstPercentage,
    required this.measurement,
    required this.size,
    required this.weight,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] ?? 0,
      gstPercentage: (json['gstPercentage'] ?? 0).toDouble(),
      measurement: json['measurement'] ?? '',
      size: json['size'] ?? '',
      weight: json['weight'] ?? '',
    );
  }
}

class Categorys {
  final String id;
  final String title;
  final List<String> images;

  Categorys({required this.id, required this.title, required this.images});

  factory Categorys.fromJson(Map<String, dynamic> json) {
    return Categorys(
      id: json['_id'],
      title: json['title'],
      images: List<String>.from(json['images']),
    );
  }
}

// class Offer {
//   final String id;
//   final String productId;
//   final String title;
//   final String description;
//   final double actualPrice;
//   final double offerPrice;
//   final List<String> images;
//   final int stock;
//   final double gstPercentage;
//   final String unit;

//   Offer({
//     required this.id,
//     required this.productId,
//     required this.title,
//     required this.description,
//     required this.actualPrice,
//     required this.offerPrice,
//     required this.images,
//     required this.stock,
//     required this.gstPercentage,
//     required this.unit,
//   });

//   factory Offer.fromJson(Map<String, dynamic> json) {
//     return Offer(
//       id: json['_id'],
//       productId: json['product'],
//       title: json['title'],
//       description: json['description'],
//       actualPrice: (json['actualPrice'] as num).toDouble(),
//       offerPrice: (json['offerPrice'] as num).toDouble(),
//       images: List<String>.from(json['images'] ?? []),
//       stock: json['stock'] ?? 1,
//       gstPercentage: (json['gstPercentage'] ?? 0).toDouble(),
//       unit: json['unit'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'productId': productId,
//       'title': title,
//       'actualPrice': actualPrice,
//       'offerPrice': offerPrice,
//       'description': description,
//       'images': images,
//       'stock': stock,
//       'gstPercentage': gstPercentage,
//       'unit': unit,
//     };
//   }
// }

class Offer {
  final String id;
  final Product product;
  final String title;
  final String description;
  final double actualPrice;
  final double offerPrice;
  final List<String> images;
  final int stock;
  final double gstPercentage;
  final String measurement;
  final String size;
  final String weight;

  Offer({
    required this.id,
    required this.product,
    required this.title,
    required this.description,
    required this.actualPrice,
    required this.offerPrice,
    required this.images,
    required this.stock,
    required this.gstPercentage,
    required this.measurement,
    required this.size,
    required this.weight,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      actualPrice: (json['actualPrice'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] ?? 0,
      gstPercentage: (json['gstPercentage'] ?? 0).toDouble(),
      measurement: json['measurement'] ?? '',
      size: json['size'] ?? '',
      weight: json['weight'] ?? '',
    );
  }
}

class SubCategory {
  final String id;
  final String title;
  final String categoryId;
  final List<String> images;

  SubCategory({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.images,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'],
      title: json['title'],
      categoryId: json['categoryId'],
      images: List<String>.from(json['images']),
    );
  }
}

class CartItem {
  final String productId;
  final String productTitle;
  final String productImages;
  int quantity;
  final int stock;
  final double originalPrice;
  final double offerPrice;
  final double gstPercentage;
  final double gstAmount;
  final double totalWithGST;
  final double savings;
  final bool isUpdating;

  CartItem({
    required this.productId,
    required this.productTitle,
    required this.productImages,
    required this.quantity,
    required this.stock,
    required this.originalPrice,
    required this.offerPrice,
    required this.gstPercentage,
    required this.gstAmount,
    required this.totalWithGST,
    required this.savings,
    this.isUpdating = false,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImages: json['productImages'] ?? '',
      quantity: json['quantity'] ?? 0,
      stock: json['stock'] ?? 0,
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      gstPercentage: (json['gstPercentage'] is num)
          ? (json['gstPercentage'] as num).toDouble()
          : 0.0,
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      totalWithGST: (json['totalWithGST'] ?? 0).toDouble(),
      savings: (json['savings'] ?? 0).toDouble(),
    );
  }

  CartItem copyWith({
    String? productId,
    String? productTitle,
    String? productImages,
    int? quantity,
    int? stock,
    double? originalPrice,
    double? offerPrice,
    double? gstPercentage,
    double? gstAmount,
    double? totalWithGST,
    double? savings,
    bool? isUpdating,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImages: productImages ?? this.productImages,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      originalPrice: originalPrice ?? this.originalPrice,
      offerPrice: offerPrice ?? this.offerPrice,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      gstAmount: gstAmount ?? this.gstAmount,
      totalWithGST: totalWithGST ?? this.totalWithGST,
      savings: savings ?? this.savings,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class BannerModel {
  final String image;
  final String page;

  BannerModel({required this.image, required this.page});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(image: json['image'] ?? '', page: json['page'] ?? '');
  }
}

class Order {
  final String orderId;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double overallTotal;
  final String houseNo;
  final String streetName;
  final String city;
  final String state;
  final String pinCode;
  final String phoneNo;
  final String dealername;
  final String paymentMethod;
  final String status;
  final String deliveryId;
  final String? offerId;
  final double gstAmount;
  final List<OrderStatusEntry> statusHistory;

  Order({
    // required this.productId,
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.overallTotal,
    required this.phoneNo,
    required this.houseNo,
    required this.state,
    required this.streetName,
    required this.city,
    required this.pinCode,
    required this.paymentMethod,
    required this.status,
    required this.dealername,
    required this.deliveryId,
    this.offerId,
    required this.gstAmount,
    required this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
      overallTotal: (json['overallTotal'] as num).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      houseNo: json['houseNo'] ?? '',
      streetName: json['streetName'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pinCode'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      dealername: json['dealername'] ?? '',
      deliveryId: json['deliveryId'] ?? '',
      offerId: json['offerId'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .map((entry) => OrderStatusEntry.fromJson(entry))
          .toList(),
    );
  }
}

class OrderItem {
  final String productId;
  final String productTitle;
  final String productImage;
  final double offerPrice;
  final int quantity;
  final String deliveryId;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.offerPrice,
    required this.quantity,
    required this.deliveryId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      deliveryId: json['deliveryId'] ?? '',
    );
  }
}

class OrderStatusEntry {
  final String status;
  final DateTime timestamp;

  OrderStatusEntry({required this.status, required this.timestamp});

  factory OrderStatusEntry.fromJson(Map<String, dynamic> json) {
    return OrderStatusEntry(
      status: json['status'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Notifications {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String? page;
  final String? productId;
  final String? orderId;
  final String? deliveryId;

  Notifications({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.page,
    this.productId,
    this.orderId,
    this.deliveryId,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      id: json['_id'], // Parse the _id from MongoDB
      title: json['title'],
      body: json['body'],
      date: DateTime.parse(json['date'] ?? json['createdAt']),
      // date: DateTime.parse(json['date']),
      page: json['page'],
      productId: json['productId'],
      orderId: json['orderId'],
      deliveryId: json['deliveryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'page': page,
      'productId': productId,
      'orderId': orderId,
      'deliveryId': deliveryId,
    };
  }
}

class Marquees {
  final String id;
  final String content;
  final bool isActive;

  Marquees({required this.id, required this.content, required this.isActive});

  factory Marquees.fromJson(Map<String, dynamic> json) {
    return Marquees(
      id: json['_id'],
      content: json['content'],
      isActive: json['isActive'],
    );
  }
}

class ShopSettings {
  final String websiteUrl;
  final String profileImage;
  final String mapLink;
  final String message;
  final String name;
  final String phoneNumber;
  final String whatsappNumber;
  final String poweredByImage;
  final String poweredByName;
  final String link;

  ShopSettings({
    required this.websiteUrl,
    required this.profileImage,
    required this.mapLink,
    required this.message,
    required this.name,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.poweredByImage,
    required this.poweredByName,
    required this.link,
  });

  factory ShopSettings.fromJson(Map<String, dynamic> json) {
    return ShopSettings(
      websiteUrl: json['websiteUrl'] ?? '',
      profileImage: json['profileImage'] ?? '',
      mapLink: json['mapLink'] ?? '',
      message: json['message'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
      poweredByImage: json['poweredBy']?['image'] ?? '',
      poweredByName: json['poweredBy']?['name'] ?? '',
      link: json['poweredBy']?['link'] ?? '',
    );
  }
}
