import 'dart:convert';
import  '../backend/database_helper.dart';
import '../models/inventory_item.dart';
import  '../models/inventory_bundle.dart';
import 'package:sqflite/sqflite.dart';

class InventoryHelper {
  static Future<List<InventoryItem>> getAllInventoryItems() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('inventory');
    return result.map((json) => InventoryItem.fromJson(json)).toList();
  }

  static Future<int> getLowStockItemCount() async {
    final items = await getAllInventoryItems();
    return items
        .where((item) => item.stock <= item.minStock)
        .length;
  }

  static Future<int> getActiveItemCount() async {
    final items = await getAllInventoryItems();
    return items.where((item) => item.stock > 0).length;
  }

  static Future<Map<String, int>> getInventoryStatusBreakdown() async {
    final items = await getAllInventoryItems();

    int inStock = 0;
    int lowStock = 0;
    int outOfStock = 0;

    for (var item in items) {
      if (item.stock > item.minStock) {
        inStock++;
      } else if (item.stock > 0) {
        lowStock++;
      } else {
        outOfStock++;
      }
    }

    return {
      'In Stock': inStock,
      'Low Stock': lowStock,
      'Out of Stock': outOfStock,
    };
  }

  static Future<void> insertInventoryItem(InventoryItem item) async {
    final db = await DatabaseHelper.instance.database;

    final existing = await db.query(
      'inventory',
      where: 'LOWER(name) = ?',
      whereArgs: [item.name.toLowerCase()],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      throw Exception('An item with this name already exists.');
    }

    await db.insert(
      'inventory',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteInventoryItemByName(String name) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'inventory',
      where: 'LOWER(name) = ?',
      whereArgs: [name.toLowerCase()],
    );
  }

  static Future<void> updateInventoryItemByName(InventoryItem item) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'inventory',
      item.toJson(),
      where: 'LOWER(name) = ?',
      whereArgs: [item.name.toLowerCase()],
    );
  }

  static Future<void> deductIngredientsForCheckoutItem(String checkoutItemName, int quantitySold) async {
    final db = await DatabaseHelper.instance.database;

    final bundleRows = await db.query(
      'inventory_bundles',
      where: 'checkout_item = ?',
      whereArgs: [checkoutItemName],
    );

    if (bundleRows.isEmpty) return;

    for (var row in bundleRows) {
      final ingredientName = row['ingredient_name'] as String?;
      if (ingredientName == null) continue;
      final qtyUsedPerUnit = row['quantity_used'] as int;

      final totalQtyToDeduct = qtyUsedPerUnit * quantitySold;

      await db.rawUpdate('''
        UPDATE inventory
        SET stock = stock - ?
        WHERE LOWER(name) = ?
      ''', [totalQtyToDeduct, ingredientName.toLowerCase()]);
    }
  }

  static Future<List<InventoryBundle>> getAllBundles() async {
    final db = await DatabaseHelper.instance.database;

    // Step 1: get all distinct checkout items (bundles)
    final checkoutItems = await db.rawQuery('''
      SELECT DISTINCT checkout_item FROM inventory_bundles
    ''');

    List<InventoryBundle> bundles = [];

    for (var row in checkoutItems) {
      final itemName = row['checkout_item'] as String;

      // Step 2: get all ingredients for this checkout item
      final ingredients = await db.query(
        'inventory_bundles',
        where: 'checkout_item = ?',
        whereArgs: [itemName],
      );

      final ingredientList = ingredients.map((ing) {
        return BundleIngredient(
          inventoryItemName: ing['ingredient_name'] as String,
          quantityUsed: ing['quantity_used'] as int,
        );
      }).toList();

      // Step 3: add fake placeholders unless you have SKU/salePrice stored elsewhere
      bundles.add(
        InventoryBundle(
          name: itemName,
          sku: 'N/A',
          salePrice: 0.0,
          status: 'active',
          ingredients: ingredientList,
        ),
      );
    }

    return bundles;
  }

  static Future<void> insertBundleItem({
    required String checkoutItem,
    required String ingredientName,
    required int quantityUsed,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('inventory_bundles', {
      'checkout_item': checkoutItem,
      'ingredient_name': ingredientName,
      'quantity_used': quantityUsed,
    });
  }

  static Future<List<String>> getCheckoutItemNames() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('order_items', columns: ['name']);
    final uniqueNames = result.map((row) => row['name'] as String).toSet().toList();
    return uniqueNames;
}
}

class DuplicateNameException implements Exception {
  final String message;
  DuplicateNameException([this.message = 'An item with this name already exists.']);

  @override
  String toString() => message;
}