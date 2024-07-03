import 'package:demo_tester/central_screen.dart';
import 'package:demo_tester/testing/view/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../../controller/order_provider.dart';
import '../../controller/user_provider.dart';
import '../../model/mysql.dart';
import '../../model/order.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  Order? order;
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    try {
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        print('User id null');
        setState(() {
          isLoading = false;
        });
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      var results = await connection.query(
          'select hallo.lmao.*, hallo.customer.cust_name from hallo.DEMO natural join hallo.lmao join hallo.customer on hallo.customer.cust_id = hallo.lmao.cust_id where hallo.lmao.id = ?',
          [userId]);
      print('Query executed, number of results: ${results.length}');

      List<Order> fetchedOrders = [];
      for (var row in results) {
        var order = Order.fromJson(row.fields);
        fetchedOrders.add(order);
      }
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      print('Error trying fetch: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return const CentralScreen();
            })); // Navigate back
          },
        ),
        title: const Text(
          'Your Orders',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2),
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
        elevation: 0, // Removes the shadow under the AppBar
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('order id: ${order.lmao_id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vendor id: ${order.id}'),
                        Text('Customer id: ${order.cust_id}'),
                        Text('Order no: ${order.order_number}'),
                        Text('Customer name: ${order.cust_name}'),
                        Text('Order status: ${order.status}'),
                      ],
                    ),
                    trailing: GestureDetector(
                      child: IconButton(
                        onPressed: () {
                          print('Delete btn presssed');
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                    onTap: () {
                      print('List tile pressed');
                      //save to provider
                      Provider.of<OrderProvider>(context, listen: false)
                          .setOrderId(order.lmao_id);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const OrderDetailScreen();
                      }));
                    },
                  ),
                );
              }),
    );
  }
}
