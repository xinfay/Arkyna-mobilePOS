import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/order_model.dart';
import '../backend/database_helper.dart';
import 'package:intl/intl.dart';


class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final DateFormat _timestampFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<TransactionProvider>().loadTransactionsFromDB();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(provider),
            const SizedBox(height: 16),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('No transactions found.'))
                  : ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return ListTile(
                          leading: Text(tx.id),
                          title: Text('${tx.items.length} items • \$${tx.total.toStringAsFixed(2)}'),
                          subtitle: Text(_timestampFormat.format(tx.timestamp)),
                          trailing: Text(tx.status),
                          onTap: () => _showTransactionDetail(context, tx),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(TransactionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search by ID or item name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: provider.updateSearch,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            DropdownButton<String>(
              value: provider.selectedMethod,
              onChanged: provider.updatePaymentMethod,
              items: ['All', 'Cash', 'Card']
                  .map((method) =>
                      DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: provider.selectedStatus,
              onChanged: provider.updateStatus,
              items: ['All', 'Completed', 'Refunded']
                  .map((status) =>
                      DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }

  void _showTransactionDetail(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Transaction ${order.id}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🕒 ${_timestampFormat.format(order.timestamp)}'),
                const SizedBox(height: 8),
                Text('🧾 Items:', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${item.quantity} × ${item.name} = \$${(item.quantity * item.price).toStringAsFixed(2)}',
                      ),
                    )),
                const Divider(),
                Text('Subtotal: \$${order.subtotal.toStringAsFixed(2)}'),
                Text('Tax: \$${order.tax.toStringAsFixed(2)}'),
                Text('Tip: \$${order.tip.toStringAsFixed(2)}'),
                Text('Total: \$${order.total.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Payment Method: ${order.paymentMethod}'),
                Text('Status: ${order.status}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}