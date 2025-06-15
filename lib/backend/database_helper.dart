import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/order_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'pos_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;

    final ordersData = await db.query('orders');
    List<Order> orders = [];

    for (var orderMap in ordersData) {
      final orderId = orderMap['id'] as String;

      final itemsData = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();

      orders.add(Order(
        id: orderId,
        timestamp: DateTime.parse(orderMap['timestamp'] as String),
        items: items,
        subtotal: ((orderMap['subtotal'] ?? 0) as num).toDouble(),
        tax: ((orderMap['tax'] ?? 0) as num).toDouble(),
        tip: ((orderMap['tip'] ?? 0) as num).toDouble(),
        total: ((orderMap['total'] ?? 0) as num).toDouble(),

        paymentMethod: orderMap['payment_method'] as String? ?? 'Card',
        status: orderMap['status'] as String? ?? 'Completed',
      ));
    }

    return orders;
  }

  Future<void> resetDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'pos_database.db');

    await deleteDatabase(path); // delete the DB
    _database = null;

    // Reopen the DB to trigger _onCreate
    await database;
  }

  Future<List<Order>> getTransactionsSince(DateTime from) async {
    final db = await database;

    final ordersData = await db.query(
      'orders',
      where: 'timestamp >= ?',
      whereArgs: [from.toIso8601String()],
    );

    List<Order> orders = [];

    for (var orderMap in ordersData) {
      final orderId = orderMap['id'] as String;

      final itemsData = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();

      orders.add(Order(
        id: orderId,
        timestamp: DateTime.parse(orderMap['timestamp'] as String),
        items: items,
        subtotal: ((orderMap['subtotal'] ?? 0) as num).toDouble(),
        tax: ((orderMap['tax'] ?? 0) as num).toDouble(),
        tip: ((orderMap['tip'] ?? 0) as num).toDouble(),
        total: ((orderMap['total'] ?? 0) as num).toDouble(),
        paymentMethod: orderMap['payment_method'] as String? ?? 'Card',
        status: orderMap['status'] as String? ?? 'Completed',
      ));
    }

    return orders;
  }

  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    final db = await database;

    final ordersData = await db.query(
      'orders',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    List<Order> orders = [];

    for (var orderMap in ordersData) {
      final orderId = orderMap['id'] as String;

      final itemsData = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();

      orders.add(Order(
        id: orderId,
        timestamp: DateTime.parse(orderMap['timestamp'] as String),
        items: items,
        subtotal: ((orderMap['subtotal'] ?? 0) as num).toDouble(),
        tax: ((orderMap['tax'] ?? 0) as num).toDouble(),
        tip: ((orderMap['tip'] ?? 0) as num).toDouble(),
        total: ((orderMap['total'] ?? 0) as num).toDouble(),
        paymentMethod: orderMap['payment_method'] as String? ?? 'Card',
        status: orderMap['status'] as String? ?? 'Completed',
      ));
    }

    return orders;
  }

  Future<Map<String, Map<String, dynamic>>> getTopSellingItems({int limit = 5}) async {
    final db = await database;

    final itemsData = await db.rawQuery('''
      SELECT name, SUM(quantity) as totalSold, SUM(quantity * price) as totalRevenue
      FROM order_items
      GROUP BY name
      ORDER BY totalSold DESC
      LIMIT ?
    ''', [limit]);

    final Map<String, Map<String, dynamic>> topItems = {};
    for (var row in itemsData) {
      topItems[row['name'] as String] = {
        'sold': row['totalSold'],
        'revenue': row['totalRevenue'],
      };
    }

    return topItems;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        timestamp TEXT,
        total REAL,
        subtotal REAL,
        tax REAL,
        tip REAL,
        payment_method TEXT DEFAULT 'Card',
        status TEXT DEFAULT 'Completed'
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT,
        name TEXT,
        price REAL,
        quantity INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE inventory (
      name TEXT PRIMARY KEY,
      sku TEXT,
      category TEXT,
      price REAL,
      stock INTEGER,
      status TEXT,
      minStock INTEGER,
      supplier TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE inventory_bundles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      checkout_item TEXT,
      ingredient_name TEXT,
      quantity_used INTEGER
    )
  ''');
  }
}