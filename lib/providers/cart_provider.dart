import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingCartList extends ChangeNotifier {
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);

  ShoppingCartList() {
    _loadCart();
  }

  void add(String item) {
    _items.add(item);
    notifyListeners();
    _saveCart();
  }

  void remove(String item) {
    _items.remove(item);
    notifyListeners();
    _saveCart();
  }

  void removeAll(String item) {
    _items.removeWhere((i) => i == item);
    notifyListeners();
    _saveCart();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cart_items', _items);
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('cart_items');
    if (saved != null) {
      _items.clear();
      _items.addAll(saved);
      notifyListeners();
    }
  }
}