import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory_item.dart'; // Assuming you have an InventoryItem model

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();

  // @override
  // Widget build(BuildContext context) {
  //   return Center(
  //     child: Text(
  //       'Inventory - Coming Soon',
  //       style: TextStyle(fontSize: 24, color: Colors.grey),
  //     ),
  //   );
  // }
}

class _InventoryPageState extends State<InventoryPage> {
  int inventoryState = 0;

  List<InventoryItem> inventoryItems = [];

  Set<String> selectedCategories = {'Ingredients', 'Supplies', 'Bakery', 'Drinks', 'Food'};
  Set<String> selectedStatuses = {'In Stock', 'Low Stock', 'Out of Stock'};

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> saveInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final itemList = inventoryItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('inventory_items', itemList);
  }

  Future<void> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final itemList = prefs.getStringList('inventory_items');
    if (itemList != null) {
      setState(() {
        inventoryItems = itemList
            .map((item) => InventoryItem.fromJson(jsonDecode(item)))
            .toList();
      });
    } else {
      // Default items if nothing is saved
      setState(() {
        inventoryItems = [
          InventoryItem('Coffee Beans', 'CB-001', 'Ingredients', 12.99, 45, 'In Stock', 10, 'Supplier A'),
          InventoryItem('Whole Milk', 'WM-001', 'Ingredients', 4.99, 12, 'Low Stock', 15, 'Supplier B'),
          InventoryItem('Sandwich Bread', 'SB-001', 'Ingredients', 4.50, 0, 'Out of Stock', 15, 'Local Bakery'),
        ];
      });
    }
  }

  void _inventoryHelper(int toggle) {
    setState(() {
      inventoryState = toggle;
    });
  }

  int _countLowStock() {
    return inventoryItems
        .where((item) => item.status == "Low Stock" || item.status == "Out of Stock")
        .length;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ...['Ingredients', 'Supplies', 'Bakery', 'Drinks', 'Food'].map((cat) => CheckboxListTile(
                          value: selectedCategories.contains(cat),
                          title: Text(cat),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                selectedCategories.add(cat);
                              } else {
                                selectedCategories.remove(cat);
                              }
                            });
                            setState(() {});
                          },
                        )),
                    const Divider(),
                    const Text('Stock Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ...['In Stock', 'Low Stock', 'Out of Stock'].map((status) => CheckboxListTile(
                          value: selectedStatuses.contains(status),
                          title: Text(status),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                selectedStatuses.add(status);
                              } else {
                                selectedStatuses.remove(status);
                              }
                            });
                            setState(() {});
                          },
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<InventoryItem> get filteredItems => inventoryItems.where((item) =>
    selectedCategories.contains(item.category) &&
    selectedStatuses.contains(item.status)
  ).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inventory Title
                const Text(
                  'Inventory',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Tabs Row
                Row(
                  children: [
                    // All Items Button
                    ElevatedButton(
                      onPressed: () => _inventoryHelper(0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(130, 48),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                      ),
                      child: const Text('All Items'),
                    ),
                    const SizedBox(width: 8),

                    // Low Stock Button with badge
                    ElevatedButton(
                      onPressed: () => _inventoryHelper(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(130, 48),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Low Stock'),
                          const SizedBox(width: 8),
                          Container(
                            height: 28, // Match badge height to button
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_countLowStock()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Item Bundles Button
                    ElevatedButton(
                      onPressed: () => _inventoryHelper(2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(130, 48),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                      ),
                      child: const Text('Item Bundles'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search, Filter, Add Item Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Ensures children are centered vertically
                  children: [
                    // Search Bar
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search inventory...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16), // Increase vertical padding
                          isDense: true, // Makes the TextField more compact
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Filter Button
                    OutlinedButton.icon(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list_alt),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Add Item Button
                    ElevatedButton.icon(
                      onPressed: () {
                        String? newName;
                        String? newSku;
                        String? newCategory;
                        double? newPrice;
                        int? newStock;
                        String? newStatus;
                        int? newMinStock;
                        String? newSupplier;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Add New Item'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                    ),
                                    onChanged: (value) => newName = value,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'SKU',
                                    ),
                                    onChanged: (value) => newSku = value,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
                                    onChanged: (value) => newCategory = value,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Price',
                                      prefixText: '\$',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (value) =>
                                        newPrice = double.tryParse(value),
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Stock',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: false),
                                    onChanged: (value) =>
                                        newStock = int.tryParse(value),
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Minimum Stock',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: false),
                                    onChanged: (value) =>
                                        newMinStock = int.tryParse(value),
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Supplier',
                                    ),
                                    onChanged: (value) => newSupplier = value,
                                  ),
                                  DropdownButtonFormField<String>(
                                    decoration:
                                        const InputDecoration(labelText: 'Status'),
                                    items: [
                                      'In Stock',
                                      'Low Stock',
                                      'Out of Stock'
                                    ]
                                        .map((status) => DropdownMenuItem<String>(
                                              value: status,
                                              child: Text(status),
                                            ))
                                        .toList(),
                                    onChanged: (value) => newStatus = value,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (newName != null &&
                                        newSku != null &&
                                        newCategory != null &&
                                        newPrice != null &&
                                        newStock != null &&
                                        newStatus != null &&
                                        newMinStock != null &&
                                        newSupplier != null) {
                                      setState(() {
                                        inventoryItems.add(InventoryItem(newName!, newSku!,
                                            newCategory!, newPrice!, newStock!, newStatus!, newMinStock!, newSupplier!));
                                      });
                                      await saveInventory();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Add Item'),
                                ),
                              ],
                            );
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Flexible(flex: 6, child: _buildInventoryState())
      ],
    );
  }

  Widget _buildInventoryState() {
    switch (inventoryState) {
      case 0: // all items
        return _buildAllItems(inventoryItems);

      case 1: // low stock
         return _buildLowStock(inventoryItems);
      case 2: // item bundles
         return _buildItemBundles(inventoryItems);
      default:
        return _buildAllItems(inventoryItems); // same as case 0
    }
  }

  Widget _buildItemBundles(List<InventoryItem> items) {
    // Placeholder for item bundles logic
    return const Center(
      child: Text(
        'Item Bundles - Coming Soon',
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
    );
  }

  Widget _buildLowStock(List<InventoryItem> items) {
    final lowStockItems = items
        .where((item) => item.status == 'Low Stock' || item.status == 'Out of Stock')
        .toList();

    if (lowStockItems.isEmpty) {
      return const Center(
        child: Text('No low stock items found.',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }
    else {
          final displayItems = filteredItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: const [
              Expanded(
                  flex: 2,
                  child: Text('Name',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('SKU',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Category',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Current Stock',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Min Stock',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Supplier',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Actions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(),
        // Table rows
        ...displayItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(item.name)),
                  Expanded(child: Text(item.sku)),
                  Expanded(child: Text(item.category)),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.stock == 0 ? Colors.red : const Color.fromARGB(255, 244, 241, 241),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.stock.toString(),
                          style: TextStyle(
                            color: item.stock == 0 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),                  Expanded(child: Text(item.minStock.toString())),
                  Expanded(child: Text(item.supplier)),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Handle edit action
                        showDialog(
                          context: context,
                          builder: (context) {
                            String? editedName = item.name;
                            String? editedSku = item.sku;
                            String? editedCategory = item.category;
                            double? editedPrice = item.price;
                            int? editedStock = item.stock;
                            String? editedStatus = item.status;
                            int? editedMinStock = item.minStock;
                            String? editedSupplier = item.supplier;

                            return AlertDialog(
                              title: const Text('Edit Item'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                    ),
                                    initialValue: item.name,
                                    onChanged: (value) => editedName = value,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'SKU',
                                    ),
                                    initialValue: item.sku,
                                    onChanged: (value) => editedSku = value,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
                                    initialValue: item.category,
                                    onChanged: (value) => editedCategory = value,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Price',
                                      prefixText: '\$',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: true),
                                    initialValue:
                                        item.price.toStringAsFixed(2),
                                    onChanged: (value) =>
                                        editedPrice = double.tryParse(value),
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Stock',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: false),
                                    initialValue: item.stock.toString(),
                                    onChanged: (value) =>
                                        editedStock = int.tryParse(value),
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Minimum Stock',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: false),
                                    initialValue: item.minStock.toString(),
                                    onChanged: (value) =>
                                        editedMinStock = int.tryParse(value),
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Supplier',
                                    ),
                                    initialValue: item.supplier,
                                    onChanged: (value) => editedSupplier = value,
                                  ),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Status'),
                                    value: item.status,
                                    items: [
                                      'In Stock',
                                      'Low Stock',
                                      'Out of Stock'
                                    ]
                                        .map((status) => DropdownMenuItem<String>(
                                              value: status,
                                              child: Text(status),
                                            ))
                                        .toList(),
                                    onChanged: (value) => editedStatus = value,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (editedName != null &&
                                        editedSku != null &&
                                        editedCategory != null &&
                                        editedPrice != null &&
                                        editedStock != null &&
                                        editedStatus != null &&
                                        editedMinStock != null &&
                                        editedSupplier != null) {
                                      setState(() {
                                        item.name = editedName!;
                                        item.sku = editedSku!;
                                        item.category = editedCategory!;
                                        item.price = editedPrice!;
                                        item.stock = editedStock!;
                                        item.status = editedStatus!;
                                        item.minStock = editedMinStock!;
                                        item.supplier = editedSupplier!;
                                      });
                                      await saveInventory();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Save Changes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
    }

    return _buildAllItems(lowStockItems);
  }

  Widget _buildAllItems(List<InventoryItem> items) {
    final displayItems = filteredItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: const [
              Expanded(
                  flex: 2,
                  child: Text('Name',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('SKU',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Category',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Price',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Stock',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Status',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Actions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(),
        // Table rows
        ...displayItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(item.name)),
                  Expanded(child: Text(item.sku)),
                  Expanded(child: Text(item.category)),
                  Expanded(child: Text('\$${item.price.toStringAsFixed(2)}')),
                  Expanded(child: Text(item.stock.toString())),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.status == 'In Stock'
                            ? Colors.green[100]
                            : item.status == 'Low Stock'
                                ? Colors.yellow[100]
                                : item.status == 'Out of Stock'
                                    ? Colors.red[300]
                                    : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item.status,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Handle edit action
                        showDialog(
                          context: context,
                          builder: (context) {
                            String? editedName = item.name;
                            String? editedSku = item.sku;
                            String? editedCategory = item.category;
                            double? editedPrice = item.price;
                            int? editedStock = item.stock;
                            String? editedStatus = item.status;
                            int? editedMinStock = item.minStock;
                            String? editedSupplier = item.supplier;

                            return AlertDialog(
                              title: const Text('Edit Item'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                    ),
                                    initialValue: item.name,
                                    onChanged: (value) => editedName = value,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'SKU',
                                    ),
                                    initialValue: item.sku,
                                    onChanged: (value) => editedSku = value,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
                                    initialValue: item.category,
                                    onChanged: (value) => editedCategory = value,
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Price',
                                      prefixText: '\$',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: true),
                                    initialValue:
                                        item.price.toStringAsFixed(2),
                                    onChanged: (value) =>
                                        editedPrice = double.tryParse(value),
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Stock',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: false),
                                    initialValue: item.stock.toString(),
                                    onChanged: (value) =>
                                        editedStock = int.tryParse(value),
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Minimum Stock',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(decimal: false),
                                    initialValue: item.minStock.toString(),
                                    onChanged: (value) =>
                                        editedMinStock = int.tryParse(value),
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Supplier',
                                    ),
                                    initialValue: item.supplier,
                                    onChanged: (value) => editedSupplier = value,
                                  ),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Status'),
                                    value: item.status,
                                    items: [
                                      'In Stock',
                                      'Low Stock',
                                      'Out of Stock'
                                    ]
                                        .map((status) => DropdownMenuItem<String>(
                                              value: status,
                                              child: Text(status),
                                            ))
                                        .toList(),
                                    onChanged: (value) => editedStatus = value,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (editedName != null &&
                                        editedSku != null &&
                                        editedCategory != null &&
                                        editedPrice != null &&
                                        editedStock != null &&
                                        editedStatus != null &&
                                        editedMinStock != null &&
                                        editedSupplier != null) {
                                      setState(() {
                                        item.name = editedName!;
                                        item.sku = editedSku!;
                                        item.category = editedCategory!;
                                        item.price = editedPrice!;
                                        item.stock = editedStock!;
                                        item.status = editedStatus!;
                                        item.minStock = editedMinStock!;
                                        item.supplier = editedSupplier!;
                                      });
                                      await saveInventory();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Save Changes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
