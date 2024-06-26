import 'package:demo_tester/testing/view/auth/signin_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import '../../controller/user_provider.dart';
import '../../model/mysql.dart';
import '../../model/user.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Profile',
        //       style: TextStyle(
        //         letterSpacing: 4,
        //         fontSize: 20,
        //         fontWeight: FontWeight.bold,
        //       )),
        //   automaticallyImplyLeading: false,
        //   centerTitle: true,
        // ),
        body: user == null
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.lightBlue,
                        child: Icon(
                          CupertinoIcons.camera,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      itemProfile('Name', user!.fname, CupertinoIcons.person),
                      const SizedBox(height: 10),
                      itemProfile(
                          'Last Name', user!.lname, CupertinoIcons.phone),
                      const SizedBox(height: 10),
                      itemProfile(
                          'Address', user!.address, CupertinoIcons.location),
                      const SizedBox(height: 10),
                      itemProfile(
                          'Email', '${user!.id}', CupertinoIcons.person),
                      const SizedBox(
                        height: 20,
                      ),
                      _gap(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.lightBlue,
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            )),
                      )
                    ],
                  ),
                ),
              ));
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 5),
                color: Colors.blue.withOpacity(.4),
                spreadRadius: 2,
                blurRadius: 10)
          ]),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);

  void _showConfirmationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              ElevatedButton(
                  style: ButtonStyle(),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SigninScreen()));
                  },
                  child: const Text('Confirm'))
            ],
          );
        });
  }
}
