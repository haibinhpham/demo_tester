class Order {
  final int lmaoId;
  final int id;
  final int custId;
  final String orderNumber;
  final String custName;
  final String status;

  Order({
    required this.lmaoId,
    required this.id,
    required this.custId,
    required this.orderNumber,
    required this.custName,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      lmaoId: json['lmao_id'],
      id: json['id'],
      custId: json['cust_id'],
      orderNumber: json['order_number'],
      custName: json['cust_name'],
      status: json['status'],
    );
  }
}
