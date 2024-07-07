class Item {
  final int itemId;
  final int sellerId;
  final String itemName;
  final String itemDescription;
  final String imageUrl;
  final int price;
  final int quantity;

  Item({
    required this.itemId,
    required this.sellerId,
    required this.itemName,
    required this.itemDescription,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        itemId: json['item_id'],
        sellerId: json['seller_id'],
        itemName: json['item_name'],
        itemDescription: json['item_desc'],
        imageUrl: json['image_url'] ?? "",
        price: json['price'],
        quantity: json['amount']);
  }
}
