import '../backend/database_helper.dart';
import '../models/order_model.dart';
import 'package:sqflite/sqflite.dart';

class AnalyticsService {
  static Future<void> saveOrder(Order order) async {
    final db = await DatabaseHelper.instance.database;

    // Insert order details
    await db.insert('orders', {
      'id': order.id,
      'timestamp': order.timestamp.toIso8601String(),
      'total': order.total,
      'subtotal': order.subtotal,
      'tax': order.tax,
      'tip': order.tip,
    });

    // Insert each item associated with the order
    for (final item in order.items) {
      await db.insert('order_items', {
        'order_id': order.id,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      });
    }
  }

  static Future<List<Order>> getOrders() async {
    final db = await DatabaseHelper.instance.database;

    final orderRows = await db.query('orders');
    final itemRows = await db.query('order_items');

    // Group order items by order ID
    final Map<String, List<OrderItem>> itemsByOrderId = {};
    for (final itemRow in itemRows) {
      final orderId = itemRow['order_id'] as String;
      final item = OrderItem(
        name: itemRow['name'] as String,
        price: (itemRow['price'] as num).toDouble(),
        quantity: itemRow['quantity'] as int,
      );
      itemsByOrderId.putIfAbsent(orderId, () => []).add(item);
    }

    // Reconstruct orders with their items
    return orderRows.map((row) {
      final orderId = row['id'] as String;
      return Order(
        id: orderId,
        timestamp: DateTime.parse(row['timestamp'] as String),
        items: itemsByOrderId[orderId] ?? [],
        total: (row['total'] as num?)?.toDouble() ?? 0.0,
        subtotal: (row['subtotal'] as num?)?.toDouble() ?? 0.0,
        tax: (row['tax'] as num?)?.toDouble() ?? 0.0,
        tip: (row['tip'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }
}
