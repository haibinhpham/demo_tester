class Customer {
  final int custId;
  final String custName;
  final int id;

  Customer({required this.custId, required this.custName, required this.id});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      custId: json['cust_id'],
      custName: json['cust_name'],
      id: json['id'],
    );
  }
}
