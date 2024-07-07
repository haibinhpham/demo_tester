import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import '../model/mysql.dart';
import '../model/user.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // @override
  // void dispose() {
  //   Mysql().closeConnection(); // Close connection when screen is disposed
  //   super.dispose();
  // }

  Future<void> fetchData() async {
    try {
      MySqlConnection connection = await Mysql().connection;

      var results = await connection
          .query('SELECT * FROM hallo.DEMO'); // Query the 'DEMO' table

      List<User> fetchedUsers = [];
      for (var row in results) {
        var user = User.fromJson(row.fields);
        fetchedUsers.add(user);
      }

      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
    // Do not close connection here to keep it open for possible future operations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
        automaticallyImplyLeading: false,
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  title: Text('ID: ${user.userId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('First Name: ${user.username}'),
                      Text('Last Name: ${user.password}'),
                      Text('Address: ${user.email}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
