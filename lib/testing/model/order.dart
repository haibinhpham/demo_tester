import 'package:demo_tester/testing/model/user.dart';

class Order {
  final int lmao_id;
  final int id;
  final int cust_id;
  final String order_number;
  final String cust_name;

  Order(
      {required this.lmao_id,
      required this.id,
      required this.cust_id,
      required this.order_number,
      required this.cust_name});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      lmao_id: json['lmao_id'],
      id: json['id'],
      cust_id: json['cust_id'],
      order_number: json['order_number'],
      cust_name: json['cust_name'],
    );
  }
}
