import 'order_details.dart';

class OrderDisplay {
  final int lmao_id;
  final int id;
  final int cust_id;
  final String order_number;
  final String cust_name;
  final String status;
  final List<OrderDetails> details;

  OrderDisplay(
      {required this.lmao_id,
      required this.id,
      required this.cust_id,
      required this.order_number,
      required this.cust_name,
      required this.status,
      required this.details});

  factory OrderDisplay.fromJson(
      Map<String, dynamic> json, List<OrderDetails> details) {
    return OrderDisplay(
      lmao_id: json['lmao_id'],
      id: json['id'],
      cust_id: json['cust_id'],
      order_number: json['order_number'],
      cust_name: json['cust_name'],
      status: json['status'],
      details: details,
    );
  }
}
