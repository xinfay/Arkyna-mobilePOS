import 'package:mobile_pos/models/inventory_item.dart';

class BundledItem {
  String name;
  String sku;
  List<InventoryItem>? items;
  double price;
  String? stockStatus;

  BundledItem(
    this.name,
    this.sku,
    this.price, 
  );

  //TODO: add method for calculating stock status based on items

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