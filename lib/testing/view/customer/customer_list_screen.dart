import 'package:demo_tester/testing/controller/provider/customer_provider.dart';
import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/customer/add_customer_screen.dart';
import 'package:demo_tester/testing/view/customer/customer_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../model/customer.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Customer> customers = [];
  int count = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllCustomers();
  }

  void fetchAllCustomers() async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('User id is null');
        setState(() {
          isLoading = false;
        });
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      var results = await connection.query(
          'select hallo.customer.* from hallo.customer natural join hallo.DEMO where hallo.DEMO.id = ?',
          [userId]);

      debugPrint('Query executed, number of results: ${results.length}');

      List<Customer> fetchedCustomers = [];
      for (var row in results) {
        var customer = Customer.fromJson(row.fields);
        fetchedCustomers.add(customer);
      }
      setState(() {
        customers = fetchedCustomers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> deleteCustomer(int customerId) async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        return 'User id is null';
      }
      //get connection
      MySqlConnection connection = await Mysql().connection;
      //delete operation
      await connection.query(
          'delete from hallo.customer where hallo.customer.id = ? and hallo.customer.cust_id = ?',
          [userId, customerId]);
      //reload after query
      fetchAllCustomers();
      return 'Delete Successful';
    } catch (e) {
      debugPrint('Error deleting item: $e');
      return 'Delete Error';
    }
  }

  void _showResultDialog(String message) {
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
                  child: const Text('OK'))
            ],
          );
        });
  }

  void _showConfirmationDialog(int customerId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    String result = await deleteCustomer(customerId);
                    _showResultDialog(result);
                  },
                  child: const Text('Confirm'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Customers',
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
              ])),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue, Colors.white],
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              debugPrint('Filter btn pressed');
                            },
                            icon: const Icon(CupertinoIcons.layers_alt)),
                        GestureDetector(
                          child: IconButton(
                              onPressed: () {
                                debugPrint('Add btn pressed');
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const AddCustomerScreen();
                                }));
                              },
                              icon: const Icon(CupertinoIcons.add)),
                        ),
                      ],
                    ),
                  ),
                  _gap(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      var customer = customers[index];
                      return Card(
                        elevation: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.black,
                            ),
                            title: Text(
                              'Name: ${customer.custName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Id: ${customer.custId}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  _gap(),
                                  //todo add from db
                                  const Text(
                                    'Phone: 1111111',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  _gap(),
                                  //todo add from db
                                  const Text(
                                    'Address: 11 Yilong Str. Shenzhen',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  _gap(),
                                ],
                              ),
                            ),
                            trailing: GestureDetector(
                              child: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                _showConfirmationDialog(customer.custId);
                                debugPrint('Delete icon pressed');
                              },
                            ),
                            onTap: () {
                              debugPrint('List Tile pressed');
                              //save to provider
                              Provider.of<CustomerProvider>(context,
                                      listen: false)
                                  .setCustomerId(customer.custId);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const CustomerDetailScreen();
                              }));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
