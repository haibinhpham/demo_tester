class Item {
  final int item_id;
  final int id;
  final String item_name;
  final int quantity;

  Item({
    required this.item_id,
    required this.id,
    required this.item_name,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        item_id: json['item_id'],
        id: json['id'],
        item_name: json['item_name'],
        quantity: json['quantity']);
  }
}
