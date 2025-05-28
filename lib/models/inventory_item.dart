class InventoryItem {
  String name;
  String sku;
  String category;
  double price;
  int stock;
  String status;

  int minStock;
  String supplier;

  InventoryItem(
    this.name,
    this.sku,
    this.category,
    this.price,
    this.stock,
    this.status,
    this.minStock,
    this.supplier,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'category': category,
    'price': price,
    'stock': stock,
    'status': status,
    'minStock': minStock,
    'supplier': supplier,
  };

  static InventoryItem fromJson(Map<String, dynamic> json) => InventoryItem(
    json['name'],
    json['sku'],
    json['category'],
    (json['price'] as num).toDouble(),
    json['stock'],
    json['status'],
    json['minStock'] ?? 0,
    json['supplier'] ?? '',
  );
}