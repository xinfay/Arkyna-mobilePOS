import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class AnalyticsService {
  static const String _storageKey = 'completed_orders';

  static Future<void> saveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_storageKey);

    final List<Order> orders = existing != null
        ? (jsonDecode(existing) as List<dynamic>)
            .map((e) => Order.fromJson(e))
            .toList()
        : [];

    orders.add(order);

    final encoded = jsonEncode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => Order.fromJson(e)).toList();
  }
}