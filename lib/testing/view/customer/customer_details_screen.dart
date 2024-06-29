import 'package:demo_tester/testing/view/customer/customer_list_screen.dart';
import 'package:flutter/material.dart';

import '../../model/customer.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Customer customer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
    fetchCustomerDetails();
  }

  Future<void> fetchCustomerDetails() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return const CustomerListScreen();
            }));
          },
        ),
      ),
    );
  }
}
