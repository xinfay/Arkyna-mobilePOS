import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../providers/analytics_service.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesTab extends StatefulWidget {
  const SalesTab({super.key});

  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  List<Order> orders = [];
  double totalRevenue = 0.0;
  double averageOrderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final data = await AnalyticsService.getOrders();
    final revenue = data.fold(0.0, (sum, order) => sum + order.total);
    final avgOrder = data.isNotEmpty ? revenue / data.length : 0.0;

    setState(() {
      orders = data;
      totalRevenue = revenue;
      averageOrderValue = avgOrder;
    });
  }

  Widget _buildMetric(String label, String value, [String? subtext]) {
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
          if (subtext != null)
            Text(subtext, style: const TextStyle(fontSize: 12, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildHourlyBarChart() {
    final hourlyRevenue = _getHourlyRevenue();

    if (hourlyRevenue.isEmpty) {
      return const Text("No hourly sales data yet");
    }

    final sortedKeys = hourlyRevenue.keys.toList()..sort();
    final maxRevenue = hourlyRevenue.values.fold<double>(0.0, (max, val) => val > max ? val : max);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "\$${rod.toY.toStringAsFixed(2)}",
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text("\$${value.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10));
                },
                reservedSize: 36,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final hour = value.toInt();
                  return Text(
                    hour < 12 ? '$hour AM' : (hour == 12 ? '12 PM' : '${hour - 12} PM'),
                    style: const TextStyle(fontSize: 10),
                  );
                },
                reservedSize: 28,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: sortedKeys.map((hour) {
            final value = hourlyRevenue[hour]!;
            return BarChartGroupData(
              x: hour,
              barRods: [
                BarChartRodData(
                  toY: value,
                  width: 14,
                  color: Colors.blueAccent,
                ),
              ],
            );
          }).toList(),
          maxY: maxRevenue + 10,
        ),
      ),
    );
  }

  Map<int, double> _getHourlyRevenue() {
    final Map<int, double> hourlyTotals = {};

    for (final order in orders) {
      final hour = order.timestamp.hour;
      hourlyTotals[hour] = (hourlyTotals[hour] ?? 0) + order.total;
    }

    return hourlyTotals;
  }

  Map<String, double> _getRevenueByWeekday() {
    final Map<String, double> revenuePerDay = {
      'Mon': 0.0,
      'Tue': 0.0,
      'Wed': 0.0,
      'Thu': 0.0,
      'Fri': 0.0,
      'Sat': 0.0,
      'Sun': 0.0,
    };

    for (final order in orders) {
      final weekday = order.timestamp.weekday; // 1 = Mon, 7 = Sun
      final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
      revenuePerDay[label] = (revenuePerDay[label] ?? 0) + order.total;
    }

    return revenuePerDay;
  }

  Widget _buildWeeklyLineChart() {
    final data = _getRevenueByWeekday();
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = data.values.fold(0.0, (prev, curr) => curr > prev ? curr : prev);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text("\$${value.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10));
                },
                reservedSize: 36,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // show only one per tick
                getTitlesWidget: (value, meta) {
                  const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final index = value.toInt();
                  if (index >= 0 && index < dayLabels.length) {
                    return Text(dayLabels[index], style: const TextStyle(fontSize: 10));
                  }
                  return const SizedBox.shrink(); // hide out-of-bounds
                },
                reservedSize: 28,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: FlDotData(show: true),
              spots: List.generate(7, (i) {
                final label = dayLabels[i];
                return FlSpot(i.toDouble(), data[label]!);
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<int, double>> _getTopRevenueHours({int count = 3}) {
    final hourly = _getHourlyRevenue();
    final sorted = hourly.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Descending
    return sorted.take(count).toList();
  }

  Widget _buildTopHoursList() {
    final topHours = _getTopRevenueHours();

    if (topHours.isEmpty) return const Text("No sales yet.");

    return Column(
      children: topHours.map((entry) {
        final hour = entry.key;
        final revenue = entry.value;

        final label = hour < 12
            ? '$hour AM'
            : hour == 12
                ? '12 PM'
                : '${hour - 12} PM';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text("\$${revenue.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: orders.isEmpty
          ? const Center(child: Text("No orders yet"))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildMetric("Total Revenue", "\$${totalRevenue.toStringAsFixed(2)}"),
                    _buildMetric("Transactions", "${orders.length}"),
                    _buildMetric("Average Order", "\$${averageOrderValue.toStringAsFixed(2)}"),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("Hourly Sales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildHourlyBarChart(),
                const SizedBox(height: 32),
                const Text("Weekly Performance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildWeeklyLineChart(),
                const SizedBox(height: 32),
                const Text("Top Sales Hours", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildTopHoursList(),
              ],
            ),
    );
  }
}