class OrderDetails {
  final int id;
  final int lmao_id;
  final int item_id;
  final int lmao_quantity;
  final String item_name;

  OrderDetails({
    required this.id,
    required this.lmao_id,
    required this.item_id,
    required this.lmao_quantity,
    required this.item_name,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      lmao_id: json['lmao_id'],
      item_id: json['item_id'],
      lmao_quantity: json['lmao_quantity'],
      item_name: json['item_name'],
    );
  }
}
