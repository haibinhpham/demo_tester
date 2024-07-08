import 'package:demo_tester/testing/view/order/add_order_screen.dart';
import 'package:demo_tester/testing/view/order/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final f = NumberFormat("###,###.###", "id_ID");

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  void showConfirmationDialog(BuildContext context, int orderId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Cancellation'),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await cancelOrder(orderId);
                  },
                  child: const Text('Yes'))
            ],
          );
        });
  }

  void showResultDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Result'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  Future<void> fetchAllOrders() async {
    setState(() {
      isLoading = true;
    });
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
          'select Production.orders.*, Production.customers.name from Production.orders join Production.customers on Production.customers.customer_id = Production.orders.customer_id where Production.orders.seller_id = ?',
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

  Future<void> cancelOrder(int orderId) async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;

      //get conn
      MySqlConnection connection = await Mysql().connection;

      //start transaction
      await connection.transaction((txn) async {
        var statusResult = await txn.query(
            'select Production.orders.status from Production.orders where order_id = ? and seller_id = ?',
            [orderId, userId]);

        //if status is equal to created
        if (statusResult.isNotEmpty) {
          var status = statusResult.first['status'];
          //start changing the query
          if (status == 'created') {
            //update order status to cancelled
            await txn.query(
                'update Production.orders set status = ? where order_id = ? and seller_id = ?',
                ['cancelled', orderId, userId]);

            //return items to inventory
            var inventoryResults = await txn.query('');
            showResultDialog(context, 'Cancelled successfully');
          } else {
            debugPrint('Order cannot be cancelled bc status is not created');
            showResultDialog(
                context, 'Cannot cancel because of status is not created');
            throw Exception(
                'Order cannot be cancelled bc status is not created');
          }
        }
      });
      //refresh the list
      fetchAllOrders();
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      showResultDialog(context, 'Error: $e');
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
        backgroundColor: Colors.lightBlue,
        onPressed: () => {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return const AddOrderScreen();
          })).then((value) => fetchAllOrders())
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
                return Card.outlined(
                  child: ListTile(
                    title: Text(
                      "Order Id: ${order.orderId}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer name: ${order.customerName}',
                            style: const TextStyle(color: Colors.black54)),
                        Text('Total: ${f.format(order.totalPrice)}',
                            style: const TextStyle(color: Colors.black54)),
                        Text('Order status: ${order.status}',
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                    trailing: GestureDetector(
                      child: IconButton(
                          onPressed: () async {
                            showConfirmationDialog(context, order.orderId);
                            debugPrint('Cancel btn pressed');
                          },
                          icon: const Icon(Icons.cancel_rounded)),
                    ),
                    onTap: () {
                      debugPrint('List tile pressed');
                      //save to provider
                      Provider.of<OrderProvider>(context, listen: false)
                          .setOrderId(order.orderId);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const OrderDetailScreen();
                      })).then((value) => fetchAllOrders());
                    },
                  ),
                );
              }),
    );
  }
}
