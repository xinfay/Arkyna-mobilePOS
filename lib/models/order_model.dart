class Order {
  final String id;
  final DateTime timestamp;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double tip;
  final double total;

  Order({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.tip,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'tip': tip,
        'total': total,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        items: (json['items'] as List<dynamic>)
            .map((e) => OrderItem.fromJson(e))
            .toList(),
        subtotal: (json['subtotal'] as num).toDouble(),
        tax: (json['tax'] as num).toDouble(),
        tip: (json['tip'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
      );
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
      );
}