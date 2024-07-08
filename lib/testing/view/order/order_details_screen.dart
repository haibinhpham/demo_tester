import 'package:demo_tester/testing/controller/provider/order_provider.dart';
import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/model/order_details/order_details.dart';
import 'package:demo_tester/testing/model/order_details/order_display.dart';
import 'package:demo_tester/testing/view/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isLoading = true;
  OrderDisplay? orderDisplay;
  String selectedStatus = 'created';

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      int? orderId = Provider.of<OrderProvider>(context, listen: false).orderId;
      if (orderId == null) {
        debugPrint('order id is null');
        setState(() {
          isLoading = false;
        });
        return;
      }
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      //fetch order details
      var orderResults = await connection.query(
          'select Production.orders.*, Production.customers.name from Production.orders natural join Production.customers  where Production.orders.order_id = ? and Production.orders.seller_id = ?',
          [orderId, userId]);

      if (orderResults.isEmpty) {
        debugPrint('Order not found');
        setState(() {
          isLoading = false;
        });
        return;
      }

      var orderRow = orderResults.first;
      //fetch lmao details row
      var detailsResults = await connection.query(
          'select Production.orderItems.* from Production.orderItems where Production.orderItems.order_id = ?',
          [orderId]);
      //map to lists
      List<OrderDetails> orderDetails = detailsResults.map((row) {
        return OrderDetails.fromJson(row.fields);
      }).toList();

      setState(() {
        orderDisplay = OrderDisplay.fromJson(orderRow.fields, orderDetails);
        isLoading = false;
      });
    } catch (e, t) {
      debugPrint('Error fetching order details: $e $t');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus() async {
    UtilWidget.showLoadingDialog(context: context);
    try {
      int? orderId = Provider.of<OrderProvider>(context, listen: false).orderId;
      if (orderId == null) {
        debugPrint('order id is null');
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      //update operation
      await connection.query(
          'update Production.orders set Production.orders.status = ? where Production.orders.order_id = ?',
          [selectedStatus, orderId]);
      //refresh page
      Navigator.of(context).pop();
      fetchOrderDetails();
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint('Error updating order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : orderDisplay == null
              ? const Center(child: Text('No order details available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card.outlined(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Order ID: ${orderDisplay!.orderId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Customer ID: ${orderDisplay!.customerId}'),
                                Text(
                                    'Customer name: ${orderDisplay!.customerName}'),
                                Text('Status: ${orderDisplay!.status}'),
                              ],
                            ),
                          ),
                        ),
                        _gap(),
                        const Text('Order Items:'),
                        ...orderDisplay!.details.map((detail) {
                          return Card.outlined(
                            child: ListTile(
                              title: Text('Item id: ${detail.itemId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Item Name: ${detail.itemName}'),
                                  Text('Quantity: ${detail.amount}'),
                                ],
                              ),
                            ),
                          );
                        }),
                        _gap(),
                        const Text('Update Order Status:'),
                        DropdownButton<String>(
                          value: selectedStatus,
                          items: <String>[
                            'created',
                            'packaged',
                            'delivering',
                            'delivered',
                            'cancelled',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(
                              () {
                                selectedStatus = newValue!;
                              },
                            );
                          },
                        ),
                        _gap(),
                        ElevatedButton(
                            onPressed: updateOrderStatus,
                            child: const Text('Update Status')),
                      ]),
                ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
