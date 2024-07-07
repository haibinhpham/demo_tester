class Customer {
  final int customerId;
  final int sellerId;
  final String name;
  final String phone;
  final String address;

  Customer({required this.customerId, required this.sellerId, required this.name, required this.phone, required this.address,});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'],
      sellerId: json['seller_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}
