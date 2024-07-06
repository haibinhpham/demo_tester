import 'package:demo_tester/testing/controller/provider/order_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/model/order_details/order_details.dart';
import 'package:demo_tester/testing/model/order_details/order_display.dart';
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
    try {
      int? orderId = Provider.of<OrderProvider>(context, listen: false).orderId;
      if (orderId == null) {
        debugPrint('order id is null');
        setState(() {
          isLoading = false;
        });
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      //fetch order details
      var orderResults = await connection.query(
          'select hallo.lmao.*, hallo.customer.cust_name from hallo.lmao join hallo.customer on hallo.customer.cust_id = hallo.lmao.cust_id where hallo.lmao.lmao_id = ?',
          [orderId]);

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
          'select hallo.lmao_details.*,hallo.item.item_name from hallo.lmao_details join hallo.item on hallo.lmao_details.item_id = hallo.item.item_id where lmao_id = ?',
          [orderId]);
      //map to lists
      List<OrderDetails> orderDetails = detailsResults.map((row) {
        return OrderDetails.fromJson(row.fields);
      }).toList();

      setState(() {
        orderDisplay = OrderDisplay.fromJson(orderRow.fields, orderDetails);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus() async {
    try {
      int? orderId = Provider.of<OrderProvider>(context, listen: false).orderId;
      if (orderId == null) {
        debugPrint('order id is null');
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      //update operation
      await connection.query(
          'update hallo.lmao set hallo.lmao.status = ? where hallo.lmao.lmao_id = ?',
          [selectedStatus, orderId]);
      //refresh page
      fetchOrderDetails();
    } catch (e) {
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
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Order ID: ${orderDisplay!.lmaoId}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vendor ID: ${orderDisplay!.id}'),
                                Text('Customer ID: ${orderDisplay!.custId}'),
                                Text(
                                    'Order desc: ${orderDisplay!.orderNumber}'),
                                Text(
                                    'Customer name: ${orderDisplay!.custName}'),
                                Text('Status: ${orderDisplay!.status}'),
                              ],
                            ),
                          ),
                        ),
                        _gap(),
                        const Text('Order Items:'),
                        ...orderDisplay!.details.map((detail) {
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text('Item id: ${detail.itemId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Item Name: ${detail.itemName}'),
                                  Text('Quantity: ${detail.lmaoQuantity}'),
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
