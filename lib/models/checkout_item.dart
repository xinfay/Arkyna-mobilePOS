import '../models/bundled_item.dart';

class CheckoutItem {
  final String name;
  final double price;
  final String? description;

  List<BundledItem>? bundles = [];

  CheckoutItem(
    this.name,
    this.price,
    this.description);
}
