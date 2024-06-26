import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../../controller/user_provider.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    item = widget.item;
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        print('User id null');
        return;
      }
      //get connection
      MySqlConnection connection = await Mysql().connection;
      var results = await connection.query(
          'select * from hallo.item where id = ? and item_id = ?',
          [userId, widget.item.item_id]);

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
      print('Error get item details: $e');
    }
  }

  Future<void> updateItemQuantity(int quantity) async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      //get connection
      MySqlConnection connection = await Mysql().connection;
      //update operation
      await connection.query(
          'update hallo.item set hallo.item.quantity = ? where hallo.item.id = ? and hallo.item.item_id = ?',
          [quantity, userId, widget.item.item_id]);

      //reload the page
      fetchItemDetails();
      print('Quantity updated');
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<String> updateItemName() async {
    return 'Hallo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: 400,
                        height: 400,
                        color: Colors.cyan,
                        child: const Center(
                            child: Icon(CupertinoIcons.square_grid_2x2_fill)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    item.item_name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${item.item_id}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A short description of this product blahblahblahablaalasdlfa;jdajsdfja;lf',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle update quantity
                          _showUpdateDialog('Quantity');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('UPDATE QUANTITY'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle update name
                          _showUpdateDialog('Name');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('UPDATE NAME'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _showUpdateDialog(String field) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update $field'),
            content: SingleChildScrollView(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Enter new $field'),
                keyboardType: field == 'Quantity'
                    ? TextInputType.number
                    : TextInputType.text,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL')),
              TextButton(
                onPressed: () {
                  if (field == 'Quantity') {
                    if (int.tryParse(_controller.text) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please enter a valid number')));
                    } else {
                      print('Update $field');
                      //perform update login
                      Navigator.of(context).pop();
                    }
                  } else {
                    print('Update $field');
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('UPDATE'),
              )
            ],
          );
        });
  }

  Widget _gap() => const SizedBox(height: 16);
}
