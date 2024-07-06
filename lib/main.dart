import 'package:demo_tester/testing/controller/provider/customer_provider.dart';
import 'package:demo_tester/testing/controller/provider/home_provider.dart';
import 'package:demo_tester/testing/controller/provider/order_provider.dart';
import 'package:demo_tester/testing/controller/provider/user_provider.dart';
import 'package:demo_tester/testing/view/auth/registration_screen.dart';
import 'package:flutter/material.dart';
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
  // @override
  // Widget build(BuildContext context) {
  //   return ChangeNotifierProvider(
  //     create: (context) => UserProvider(),
  //     child: const MaterialApp(
  //       title: 'Retrieve Stuff',
  //       debugShowCheckedModeBanner: false,
  //       home: RegistrationScreen(),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => CustomerProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
      ],
      child: MaterialApp(
        title: 'Retrieve Stuff',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white,
            ), // set backbutton color here which will reflect in all screens.
          ),
        ),
        home: const RegistrationScreen(),
      ),
    );
  }
}
