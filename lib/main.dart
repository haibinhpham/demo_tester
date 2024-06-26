import 'package:demo_tester/testing/controller/user_provider.dart';
import 'package:demo_tester/testing/view/auth/registration_screen.dart';
import 'package:demo_tester/testing/view/display_screen.dart';
import 'package:demo_tester/testing/view/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';

import 'testing/model/mysql.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Mysql().connection;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MaterialApp(
        title: 'Retrieve Stuff',
        debugShowCheckedModeBanner: false,
        home: RegistrationScreen(),
      ),
    );
  }
}