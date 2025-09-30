class FurnitureOrder {
  final int orderId;
  final String status;
  final DateTime orderDate;
  final String username;
  final String phone;
  final String address;
  final String productName;
  final int quantity;
  final double price;

  FurnitureOrder({
    required this.orderId,
    required this.status,
    required this.orderDate,
    required this.username,
    required this.phone,
    required this.address,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get totalAmount => price * quantity;
}
// Dummy data (unit prices instead of totals)
List<FurnitureOrder> dummyOrders = [
  FurnitureOrder(
    orderId: 1001,
    status: 'Placed',
    orderDate: DateTime(2025, 9, 17),
    username: 'Hari',
    phone: '9360045006',
    address: '12, Nehru Nagar, Madurai, Tamil Nadu - 625006',
    productName: 'Wooden Chair',
    quantity: 1,
    price: 4850, // unit price
  ),
   FurnitureOrder(
    orderId: 1011,
    status: 'Placed',
    orderDate: DateTime(2025, 8, 12),
    username: 'eswari',
    phone: '9360045900',
    address: '34, aa nagar, Madurai, Tamil Nadu - 625010',
    productName: 'study Table',
    quantity: 2,
    price: 9500, 
  ),
  FurnitureOrder(
    orderId: 1002,
    status: 'Placed',
    orderDate: DateTime(2025, 9, 18),
    username: 'Muthu',
    phone: '9360045005',
    address: '12, Nehjut, Maduari, Tamil Nadu - 625006',
    productName: 'Dining Table',
    quantity: 1,
    price: 24150, // unit price
  ),
  FurnitureOrder(
    orderId: 1003,
    status: 'Cancelled',
    orderDate: DateTime(2025, 9, 18),
    username: 'Muthu',
    phone: '9360045005',
    address: '12, Nehjut, Maduari, Tamil Nadu - 625006',
    productName: 'Sofa Set',
    quantity: 1,
    price: 17000, // unit price
  ),
  FurnitureOrder(
    orderId: 1004,
    status: 'Placed',
    orderDate: DateTime(2025, 9, 20),
    username: 'Anita',
    phone: '9360045010',
    address: '34, Anna Nagar, Madurai, Tamil Nadu - 625010',
    productName: 'Coffee Table',
    quantity: 2,
    price: 5900, // unit price
  ),
  FurnitureOrder(
    orderId: 1007,
    status: 'Delivered',
    orderDate: DateTime(2025, 9, 22),
    username: 'Vishwa',
    phone: '9360845010',
    address: '34, Anna Nagar, Madurai, Tamil Nadu - 625010',
    productName: 'Coffee Table',
    quantity: 2,
    price: 8900, // unit price
  ),
  FurnitureOrder(
    orderId: 1008,
    status: 'Placed',
    orderDate: DateTime(2025, 9, 24),
    username: 'Karthik',
    phone: '9360045900',
    address: '34, Tvs Nagar, Madurai, Tamil Nadu - 625010',
    productName: 'Coffee Table',
    quantity: 2,
    price: 9500, // unit price
  ),
  FurnitureOrder(
    orderId: 1005,
    status: 'Placed',
    orderDate: DateTime(2025, 9, 21),
    username: 'Ravi',
    phone: '9360045020',
    address: '56, Gandhi Street, Madurai, Tamil Nadu - 625012',
    productName: 'Bookshelf',
    quantity: 1,
    price: 12000, // unit price
  ),
];
