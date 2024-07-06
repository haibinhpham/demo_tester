import 'order_details.dart';

class OrderDisplay {
  final int lmaoId;
  final int id;
  final int custId;
  final String orderNumber;
  final String custName;
  final String status;
  final List<OrderDetails> details;

  OrderDisplay(
      {required this.lmaoId,
      required this.id,
      required this.custId,
      required this.orderNumber,
      required this.custName,
      required this.status,
      required this.details});

  factory OrderDisplay.fromJson(
      Map<String, dynamic> json, List<OrderDetails> details) {
    return OrderDisplay(
      lmaoId: json['lmao_id'],
      id: json['id'],
      custId: json['cust_id'],
      orderNumber: json['order_number'],
      custName: json['cust_name'],
      status: json['status'],
      details: details,
    );
  }
}
