import 'package:flutter/material.dart';
import '../providers/analytics_service.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  Map<String, ProductStats> productStats = {};

  @override
  void initState() {
    super.initState();
    _loadProductStats();
  }

  Future<void> _loadProductStats() async {
    final orders = await AnalyticsService.getOrders();

    final Map<String, ProductStats> stats = {};

    for (var order in orders) {
      for (var item in order.items) {
        stats[item.name] = stats.putIfAbsent(item.name, () => ProductStats(name: item.name));
        stats[item.name]!.quantitySold += item.quantity;
        stats[item.name]!.revenue += item.quantity * item.price;
      }
    }

    setState(() {
      productStats = stats;
    });
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'trending':
        color = Colors.green;
        break;
      case 'stable':
        color = Colors.blueGrey;
        break;
      case 'declining':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = productStats.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: sorted.isEmpty
          ? const Center(child: Text("No product sales data yet"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Top Selling Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                        children: [
                          Padding(padding: EdgeInsets.all(8), child: Text("Product", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text("Qty Sold", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text("Revenue", style: TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: EdgeInsets.all(8), child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      ...sorted.map((stat) => TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(8), child: Text(stat.name)),
                          Padding(padding: const EdgeInsets.all(8), child: Text("${stat.quantitySold}")),
                          Padding(padding: const EdgeInsets.all(8), child: Text("\$${stat.revenue.toStringAsFixed(2)}")),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildStatusBadge(stat.getStatus()),
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class ProductStats {
  final String name;
  int quantitySold = 0;
  double revenue = 0;

  ProductStats({required this.name});

  String getStatus() {
    if (quantitySold >= 30) return "trending";
    if (quantitySold == 0) return "zero";
    if (quantitySold <= 5) return "declining";
    return "stable";
  }
}