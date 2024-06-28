import 'package:demo_tester/central_screen.dart';
import 'package:demo_tester/testing/controller/user_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/customer/add_customer_screen.dart';
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
        print('User id is null');
        setState(() {
          isLoading = false;
        });
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      var results = await connection.query(
          'select hallo.customer.* from hallo.customer natural join hallo.DEMO where hallo.DEMO.id = ?',
          [userId]);

      print('Query executed, number of results: ${results.length}');

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
      print('Error fetching customers: $e');
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return const CentralScreen();
            }));
          },
        ),
        title: const Text(
          'Your Customers',
          style: TextStyle(
              fontSize: 28,
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
                              print('Filter btn pressed');
                            },
                            icon: const Icon(CupertinoIcons.layers_alt)),
                        GestureDetector(
                          child: IconButton(
                              onPressed: () {
                                print('Add btn pressed');
                                Navigator.pushReplacement(context,
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
                          child: Container(
                            // decoration: const BoxDecoration(
                            //     gradient: LinearGradient(
                            //         begin: Alignment.topCenter,
                            //         end: Alignment.bottomCenter,
                            //         colors: [
                            //       Colors.white,
                            //       Colors.lightBlueAccent,
                            //     ])),
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.black,
                              ),
                              title: Text(
                                'Name: ${customer.cust_name}',
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
                                      'Id: ${customer.cust_id}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    _gap(),
                                    //todo add from db
                                    Text(
                                      'Phone: 1111111',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    _gap(),
                                    //todo add from db
                                    Text(
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
                                  print('Delete icon pressed');
                                },
                              ),
                              onTap: () {
                                print('List Tile pressed');
                              },
                            ),
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
