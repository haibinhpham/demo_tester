import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  int? orderId;

  void setOrderId(int id) {
    orderId = id;
    notifyListeners();
  }
}
