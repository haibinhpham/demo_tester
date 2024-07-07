class Order {
  final int orderId;
  final int sellerId;
  final int customerId;
  final String customerName;
  final String orderDesc;
  final String status;
  final int totalPrice;

  Order({
    required this.orderId,
    required this.sellerId,
    required this.customerId,
    required this.customerName,
    required this.orderDesc,
    required this.status,
    required this.totalPrice,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      sellerId: json['seller_id'],
      customerId: json['customer_id'],
      customerName: json['name'],
      orderDesc: json['order_desc'],
      status: json['status'],
      totalPrice: json['total_price'],
    );
  }
}
