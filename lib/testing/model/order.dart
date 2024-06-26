import 'package:demo_tester/testing/model/user.dart';

class Order {
  final int lmao_id;
  final int id;
  final String order_number;
  final String fname;

  Order(
      {required this.lmao_id,
      required this.id,
      required this.order_number,
      required this.fname});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      lmao_id: json['lmao_id'],
      id: json['id'],
      order_number: json['order_number'],
      fname: json['fname'],
    );
  }
}
