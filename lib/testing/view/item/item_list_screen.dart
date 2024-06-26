import 'package:demo_tester/central_screen.dart';
import 'package:demo_tester/testing/controller/user_provider.dart';
import 'package:demo_tester/testing/view/home_screen.dart';
import 'package:demo_tester/testing/view/item/item_details_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../model/item.dart';
import '../../model/mysql.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<Item> items = [];
  int count = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllItems();
  }

  void fetchAllItems() async {
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
          'select hallo.item.* from hallo.item natural join hallo.DEMO where hallo.DEMO.id = ?',
          [userId]);
      print('Query executed, number of results: ${results.length}');

      List<Item> fetchedOrders = [];
      for (var row in results) {
        var order = Item.fromJson(row.fields);
        fetchedOrders.add(order);
      }
      setState(() {
        items = fetchedOrders;
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
            }));
          },
        ),
        elevation: 2,
        title: const Text(
          'Your Items',
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
                            colors: [Colors.blue, Colors.white])),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              print('Filter btn pressed');
                            },
                            icon: const Icon(CupertinoIcons.layers_alt)),
                        IconButton(
                            onPressed: () {
                              print('Add btn pressed');
                            },
                            icon: const Icon(CupertinoIcons.add)),
                      ],
                    ),
                  ),
                  _gap(),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var item = items[index];
                        return Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 30,
                              child: Icon(
                                CupertinoIcons.camera,
                                color: Colors.black,
                              ),
                            ),
                            title: Text(
                              'Name: ${item.item_name}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text('Id: ${item.item_id}',
                                      style: const TextStyle(fontSize: 16)),
                                  SizedBox(width: 16),
                                  Text('Quantity: ${item.quantity}',
                                      style: const TextStyle(fontSize: 16)),
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
                              print('List Tile Pressed');
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ItemDetailScreen(item: item);
                              }));
                            },
                          ),
                        );
                      }),
                ],
              ),
            ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
