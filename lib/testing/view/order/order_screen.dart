import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../../controller/user_provider.dart';
import '../../model/mysql.dart';
import '../../model/order.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
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
        title: const Text('Your Orders'),
        automaticallyImplyLeading: false,
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
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
