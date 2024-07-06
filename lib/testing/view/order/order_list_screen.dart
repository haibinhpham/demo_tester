import 'package:demo_tester/testing/view/order/add_order_screen.dart';
import 'package:demo_tester/testing/view/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../../controller/provider/order_provider.dart';
import '../../controller/provider/user_provider.dart';
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
        debugPrint('User id null');
        setState(() {
          isLoading = false;
        });
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      var results = await connection.query(
          'select hallo.lmao.*, hallo.customer.cust_name from hallo.DEMO natural join hallo.lmao join hallo.customer on hallo.customer.cust_id = hallo.lmao.cust_id where hallo.lmao.id = ?',
          [userId]);
      debugPrint('Query executed, number of results: ${results.length}');

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
      debugPrint('Error trying fetch: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Orders',
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
        elevation: 0, // Removes the shadow under the AppBar
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return const AddOrderScreen();
          }))
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                var order = orders[index];
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      "Order Id: ${order.lmaoId}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vendor id: ${order.id}'),
                        Text('Customer id: ${order.custId}'),
                        Text('Order no: ${order.orderNumber}'),
                        Text('Customer name: ${order.custName}'),
                        Text('Order status: ${order.status}'),
                      ],
                    ),
                    trailing: GestureDetector(
                      child: IconButton(
                        onPressed: () {
                          debugPrint('Delete btn presssed');
                        },
                        icon: const Icon(Icons.delete_rounded)
                      ),
                    ),
                    onTap: () {
                      debugPrint('List tile pressed');
                      //save to provider
                      Provider.of<OrderProvider>(context, listen: false)
                          .setOrderId(order.lmaoId);
                      Navigator.push(context,
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
