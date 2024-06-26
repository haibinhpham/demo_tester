class User {
  final int id;
  final String fname;
  final String lname;
  final String address;

  User({
    required this.id,
    required this.fname,
    required this.lname,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fname: json['fname'],
      lname: json['lname'],
      address: json['address'],
    );
  }
}
