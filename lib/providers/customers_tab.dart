import 'package:flutter/material.dart';
import 'analytics_service.dart';

class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  int totalCustomers = 0;
  double avgTransaction = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    final orders = await AnalyticsService.getOrders();
    final revenue = orders.fold(0.0, (sum, order) => sum + order.total);

    setState(() {
      totalCustomers = orders.length;
      avgTransaction = orders.isNotEmpty ? revenue / orders.length : 0.0;
    });
  }

  Widget _buildMetric(String label, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetric("Total Customers", "$totalCustomers", "+${totalCustomers > 0 ? 1 : 0} this week"),
              _buildMetric("Avg. Transaction", "\$${avgTransaction.toStringAsFixed(2)}", "Per customer"),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Customer Demographics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Customer demographic visualization will appear here", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
