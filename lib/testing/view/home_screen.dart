import 'dart:ui';

import 'package:demo_tester/testing/view/customer/customer_list_screen.dart';
import 'package:demo_tester/testing/view/item/item_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../controller/user_provider.dart';
import '../model/mysql.dart';
import '../model/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;

  void fetchUserName() async {
    try {
      int? userId = Provider.of<UserProvider>(context, listen: false).userId;
      if (userId == null) {
        print('User id null');
        return;
      }
      MySqlConnection connection = await Mysql().connection;

      var results = await connection
          .query('select * from hallo.DEMO where id = ?', [userId]);

      if (results.isNotEmpty) {
        var userData = results.first.fields;
        setState(() {
          user = User.fromJson(userData);
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: Icon(CupertinoIcons.camera_on_rectangle),
            ),
            const SizedBox(width: 8),
            Text(
              user == null ? 'Loading...' : 'Welcome, ${user!.fname}!',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
          ],
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
              Colors.white,
              Colors.blue,
            ])),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Customer Management',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const CustomerListScreen();
                              })));
                            },
                          ),
                        ),
                        _gap(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Inventory Management',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: ((context) {
                                return const ItemListScreen();
                              })));
                            },
                          ),
                        ),
                        _gap(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Orders Management',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            onPressed: () async {},
                          ),
                        ),

                        // Add more fields as needed
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
