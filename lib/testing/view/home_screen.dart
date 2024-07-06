import 'package:demo_tester/testing/controller/provider/home_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import '../controller/provider/user_provider.dart';
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
        debugPrint('User id null');
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
      debugPrint('Error fetching user: $e');
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
            Flexible(
              child: FittedBox(
                child: Text(
                  user == null ? 'Loading...' : 'Welcome, ${user!.fname}!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
              ),
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
                padding: const EdgeInsets.all(24.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: [
                    Card(
                      child: Consumer<HomeProvider>(builder: (_, provider, __) {
                        return InkWell(
                          onTap: () {
                            debugPrint('${provider.pageIndex}');
                            provider.pageIndex = 1;
                            debugPrint('${provider.pageIndex}');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.lightBlue,
                                child: Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              _gap(),
                              Text(
                                "Manage Order",
                                style: Theme.of(context).textTheme.titleSmall,
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                    Card(
                      child: Consumer<HomeProvider>(builder: (_, provider, __) {
                        return InkWell(
                          onTap: () {
                            debugPrint('${provider.pageIndex}');
                            provider.pageIndex = 2;
                            debugPrint('${provider.pageIndex}');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.lightBlue,
                                child: Icon(
                                  Icons.inventory_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              _gap(),
                              Text(
                                "Manage Item",
                                style: Theme.of(context).textTheme.titleSmall,
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                    Card(
                      child: Consumer<HomeProvider>(builder: (_, provider, __) {
                        return InkWell(
                          onTap: () {
                            debugPrint('${provider.pageIndex}');
                            provider.pageIndex = 3;
                            debugPrint('${provider.pageIndex}');
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.lightBlue,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              _gap(),
                              Text(
                                "Manage Customer",
                                style: Theme.of(context).textTheme.titleSmall,
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
