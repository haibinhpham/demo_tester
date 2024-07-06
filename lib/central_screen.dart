import 'package:demo_tester/testing/controller/provider/home_provider.dart';
import 'package:demo_tester/testing/view/account/account_screen.dart';
import 'package:demo_tester/testing/view/item/item_list_screen.dart';
import 'package:demo_tester/testing/view/customer/customer_list_screen.dart';
import 'package:demo_tester/testing/view/home_screen.dart';
import 'package:demo_tester/testing/view/order/order_list_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CentralScreen extends StatefulWidget {
  const CentralScreen({super.key});

  @override
  State<CentralScreen> createState() => _CentralScreenState();
}

class _CentralScreenState extends State<CentralScreen> {
  final List<Widget> _pages = [
    const HomeScreen(),
    const OrderListScreen(),
    const ItemListScreen(),
    const CustomerListScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, provider, __) => PopScope(
        canPop: false,
        onPopInvoked: (didPop){
            provider.pageIndex = 0;
        },
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: provider.pageIndex,
            onTap: (value) {
              setState(() {
                provider.pageIndex = value;
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
                icon: Icon(CupertinoIcons.profile_circled),
                label: '',
              )
            ],
          ),
          body: _pages[provider.pageIndex],
        ),
      ),
    );
  }
}
