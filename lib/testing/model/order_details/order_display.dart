import 'order_details.dart';

class OrderDisplay {
  final int orderId;
  final int sellerId;
  final int customerId;
  final String customerName;
  final String orderDesc;
  final String status;
  final int totalPrice;
  final List<OrderDetails> details;

  OrderDisplay(
    {
    required this.orderId,
    required this.sellerId,
    required this.customerId,
    required this.customerName,
    required this.orderDesc,
    required this.status,
    required this.totalPrice,
      required this.details});

  factory OrderDisplay.fromJson(
      Map<String, dynamic> json, List<OrderDetails> details) {
    return OrderDisplay(
      orderId: json['order_id'],
      sellerId: json['seller_id'],
      customerId: json['customer_id'],
      customerName: json['name'],
      orderDesc: json['order_desc'],
      status: json['status'],
      totalPrice: json['total_price'],
      details: details,
    );
  }
}
