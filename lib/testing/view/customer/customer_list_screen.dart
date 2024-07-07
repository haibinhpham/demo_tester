import 'package:demo_tester/testing/controller/provider/customer_provider.dart';
import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/customer/add_customer_screen.dart';
import 'package:demo_tester/testing/view/customer/customer_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../model/customer.dart';
import '../widgets/loading_indicator.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  int count = 0;
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchAllCustomers();
  }

  void searchOperation(String val) {
    if (val.isEmpty) {
      setState(() {
        isSearching = false;
      });
    } else {
      setState(() {
        isSearching = true;
        filteredCustomers = customers
            .where((element) =>
                element.name.toLowerCase().startsWith(val.toLowerCase()))
            .toList();
      });
    }
  }

  void fetchAllCustomers() async {
    setState(() {
      isLoading = true;
    });
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
          'select Production.customers.* from Production.customers natural join Production.users where Production.users.user_id = ? and is_deleted = false',
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
    UtilWidget.showLoadingDialog(context: context);
    try {
      //get connection
      MySqlConnection connection = await Mysql().connection;
      //delete operation
      await connection.query(
          'update Production.customers set is_deleted = true where Production.customers.customer_id = ?',
          [customerId]);
      //reload after query
      fetchAllCustomers();
      Navigator.of(context).pop();
      return 'Delete Successful';
    } catch (e) {
      debugPrint('Error deleting item: $e');
      Navigator.of(context).pop();
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return const AddCustomerScreen();
          })).then((value) => fetchAllCustomers())
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => {searchOperation(val)},
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      hintText: 'Enter Customer name',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: !isSearching ? customers.length :filteredCustomers.length,
                    itemBuilder: (context, index) {
                      var customer = !isSearching ?customers[index] : filteredCustomers[index];
                      return Card.outlined(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.lightBlue,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                                Text(
                                  '+49 ${customer.phone}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Address: ${customer.address}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            trailing: InkWell(
                              child: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                _showConfirmationDialog(customer.customerId);
                                debugPrint('Delete icon pressed');
                              },
                            ),
                            onTap: () {
                              debugPrint('List Tile pressed');
                              //save to provider
                              Provider.of<CustomerProvider>(context,
                                      listen: false)
                                  .setCustomerId(customer.customerId);
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return const CustomerDetailScreen();
                                },
                              )).then((value) => fetchAllCustomers());
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
}
