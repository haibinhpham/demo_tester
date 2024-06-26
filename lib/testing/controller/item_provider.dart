import 'package:flutter/material.dart';

class ItemProvider extends ChangeNotifier {
  int? itemId;

  void setItemId(int id) {
    itemId = id;
    notifyListeners();
  }
}
