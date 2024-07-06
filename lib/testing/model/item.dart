class Item {
  final int itemId;
  final int id;
  final String itemName;
  final int quantity;

  Item({
    required this.itemId,
    required this.id,
    required this.itemName,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        itemId: json['item_id'],
        id: json['id'],
        itemName: json['item_name'],
        quantity: json['quantity']);
  }
}
