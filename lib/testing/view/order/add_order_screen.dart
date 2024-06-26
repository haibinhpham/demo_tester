import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../controller/user_provider.dart';
import '../../model/mysql.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _orderNumberController = TextEditingController();

  Future<String> addNewOrder(String order_number) async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        print('User id null');
        return 'id is null';
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //check if order number already exists
      var results = await connection.query(
          'select count(*) as count from hallo.lmao where order_number = ?',
          [order_number]);
      int count = results.first['count'];
      if (count > 0) {
        return 'Order already exists';
      }

      //perform sql operations
      await connection.query(
          'insert into hallo.lmao(id,order_number) values(?,?)',
          [userId, order_number]);
      return 'Added Successfully';
    } catch (e) {
      print('Error with adding: $e');
      return 'Error adding';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Order'),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32.0),
            constraints: const BoxConstraints(maxWidth: 350),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Add New Order',
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _gap(),
                  TextFormField(
                    controller: _orderNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Order Number',
                      hintText: 'Enter order number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  _gap(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        String result =
                            await addNewOrder(_orderNumberController.text);
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Result'),
                                  content: Text(result),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'))
                                  ],
                                ));
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text('Add New Order',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
