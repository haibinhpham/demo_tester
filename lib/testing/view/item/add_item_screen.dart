import 'package:demo_tester/testing/model/mysql.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../controller/provider/user_provider.dart';
import 'item_list_screen.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final TextEditingController _itemImageUrlController = TextEditingController();

  //todo add image functionality later
  Future<String> addItem(String itemName, int quantity) async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('user id null');
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //check if same item name already exists
      var results = await connection.query(
          'select count(*) as count from hallo.item where item_name = ?',
          [itemName]);
      int count = results.first['count'];
      if (count > 0) {
        debugPrint('Order already exists');
        return 'Order already exists';
      }

      //perform add operation
      await connection.query(
          'insert into hallo.item(id,item_name,quantity) values(?,?,?)',
          [userId, itemName, quantity]);
      return 'Item added!';
    } catch (e) {
      debugPrint('Error adding item: $e');
      return 'Error adding item';
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
                    if (message == 'Item added!') {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  void _showConfirmationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String itemName = _itemNameController.text;
                      int itemQuantity =
                          int.parse(_itemQuantityController.text);
                      String result = await addItem(itemName, itemQuantity);
                      _showResultDialog(result);
                    }
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
          'Add Item',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _gap(),
                _gap(),
                TextFormField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                    prefixIcon: Icon(Icons.add_card),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                TextFormField(
                  controller: _itemQuantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Enter quantity',
                    prefixIcon: Icon(Icons.numbers_sharp),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                TextFormField(
                  controller: _itemImageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image',
                    hintText: 'Enter image',
                    prefixIcon: Icon(Icons.add_card),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                _gap(),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                    child: const Text('Add Item'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
