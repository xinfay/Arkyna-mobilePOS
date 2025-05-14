import 'package:flutter/material.dart';



class ShoppingCartList extends ChangeNotifier {
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);

  void add(String item) {
    _items.add(item);
    notifyListeners();
  }

  void remove(String item) {
    _items.remove(item);
    notifyListeners();
  }

  void removeAll(String item) {
    _items.removeWhere((i) => i == item);
    notifyListeners();
  }
}