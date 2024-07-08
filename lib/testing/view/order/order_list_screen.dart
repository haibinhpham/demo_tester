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
import '../widgets/loading_indicator.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  Order? order;
  List<Order> orders = [];
  List<Order> filteredOrder = [];
  bool isLoading = true;
  bool isSearching = false;
  final f = NumberFormat("###,###.###", "id_ID");

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
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

  // Future<String> deleteOrder(int orderId) async {
  //   UtilWidget.showLoadingDialog(context: context);
  //   try {
  //     //get provider
  //     int? userId = Provider.of<UserProvider>(context, listen: false).userId;
  //     if (userId == null) {
  //       return 'User ID is null';
  //     }
  //     //get connection
  //     MySqlConnection connection = await Mysql().connection;
  //     //delete operation
  //
  //     await connection.query(
  //         'delete from Production.orders where Production.orders.order_id = ?',
  //         [orderId]);
  //     //reload after query
  //     fetchAllOrders();
  //     Navigator.of(context).pop();
  //     return 'Delete Successful';
  //   } catch (e) {
  //     debugPrint('Error deleting order: $e');
  //     Navigator.of(context).pop();
  //     return 'Delete Error';
  //   }
  // }
  //
  // void _showConfirmationDialog(int orderId) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Confirm Deletion'),
  //         content: const Text('Are you sure?'),
  //         actions: [
  //           TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('Cancel')),
  //           TextButton(
  //               onPressed: () async {
  //                 Navigator.of(context).pop();
  //                 String result = await deleteOrder(orderId);
  //                 _showResultDialog(result);
  //               },
  //               child: const Text('Confirm')),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void _showResultDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Result'),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('OK')),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: GestureDetector(
                      child: IconButton(
                          onPressed: () {
                            debugPrint('Delete btn presssed');
                          },
                          icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.grey)),
                    //   //onTap: () {
                    //     //_showConfirmationDialog(order.orderId);
                    //   //},
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
