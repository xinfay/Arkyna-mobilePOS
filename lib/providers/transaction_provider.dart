import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../backend/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<Order> _allTransactions = [];
  List<Order> _filteredTransactions = [];

  String _searchQuery = '';
  String _selectedMethod = 'All';
  String _selectedStatus = 'All'; // Placeholder

  List<Order> get transactions => _filteredTransactions;

  Future<void> loadTransactionsFromDB() async {
    final dbHelper = DatabaseHelper.instance;
    _allTransactions = await dbHelper.getAllOrders();
    _applyFilters();
  }

  void _applyFilters() {
    _filteredTransactions = _allTransactions.where((order) {
      final matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.items.any((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesMethod = _selectedMethod == 'All' || order.paymentMethod == _selectedMethod;
      final matchesStatus = _selectedStatus == 'All' || order.status == _selectedStatus;

      return matchesSearch && matchesMethod && matchesStatus;
    }).toList();

    notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void updatePaymentMethod(String? method) {
    if (method == null) return;
    _selectedMethod = method;
    _applyFilters();
  }

  void updateStatus(String? status) {
    if (status == null) return;
    _selectedStatus = status;
    _applyFilters();
  }

  String get selectedMethod => _selectedMethod;
  String get selectedStatus => _selectedStatus;
}