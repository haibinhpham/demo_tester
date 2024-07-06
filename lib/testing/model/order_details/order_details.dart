class OrderDetails {
  final int id;
  final int lmaoId;
  final int itemId;
  final int lmaoQuantity;
  final String itemName;

  OrderDetails({
    required this.id,
    required this.lmaoId,
    required this.itemId,
    required this.lmaoQuantity,
    required this.itemName,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      lmaoId: json['lmao_id'],
      itemId: json['item_id'],
      lmaoQuantity: json['lmao_quantity'],
      itemName: json['item_name'],
    );
  }
}
