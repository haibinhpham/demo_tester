import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? userId;

  void setUserId(int id) {
    userId = id;
    notifyListeners();
  }
}
