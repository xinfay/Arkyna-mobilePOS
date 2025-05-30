import 'package:mobile_pos/models/inventory_item.dart';
import 'package:mobile_pos/models/checkout_item.dart';
import 'dart:collection';

class BundledItem {
  String name;
  String sku;
  List<InventoryItem>? items = [];
  LinkedHashMap<String, int>? itemCounts;
  List<CheckoutItem>? checkoutItems = [];
  double price;
  String? stockStatus;

  BundledItem(
    this.name,
    this.sku,
    this.price, 
  );

  void calculateStockStatus() {
    if (items == null || items!.isEmpty) {
      stockStatus = "Missing Items";
      return;
    }
    bool hasLowStock = false;
    for (final item in items!) {
      if (item.status == "Out of Stock") {
        stockStatus = "Missing Items";
        return;
      }
      if (item.status == "Low Stock") {
        hasLowStock = true;
      }
    }
    stockStatus = hasLowStock ? "Low Stock" : "Ready";
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'items': items?.map((item) => item.toJson()).toList(),
    'price': price,
    'stockStatus': stockStatus,
  };

  static BundledItem fromJson(Map<String, dynamic> json) => BundledItem(
    json['name'],
    json['sku'],
    (json['price'] as num).toDouble(),
  )
    ..items = (json['items'] as List?)
        ?.map((item) => InventoryItem.fromJson(item))
        .toList()
    ..stockStatus = json['stockStatus'];
}