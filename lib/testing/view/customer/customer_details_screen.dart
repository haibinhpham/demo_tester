import 'package:demo_tester/testing/controller/provider/customer_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/customer/customer_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../../controller/provider/order_provider.dart';
import '../../controller/provider/user_provider.dart';
import '../../model/customer.dart';
import '../order/order_details_screen.dart';

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
    //reset the list of items
    Provider.of<CustomerProvider>(context, listen: false).setCustomerOrders([]);
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
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //perform operation
      var customerResult = await connection.query(
          'select * from Production.customers where customer_id = ? and seller_id = ?',
          [custId, userId]);

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

      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('user id is null');
        return;
      }

      MySqlConnection connection = await Mysql().connection;
      //perform operations
      var orderResults = await connection.query(
          'select Production.orders.*, Production.customers.name from Production.orders natural join Production.customers where Production.orders.customer_id = ? and Production.orders.seller_id = ?',
          [custId, userId]);

      //save to list of maps
      List<Map<String, dynamic>> orders =
          orderResults.map((row) => row.fields).toList();
      print(orders.first);

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
                      Card.outlined(
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
                                  'Address: ${customerProvider.customerInfo!.address}'),
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
                        return Card.outlined(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () {
                              Provider.of<OrderProvider>(context, listen: false)
                                  .setOrderId(order['order_id']);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const OrderDetailScreen();
                              })).then((value) => fetchCustomerData());
                            },
                            title: Text('Order ID: ${order['order_id']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${order['status']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
