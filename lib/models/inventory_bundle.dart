class InventoryBundle {
  final String name; // Bundle name (e.g., "Burger Combo")
  final String sku;
  final List<BundleIngredient> ingredients;
  final double salePrice;
  final String status; // e.g. "Ready", "Low Stock", "Missing Items"

  InventoryBundle({
    required this.name,
    required this.sku,
    required this.ingredients,
    required this.salePrice,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'salePrice': salePrice,
    'status': status,
  };

  static InventoryBundle fromJson(Map<String, dynamic> json) => InventoryBundle(
    name: json['name'],
    sku: json['sku'],
    ingredients: (json['ingredients'] as List)
        .map((i) => BundleIngredient.fromJson(i))
        .toList(),
    salePrice: (json['salePrice'] as num).toDouble(),
    status: json['status'],
  );
}

class BundleIngredient {
  final String inventoryItemName;
  final int quantityUsed;

  BundleIngredient({
    required this.inventoryItemName,
    required this.quantityUsed,
  });

  Map<String, dynamic> toJson() => {
    'inventoryItemName': inventoryItemName,
    'quantityUsed': quantityUsed,
  };

  static BundleIngredient fromJson(Map<String, dynamic> json) => BundleIngredient(
    inventoryItemName: json['inventoryItemName'],
    quantityUsed: json['quantityUsed'],
  );
}