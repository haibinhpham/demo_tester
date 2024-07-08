import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/view/item/add_item_screen.dart';
import 'package:demo_tester/testing/view/item/item_details_screen.dart';
import 'package:demo_tester/testing/view/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<Item> filteredItems = [];
  bool isLoading = true;
  bool isSearching = false;
  final f = NumberFormat("###,###.###", "id_ID");

  @override
  void initState() {
    super.initState();
    fetchAllItems();
  }

  void fetchAllItems() async {
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
          'select Production.items.* from Production.items where Production.items.seller_id = ?',
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
    UtilWidget.showLoadingDialog(context: context);
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        return 'User ID is null';
      }
      //get connection
      MySqlConnection connection = await Mysql().connection;
      //delete operation

      await connection.query(
          'delete from Production.items where Production.items.item_id = ?',
          [itemId]);
      //reload after query
      fetchAllItems();
      Navigator.of(context).pop();
      return 'Delete Successful';
    } catch (e) {
      debugPrint('Error deleting item: $e');
      Navigator.of(context).pop();
      return 'Delete Error';
    }
  }

  void searchOperation(String val) {
    if (val.isEmpty) {
      setState(() {
        isSearching = false;
      });
    } else {
      setState(() {
        isSearching = true;
        filteredItems =
            items.where((element) => element.itemName.toLowerCase().startsWith(val.toLowerCase())).toList();
      });
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
      },
    );
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
      },
    );
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return const AddItemScreen();
          })).then((value) => fetchAllItems())
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
                      labelText: 'Item Name',
                      hintText: 'Enter item name',
                      prefixIcon: Icon(Icons.search_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        !isSearching ? items.length : filteredItems.length,
                    itemBuilder: (context, index) {
                      var item =
                          !isSearching ? items[index] : filteredItems[index];
                      return Card.outlined(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.lightBlue,
                            radius: 30,
                            foregroundImage: NetworkImage(item
                                    .imageUrl.isNotEmpty
                                ? item.imageUrl
                                : "https://upload.wikimedia.org/wikipedia/commons/a/af/Question_mark.png"),
                          ),
                          title: Text(
                            item.itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          subtitle: Row(
                            children: [
                              Flexible(
                                child: FittedBox(
                                  child: Text('Id: ${item.itemId}',
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Flexible(
                                child: FittedBox(
                                  child: Text(
                                      'Quantity: ${f.format(item.quantity)}',
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                ),
                              ),
                            ],
                          ),
                          trailing: GestureDetector(
                            child: const Icon(
                              Icons.delete,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              _showConfirmationDialog(item.itemId);
                            },
                          ),
                          onTap: () {
                            debugPrint('List Tile Pressed');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ItemDetailScreen(item: item);
                                },
                              ),
                            ).then((value) => fetchAllItems());
                          },
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
