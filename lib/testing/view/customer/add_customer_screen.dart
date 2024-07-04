import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/customer/customer_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController =
      TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();

  //todo add address and phone later in db
  Future<String> addCustomer(String customerName) async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        print('user id null');
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //todo perform checks (tbd)

      //perform add operation
      await connection.query(
          'insert into hallo.customer(id,cust_name) values (?,?)',
          [userId, customerName]);
      return 'Customer added!';
    } catch (e) {
      print('Error adding customer: $e');
      return 'Error adding customer';
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
                    if (message == 'Customer added!') {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return const CustomerListScreen();
                      }));
                    }
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  //todo modify according to db change later
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
                      String customerName = _customerNameController.text;
                      String result = await addCustomer(customerName);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return const CustomerListScreen();
            }));
          },
        ),
        title: const Text(
          'Add Customer',
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
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer name',
                    hintText: 'Enter customer name',
                    prefixIcon: Icon(CupertinoIcons.person_add_solid),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                TextFormField(
                  controller: _customerPhoneController,
                  keyboardType: TextInputType.number,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter a quantity';
                  //   }
                  //   if (int.tryParse(value) == null) {
                  //     return 'Please enter a valid number';
                  //   }
                  //   return null;
                  // },
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(CupertinoIcons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                _gap(),
                TextFormField(
                  controller: _customerAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter customer address',
                    prefixIcon: Icon(CupertinoIcons.location),
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
                    child: const Text('Add Customer'),
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
