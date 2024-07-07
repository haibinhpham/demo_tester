import 'package:demo_tester/testing/controller/provider/customer_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/customer/customer_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../../model/customer.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool isLoading = true;
  late Customer customer;

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  Future<void> fetchCustomerData() async {
    await fetchCustomerDetails();
    await fetchCustomerOrders();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCustomerDetails() async {
    try {
      //get provider
      int? custId =
          Provider.of<CustomerProvider>(context, listen: false).custId;
      if (custId == null) {
        debugPrint('customer id is null');
        return;
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //perform operation
      var customerResult = await connection
          .query('select * from Production.customers where customer_id = ?', [custId]);

      if (customerResult.isEmpty) {
        debugPrint('Customer not found');
        return;
      }

      //save info to provider
      Customer customerJson = Customer.fromJson(customerResult.first.fields);
      Provider.of<CustomerProvider>(context, listen: false)
          .setCustomerInfo(customerJson);
      customer = customerJson;
    } catch (e) {
      debugPrint('Error fetching customer details: $e');
    }
  }

  Future<void> fetchCustomerOrders() async {
    try {
      int? custId =
          Provider.of<CustomerProvider>(context, listen: false).custId;
      if (custId == null) {
        debugPrint('customer id is null');
        return;
      }

      MySqlConnection connection = await Mysql().connection;
      //perform operations
      var orderResults = await connection.query(
          'select Production.orders.*, Production.customers.cust_name from hallo.order join hallo.customer on hallo.customer.cust_id = hallo.lmao.cust_id where hallo.lmao.cust_id = ?',
          [custId]);

      //save to list of maps
      List<Map<String, dynamic>> orders =
          orderResults.map((row) => row.fields).toList();

      Provider.of<CustomerProvider>(context, listen: false)
          .setCustomerOrders(orders);
    } catch (e) {
      debugPrint('Error fetching customer orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple,
                Colors.blue,
              ],
            ),
          ),
        ),
        elevation: 0,
        actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return UpdateCustomerScreen(customer: customer);
                })).then((_) => fetchCustomerData());
              },
              icon: const Icon(Icons.edit_rounded),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customerProvider.customerInfo == null
              ? const Center(child: Text('No customer details available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                              'Customer ID: ${customerProvider.customerInfo!.customerId}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Name: ${customerProvider.customerInfo!.name}'),
                               Text(
                                   'address: ${customerProvider.customerInfo!.address}'),
                               Text(
                                   'Phone: ${customerProvider.customerInfo!.phone}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Customer Orders:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ...customerProvider.customerOrders.map((order) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Order ID: ${order['lmao_id']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order Number: ${order['order_number']}'),
                                Text('Status: ${order['status']}'),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
