import 'package:demo_tester/testing/model/item.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../controller/provider/user_provider.dart';
import '../widgets/loading_indicator.dart';

class UpdateItemScreen extends StatefulWidget {
  final Item item;
  const UpdateItemScreen({super.key, required this.item});

  @override
  State<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  late Item item;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionCtroller =
      TextEditingController();
  final TextEditingController _itemPricecontroller = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final TextEditingController _itemImageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    item = widget.item;
    _itemNameController.text = item.itemName;
    _itemDescriptionCtroller.text = item.itemDescription;
    _itemPricecontroller.text = item.price.toString();
    _itemQuantityController.text = item.quantity.toString();
    _itemImageUrlController.text = item.imageUrl;
  }

  //todo add image functionality later
  Future<String> updateItem({
    required String itemName,
    required String itemDescription,
    required int itemPrice,
    required String imageUrl,
    required int quantity,
  }) async {
    UtilWidget.showLoadingDialog(context: context);
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('user id null');
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;

      //perform update operation
      await connection.query(
          "update Production.items set item_name = ?, item_desc = ?, amount = ?, price = ?, image_url = ? where Production.items.item_id = ?",
          [itemName, itemDescription, quantity, itemPrice, imageUrl, item.itemId]);
      Navigator.of(context).pop();
      return 'Item Updated!';
    } catch (e) {
      debugPrint('Error adding item: $e');
      Navigator.of(context).pop();
      return 'Error updating item';
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
                    if (message == 'Item Updated!') {
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
                String itemName = _itemNameController.text;
                String itemDescription = _itemDescriptionCtroller.text;
                int itemPrice = int.parse(_itemPricecontroller.text);
                String imageUrl = _itemImageUrlController.text;
                int itemQuantity = int.parse(_itemQuantityController.text);
                String result = await updateItem(
                  itemName: itemName,
                  itemDescription: itemDescription,
                  itemPrice: itemPrice,
                  imageUrl: imageUrl,
                  quantity: itemQuantity,
                );
                _showResultDialog(result);
              },
              child: const Text('Confirm'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Item',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _gap(),
                TextFormField(
                  controller: _itemNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                    prefixIcon: Icon(Icons.shopping_bag_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                TextFormField(
                  controller: _itemDescriptionCtroller,
                  decoration: const InputDecoration(
                    labelText: 'Item Description',
                    hintText: 'Enter item Description',
                    prefixIcon: Icon(Icons.description_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                TextFormField(
                  controller: _itemPricecontroller,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (int.parse(value) < 0) {
                      return "Price can't be negative";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'Enter Price',
                    prefixIcon: Icon(Icons.price_change_rounded),
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
                    if (int.parse(value) < 0) {
                      return 'Quantity should be possitive';
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
                    labelText: 'Image Url',
                    hintText: 'Enter image Url',
                    prefixIcon: Icon(Icons.image_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                _gap(),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showConfirmationDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  child: const Text('Update Item'),
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
