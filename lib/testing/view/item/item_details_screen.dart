import 'package:demo_tester/testing/view/item/item_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../../controller/provider/user_provider.dart';
import '../../model/item.dart';
import '../../model/mysql.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});
  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item item;
  bool isLoading = false;
  final f = NumberFormat("###,###.###", "id_ID");

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  Future<void> fetchItemDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('User id null');
        return;
      }
      //get connection
      MySqlConnection connection = await Mysql().connection;
      var results = await connection.query(
          'select * from Production.items where Production.items.item_id = ?',
          [item.itemId]);

      if (results.isNotEmpty) {
        var userData = results.first.fields;
        setState(() {
          item = Item.fromJson(userData);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error get item details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Item Details',
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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return UpdateItemScreen(item: item);
                })).then((_) => fetchItemDetails());
              },
              icon: const Icon(Icons.edit_rounded),
            ),
          ]),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(20.0),
                      image: DecorationImage(
                          image: NetworkImage(item.imageUrl.isNotEmpty
                              ? item.imageUrl
                              : "https://upload.wikimedia.org/wikipedia/commons/a/af/Question_mark.png"),
                          fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${item.itemId}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${item.itemDescription}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Price: ${f.format(item.price)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${f.format(item.quantity)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}
