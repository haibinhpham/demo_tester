class Customer {
  final int cust_id;
  final String cust_name;
  final int id;

  Customer({required this.cust_id, required this.cust_name, required this.id});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      cust_id: json['cust_id'],
      cust_name: json['cust_name'],
      id: json['id'],
    );
  }
}
