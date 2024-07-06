import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../controller/provider/user_provider.dart';
import '../../model/mysql.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _orderNumberController = TextEditingController();

  //
  List<String> customerNames = [];
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> customers = [];

  //List<String> itemNames = [];
  String? selectedCustomer;
  String? selectedItem;
  Map<String, int> selectedItems = {};
  bool isLoadingCustomers = true;
  bool isLoadingItems = true;

  // @override
  // void initState() {
  //   super.initState();
  //   fetchCustomerNames();
  //   fetchItemNames();
  // }

  // Future<String> addNewOrder(String order_number) async {
  //   try {
  //     //get provider
  //     int? userId = Provider.of<UserProvider>(context, listen: false).userId;
  //     if (userId == null) {
  //       print('User id null');
  //       return 'id is null';
  //     }
  //     //get conn
  //     MySqlConnection connection = await Mysql().connection;
  //     //check if order number already exists
  //     var results = await connection.query(
  //         'select count(*) as count from hallo.lmao where order_number = ?',
  //         [order_number]);
  //     int count = results.first['count'];
  //     if (count > 0) {
  //       return 'Order already exists';
  //     }
  //
  //     //perform sql operations
  //     await connection.query(
  //         'insert into hallo.lmao(id,order_number) values(?,?)',
  //         [userId, order_number]);
  //     return 'Added Successfully';
  //   } catch (e) {
  //     print('Error with adding: $e');
  //     return 'Error adding';
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchCustomerNames();
    fetchItemNames();
  }

  Future<void> fetchCustomerNames() async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('User id is null');
        return;
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //perform operation
      var results = await connection.query(
          'select hallo.customer.cust_id,hallo.customer.cust_name from hallo.customer where hallo.customer.id = ?',
          [userId]);
      //map to dropdown
      setState(() {
        //map id and names to list of maps
        customers = results
            .map((row) =>
                {'cust_id': row['cust_id'], 'cust_name': row['cust_name']})
            .toList();
        //map names to dropdown
        customerNames =
            customers.map((row) => row['cust_name'] as String).toList();

        isLoadingCustomers = false;
      });
    } catch (e) {
      debugPrint('Error fetching customer names: $e');
      setState(() {
        isLoadingCustomers = false;
      });
    }
  }

  Future<void> fetchItemNames() async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('User id is null');
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;
      //perform operation
      var results = await connection.query(
          'select hallo.item.item_name,hallo.item.quantity from hallo.item where hallo.item.id = ?',
          [userId]);
      //map to dropdown
      setState(() {
        items = results
            .map((row) => {
                  'item_name': row['item_name'],
                  'quantity': row['quantity'],
                })
            .toList();
        isLoadingItems = false;
      });
    } catch (e) {
      debugPrint('Error fetching item names: $e');
      setState(() {
        isLoadingItems = false;
      });
    }
  }

  void addItem() async {
    if (selectedItem != null) {
      final quantityController = TextEditingController();
      final selectedItemData =
          items.firstWhere((item) => item['item_name'] == selectedItem);
      final availableQuantity = selectedItemData['quantity'];
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Enter Quantity'),
              content: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Quantity'),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      final quantity = int.tryParse(quantityController.text);
                      if (quantity != null && quantity > 0) {
                        if (quantity <= availableQuantity) {
                          setState(() {
                            selectedItems[selectedItem!] = quantity;
                          });
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Quantity exceeds available stock ($availableQuantity)')));
                        }
                      }
                    },
                    child: const Text('Add'))
              ],
            );
          });
    }
  }

  Future<void> performAddOrder() async {
    try {
      //get provider
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        debugPrint('user id is null');
        return;
      }
      //get conn
      MySqlConnection connection = await Mysql().connection;

      //start transaction
      await connection.transaction((txn) async {
        //retrieve customer id from chosen customer name
        var selectedCustomerData = customers.firstWhere(
            (customer) => customer['cust_name'] == selectedCustomer);
        int customerId = selectedCustomerData['cust_id'];
        //add entry into lmao table
        var lmaoResult = await txn.query(
            'insert into hallo.lmao(id,order_number,cust_id,status) values (?,?,?,?)',
            [userId, _orderNumberController.text, customerId, 'created']);

        //get the new lmao_id
        int lmaoId = lmaoResult.insertId!;

        //add entries into lmao details
        for (var entry in selectedItems.entries) {
          var itemResult = await txn.query(
              'select hallo.item.item_id, hallo.item.quantity from hallo.item where hallo.item.item_name = ? and hallo.item.id = ?',
              [entry.key, userId]);

          if (itemResult.isEmpty) {
            debugPrint('Item not found: ${entry.key}');
            throw Exception('Item not found: ${entry.key}');
          }

          int itemId = itemResult.first['item_id'];
          int currentQuantity = itemResult.first['quantity'];

          if (entry.value > currentQuantity) {
            debugPrint('Not enough stock for item: ${entry.key}');
            throw Exception('Not enough stock for item: ${entry.key}');
          }
          //insert into lmao details
          await txn.query(
              'insert into hallo.lmao_details(id,lmao_id,item_id,lmao_quantity) values (?,?,?,?)',
              [userId, lmaoId, itemId, entry.value]);

          //update item quantity
          await txn.query(
              'update hallo.item set quantity = quantity - ? where hallo.item.item_id = ?',
              [entry.value, itemId]);
        }
        debugPrint('Order added successfully');
        clearFormFields();
      });
    } catch (e) {
      debugPrint('Error performing query $e');
    }
  }

  void clearFormFields() {
    setState(() {
      _orderNumberController.clear();
      selectedCustomer = null;
      selectedItem = null;
      selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Order',
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
      body: (isLoadingCustomers || isLoadingItems)
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Order',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
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
                    DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCustomer,
                        hint: const Text('Select Customer'),
                        items: customerNames.map((name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCustomer = value;
                          });
                        }),
                    _gap(),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedItem,
                              hint: const Text('Select Item'),
                              items: items.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['item_name'],
                                  child: Text(
                                      '${item['item_name']} (${item['quantity']})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedItem = value;
                                });
                              }),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: addItem,
                        ),
                      ],
                    ),
                    _gap(),
                    const Text("Added Items: ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    selectedItems.entries.isEmpty
                        ? const Text("No items have been added")
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: selectedItems.entries.map((entry) {
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  title: Text(entry.key),
                                  subtitle: Text("Qty: ${entry.value}"),
                                  trailing: IconButton(onPressed: ()=> setState(()=>selectedItems.remove(entry.key)), icon: Icon(Icons.delete_rounded))
                                ),
                              );
                            }).toList(),
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
                          if(_formKey.currentState!.validate()){

                          }
                          await performAddOrder();
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
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
