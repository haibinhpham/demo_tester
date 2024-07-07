class OrderDetails {
  final int orderId;
  final int itemId;
  final String itemName;
  final String itemDesc;
  final int itemPrice;
  final int sellerId;
  final int amount;

  OrderDetails({
    required this.orderId,
    required this.itemId,
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.sellerId,
    required this.amount,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      orderId: json['order_id'],
      itemId: json['item_id'],
      itemName: json['item_name'],
      itemDesc: json['item_desc'],
      itemPrice: json['item_price'],
      sellerId: json['seller_id'],
      amount: json['amount'],
    );
  }
}
