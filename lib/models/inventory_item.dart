class InventoryItem {
  final String name;
  final String sku;
  final String category;
  final double price;
  final int stock;
  final String status;
  final int minStock;
  final String supplier;

  InventoryItem({
    required this.name,
    this.sku = '',
    this.category = 'Inventory',
    this.price = 0.0,
    this.stock = 0,
    this.status = 'active',
    this.minStock = 0,
    this.supplier = '',
  });

  InventoryItem copyWith({
    String? name,
    String? sku,
    String? category,
    double? price,
    int? stock,
    String? status,
    int? minStock,
    String? supplier,
  }) {
    return InventoryItem(
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      minStock: minStock ?? this.minStock,
      supplier: supplier ?? this.supplier,
    );
  }

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
        name: json['name'],
        sku: json['sku'],
        category: json['category'],
        price: (json['price'] as num).toDouble(),
        stock: json['stock'],
        status: json['status'],
        minStock: json['minStock'] ?? 0,
        supplier: json['supplier'] ?? '',
      );
}