import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/model/customer.dart';
import 'package:demo_tester/testing/model/mysql.dart';
import 'package:demo_tester/testing/view/widgets/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

class UpdateCustomerScreen extends StatefulWidget {
  final Customer customer;
  const UpdateCustomerScreen({super.key, required this.customer});

  @override
  State<UpdateCustomerScreen> createState() => _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  late Customer customer;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController =
      TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();

  //todo add address and phone later in db
  Future<String> updateCustomer() async {
    UtilWidget.showLoadingDialog(context: context);
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('user id null');
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //todo perform checks (tbd)

      //perform add operation
      await connection.query(
          'update Production.customers set name = ?, address = ?, phone = ? where Production.customers.customer_id = ?',
          [
            _customerNameController.text,
            _customerAddressController.text,
            _customerPhoneController.text,
            customer.customerId,
          ]);
      Navigator.of(context).pop();
      return 'Customer updated!';
    } catch (e) {
      debugPrint('Error updating customer: $e');
      Navigator.of(context).pop();
      return 'Error updating customer';
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'))
          ],
        );
      },
    );
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
                  String result = await updateCustomer();
                  _showResultDialog(result);
                },
                child: const Text('Confirm'))
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    customer = widget.customer;
    _customerNameController.text = customer.name;
    _customerAddressController.text = customer.address;
    _customerPhoneController.text = customer.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Update Customer',
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
                  controller: _customerNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer phone number';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer address';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter customer address',
                    prefixIcon: Icon(CupertinoIcons.location),
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
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                    child: const Text('Update Customer'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
