import 'package:flutter/material.dart';

import '../../model/customer.dart';

class CustomerProvider extends ChangeNotifier {
  int? custId;
  Customer? customerInfo;
  List<Map<String, dynamic>> customerOrders = [];

  void setCustomerId(int id) {
    custId = id;
    notifyListeners();
  }

  void setCustomerInfo(Customer info) {
    customerInfo = info;
    notifyListeners();
  }

  void setCustomerOrders(List<Map<String, dynamic>> orders) {
    customerOrders = orders;
    notifyListeners();
  }
}
