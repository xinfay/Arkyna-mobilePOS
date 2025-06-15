import 'package:flutter/material.dart';
import '../backend/database_helper.dart';
import '../providers/inventory_helper.dart';
import '../models/order_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'dart:math';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> _kpiDataFuture;

  @override
  void initState() {
    super.initState();
    _kpiDataFuture = _loadKpiData();
  }

  Future<Map<String, dynamic>> _loadKpiData() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Transactions
    final transactions = await DatabaseHelper.instance.getTransactionsSince(startOfDay);
    final totalRevenue = transactions.fold<double>(0, (sum, t) => sum + t.total);
    final transactionCount = transactions.length;

    // Inventory
    final items = await InventoryHelper.getAllInventoryItems();
    final activeItems = await InventoryHelper.getActiveItemCount();
    final lowStockItems = await InventoryHelper.getLowStockItemCount();

    return {
      'totalRevenue': totalRevenue,
      'transactionCount': transactionCount,
      'activeItems': activeItems,
      'lowStockAlerts': lowStockItems,
    };
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    String? subtitle,
    Color? valueColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 28, color: iconColor ?? Colors.black54),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, color: valueColor ?? Colors.black)),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ),
        ],
      ),
    );
  }

  Future<Map<String, double>> _getRevenueByWeekday() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday

    Map<String, double> revenueByDay = {
      'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0,
      'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0,
    };

    final allOrders = await DatabaseHelper.instance.getTransactionsSince(startOfWeek);

    for (final order in allOrders) {
      final weekday = order.timestamp.weekday; // 1 = Monday
      final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
      revenueByDay[label] = revenueByDay[label]! + order.total;
    }

    return revenueByDay;
  }

  Widget _buildSalesOverviewChart(Map<String, double> revenueData) {
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = revenueData.values.reduce(max);

    double getInterval(double maxY) {
      if (maxY <= 20) return 5;
      if (maxY <= 100) return 10;
      if (maxY <= 500) return 50;
      if (maxY <= 1000) return 100;
      return 500;
    }

    final interval = getInterval(maxY);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sales Overview', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY * 1.1, // Add a little headroom
                  barGroups: List.generate(7, (index) {
                    final label = dayLabels[index];
                    final value = double.parse(revenueData[label]!.toStringAsFixed(2));
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          width: 18,
                          color: const Color(0xFFE76F51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= dayLabels.length) return const SizedBox();
                          return Text(dayLabels[index], style: const TextStyle(fontSize: 12));
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        getTitlesWidget: (value, _) {
                          return Text('\$${value.toInt()}', style: const TextStyle(fontSize: 12));
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSalesList(List<Order> orders) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Recent Sales", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...orders.map((order) {
              final label = order.paymentMethod == 'Delivery'
                  ? 'Delivery'
                  : (order.paymentMethod == 'To-Go' ? 'To-Go Order' : 'Table Order');

              final initials = label.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
              final totalItems = order.items.fold<int>(0, (sum, i) => sum + i.quantity);
              final total = order.total.toStringAsFixed(2);

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 18,
                  child: Text(initials),
                ),
                title: Text(label),
                subtitle: Text('$totalItems item${totalItems > 1 ? 's' : ''}'),
                trailing: Text("+\$$total", style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }),
          ],
        ),
      ),
    );
  }

  
  Widget _buildInventoryStatusChart(Map<String, int> data) {
    print("Raw inventory data received by chart: $data");

    final chartData = data.map((key, value) => MapEntry(key, value.toDouble()));

    print("Converted chartData for PieChart: $chartData");

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Inventory Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            pie.PieChart(
              dataMap: chartData,
              chartType: pie.ChartType.ring,
              ringStrokeWidth: 24,
              chartRadius: 120,
              colorList: [
                Colors.green,
                Colors.orange,
                Colors.red,
              ],
              legendOptions: const pie.LegendOptions(
                showLegends: true,
                legendPosition: pie.LegendPosition.right,
              ),
              chartValuesOptions: const pie.ChartValuesOptions(
                showChartValuesInPercentage: true,
                decimalPlaces: 0,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingItems(Map<String, Map<String, dynamic>> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Top Selling Items", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.entries.map((entry) {
              final name = entry.key;
              final sold = entry.value['sold'];
              final revenue = (entry.value['revenue'] as num).toDouble().toStringAsFixed(2);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14)),
                    Text("\$$revenue", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

                const SizedBox(height: 16), // ⬅️ Add a bit of spacing after title

              FutureBuilder<Map<String, dynamic>>(
                future: _loadKpiData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildKpiCard(
                        title: "Total Revenue (Today)",
                        value: "\$${data['totalRevenue'].toStringAsFixed(2)}",
                        subtitle: "+x% from yesterday",
                        icon: Icons.attach_money,
                        valueColor: Colors.green,
                      ),
                      _buildKpiCard(
                        title: "Transactions (Today)",
                        value: "+${data['transactionCount']}",
                        subtitle: "+x% from yesterday",
                        icon: Icons.receipt_long,
                        iconColor: Colors.blue,
                      ),
                      _buildKpiCard(
                        title: "Active Items",
                        value: "${data['activeItems']}",
                        subtitle: "In stock",
                        icon: Icons.inventory_2,
                        iconColor: Colors.orange,
                      ),
                      _buildKpiCard(
                        title: "Inventory Alerts",
                        value: "${data['lowStockAlerts']}",
                        subtitle: "Need restocking",
                        icon: Icons.warning,
                        valueColor: Colors.red,
                        iconColor: Colors.red,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
              FutureBuilder<Map<String, double>>(
                future: _getRevenueByWeekday(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildSalesOverviewChart(snapshot.data!);
                },
              ),

              const SizedBox(height: 24),

              // STEP 4 & 5: Recent Sales and Inventory Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FutureBuilder<List<Order>>(
                      future: DatabaseHelper.instance.getRecentOrders(limit: 6),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return _buildRecentSalesList(snapshot.data!);
                      },
                    ),
                  ),
                  const SizedBox(width: 16), // Adds spacing between the two columns
                  Expanded(
                    child: FutureBuilder<Map<String, int>>(
                      future: InventoryHelper.getInventoryStatusBreakdown(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return _buildInventoryStatusChart(snapshot.data!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // STEP 6: Top Selling Items
              // _buildTopSellingItems(),
              FutureBuilder<Map<String, Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getTopSellingItems(limit: 6),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildTopSellingItems(snapshot.data!);
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}