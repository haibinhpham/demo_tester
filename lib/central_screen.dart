import 'package:demo_tester/testing/view/account/account_screen.dart';
import 'package:demo_tester/testing/view/item/item_list_screen.dart';
import 'package:demo_tester/testing/view/order/add_order_screen.dart';
import 'package:demo_tester/testing/view/customer/customer_list_screen.dart';
import 'package:demo_tester/testing/view/display_screen.dart';
import 'package:demo_tester/testing/view/home_screen.dart';
import 'package:demo_tester/testing/view/order/order_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CentralScreen extends StatefulWidget {
  const CentralScreen({super.key});

  @override
  State<CentralScreen> createState() => _CentralScreenState();
}

class _CentralScreenState extends State<CentralScreen> {
  int _pageIndex = 0;

  List<Widget> _pages = [
    HomeScreen(),
    OrderScreen(),
    ItemListScreen(),
    CustomerListScreen(),
    AddOrderScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.lightBlue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.light_max),
          //   label: 'USERS',
          // ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_dash),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.info_circle),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_3_fill),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            label: '',
          )
        ],
      ),
      body: _pages[_pageIndex],
    );
  }
}
