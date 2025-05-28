class InventoryItem {
  String name;
  String sku;
  String category;
  double price;
  int stock;
  String status;

  InventoryItem(
    this.name,
    this.sku,
    this.category,
    this.price,
    this.stock,
    this.status,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'category': category,
    'price': price,
    'stock': stock,
    'status': status,
  };

  static InventoryItem fromJson(Map<String, dynamic> json) => InventoryItem(
    json['name'],
    json['sku'],
    json['category'],
    (json['price'] as num).toDouble(),
    json['stock'],
    json['status'],
  );
}