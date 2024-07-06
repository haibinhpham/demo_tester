import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/view/item/add_item_screen.dart';
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
        debugPrint('User id null');
        setState(() {
          isLoading = false;
        });
        return;
      }
      MySqlConnection connection = await Mysql().connection;
      var results = await connection.query(
          'select hallo.item.* from hallo.item natural join hallo.DEMO where hallo.DEMO.id = ?',
          [userId]);
      debugPrint('Query executed, number of results: ${results.length}');

      List<Item> fetchedItems = [];
      for (var row in results) {
        var item = Item.fromJson(row.fields);
        fetchedItems.add(item);
      }
      setState(() {
        items = fetchedItems;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error trying fetch: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> deleteItem(int itemId) async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        return 'User ID is null';
      }
      //get connection
      MySqlConnection connection = await Mysql().connection;
      //delete operation
      //todo insert query
      await connection.query(
          'delete from hallo.item where hallo.item.id = ? and hallo.item.item_id = ?',
          [userId, itemId]);
      //reload after query
      fetchAllItems();
      return 'Delete Successful';
    } catch (e) {
      debugPrint('Error deleteing item: $e');
      return 'Delete Error';
    }
  }

  void _showConfirmationDialog(int itemId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    String result = await deleteItem(itemId);
                    _showResultDialog(result);
                  },
                  child: const Text('Confirm')),
            ],
          );
        });
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
                  child: const Text('OK')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text(
          'Your Items',
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
                            colors: [Colors.blue, Colors.white])),
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
                                  return const AddItemScreen();
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
                              'Name: ${item.itemName}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Text('Id: ${item.itemId}',
                                      style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 16.0),
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
                                _showConfirmationDialog(item.itemId);
                                debugPrint('Delete icon pressed');
                              },
                            ),
                            onTap: () {
                              debugPrint('List Tile Pressed');
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
