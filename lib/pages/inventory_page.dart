import 'package:flutter/material.dart';
import '../providers/inventory_helper.dart';
import '../models/inventory_item.dart';
import '../models/inventory_bundle.dart';
import '../models/checkout_catalog.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InventoryItem> _inventoryItems = [];
  List<InventoryBundle> _bundleItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInventoryFromDB();
    _loadBundleItems();
  }

  Future<void> _loadInventoryFromDB() async {
    final items = await InventoryHelper.getAllInventoryItems();
    setState(() {
      _inventoryItems = items;
    });
  }

  void _loadBundleItems() async {
    final loaded = await InventoryHelper.getAllBundles(); // you’d implement this
    setState(() {
      _bundleItems = loaded;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final stockController = TextEditingController();
    final minStockController = TextEditingController();

    final skuController = TextEditingController();
    final priceController = TextEditingController();

    String category = 'Ingredients'; // default
    bool showAdvancedFields = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Inventory Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: minStockController,
                    decoration: const InputDecoration(labelText: 'Min Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  TextButton(
                    onPressed: () => setState(() => showAdvancedFields = !showAdvancedFields),
                    child: Text(showAdvancedFields ? "Hide Advanced" : "More Options"),
                  ),
                  if (showAdvancedFields) ...[
                    TextField(
                      controller: skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Ingredients', 'Supplies', 'Bakery', 'Other'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) => setState(() => category = value!),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final stock = int.tryParse(stockController.text.trim()) ?? 0;
                  final minStock = int.tryParse(minStockController.text.trim()) ?? 0;

                  if (stock < 0 || minStock < 0) {
                    _showErrorDialog("Stock and Min Stock cannot be negative.");
                    return;
                  }

                  final newItem = InventoryItem(
                    name: nameController.text.trim(),
                    sku: skuController.text.trim(),
                    category: category,
                    price: double.tryParse(priceController.text.trim()) ?? 0.0,
                    stock: stock,
                    status: 'active',
                    minStock: minStock,
                    supplier: '',
                  );

                  try {
                    await InventoryHelper.insertInventoryItem(newItem);
                    Navigator.pop(context);
                    _loadInventoryFromDB();
                  } on DuplicateNameException catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog(e.message);
                  } catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog('Unexpected error occurred: $e');
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDeleteDialog(InventoryItem item) {
    final nameController = TextEditingController(text: item.name);
    final stockController = TextEditingController(text: item.stock.toString());
    final minStockController = TextEditingController(text: item.minStock.toString());

    final skuController = TextEditingController(text: item.sku);
    final priceController = TextEditingController(text: item.price.toStringAsFixed(2));
    String category = item.category;

    bool showAdvancedFields = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Edit Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: minStockController,
                    decoration: const InputDecoration(labelText: 'Min Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  TextButton(
                    onPressed: () => setState(() => showAdvancedFields = !showAdvancedFields),
                    child: Text(showAdvancedFields ? "Hide Advanced" : "More Options"),
                  ),
                  if (showAdvancedFields) ...[
                    TextField(
                      controller: skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Inventory', 'Ingredients', 'Supplies', 'Other'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) => setState(() => category = value!),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await InventoryHelper.deleteInventoryItemByName(item.name);
                  Navigator.pop(context);
                  _loadInventoryFromDB();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final stock = int.tryParse(stockController.text.trim()) ?? 0;
                  final minStock = int.tryParse(minStockController.text.trim()) ?? 0;

                  if (stock < 0 || minStock < 0) {
                    _showErrorDialog("Stock and Min Stock cannot be negative.");
                    return;
                  }

                  final newItem = InventoryItem(
                    name: nameController.text.trim(),
                    sku: skuController.text.trim(),
                    category: category,
                    price: double.tryParse(priceController.text.trim()) ?? 0.0,
                    stock: stock,
                    status: 'active',
                    minStock: minStock,
                    supplier: '',
                  );

                  try {
                    await InventoryHelper.updateInventoryItemByName(newItem);
                    Navigator.pop(context);
                    _loadInventoryFromDB();
                  } on DuplicateNameException catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog(e.message);
                  } catch (e) {
                    Navigator.pop(context);
                    _showErrorDialog('Unexpected error occurred: $e');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Items'),
            Tab(text: 'Low Stock'),
            Tab(text: 'Item Bundles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllItemsTab(),
          _buildLowStockTab(),
          _buildItemBundlesTab(),
        ],
      ),

      // 👇 Add this line for the "+" button
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getStockStatus(InventoryItem item) {
    if (item.stock == 0) return 'Out of Stock';
    if (item.stock <= item.minStock) return 'Low Stock';
    return 'In Stock';
  }

  Widget _buildStatusBadge(String status) {
    Color color;

    switch (status) {
      case 'Out of Stock':
        color = Colors.red;
        break;
      case 'Low Stock':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

  Widget _buildAllItemsTab() {
    if (_inventoryItems.isEmpty) {
      return const Center(child: Text("No items in inventory."));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Inventory Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Status')),
            DataColumn(label: SizedBox.shrink()),
          ],
          rows: _inventoryItems.map((item) {
            final status = _getStockStatus(item);

            return DataRow(cells: [
              DataCell(Text(item.name)),
              DataCell(Text(item.sku)),
              DataCell(Text(item.category)),
              DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
              DataCell(Text(item.stock.toString())),
              DataCell(_buildStatusBadge(status)),
              DataCell(
                ElevatedButton(
                  onPressed: () => _showEditDeleteDialog(item),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Edit'),
                ),
              ),
            ]);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStockBubble(int stock, int minStock) {
    late Color bgColor;
    late Color textColor;

    if (stock == 0) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red;
    } else {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        stock.toString(),
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildLowStockTab() {
    final lowStockItems = _inventoryItems.where((item) {
      return item.stock <= item.minStock;
    }).toList();

    if (lowStockItems.isEmpty) {
      return const Center(child: Text("No low stock items."));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Low Stock Alerts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Text(
          "Items that need to be restocked soon",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        DataTable(
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Current Stock')),
            DataColumn(label: Text('Min Stock')),
            DataColumn(label: Text('Supplier')),
            DataColumn(label: SizedBox.shrink()), // Order button column
          ],
          rows: lowStockItems.map((item) {
            return DataRow(cells: [
              DataCell(Text(item.name)),
              DataCell(Text(item.sku)),
              DataCell(Text(item.category)),
              DataCell(_buildStockBubble(item.stock, item.minStock)),
              DataCell(Text(item.minStock.toString())),
              DataCell(Text(item.supplier)),
              DataCell(
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ordering ${item.name}...")),
                    );
                  },
                  icon: const Icon(Icons.local_grocery_store_outlined, size: 16),
                  label: const Text('Order'),
                )
              ),
            ]);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBundleStatusBadge(String status) {
    Color color;

    switch (status) {
      case 'Missing Items':
        color = Colors.red;
        break;
      case 'Low Stock':
        color = Colors.orange;
        break;
      case 'Ready':
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showBundleDetailsDialog(InventoryBundle bundle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bundle.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SKU: ${bundle.sku}'),
            const SizedBox(height: 8),
            Text('Sale Price: \$${bundle.salePrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('Included Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...bundle.ingredients.map((ingredient) => Text(
                '- ${ingredient.inventoryItemName} x${ingredient.quantityUsed}')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }


  void _showCreateBundleDialog() {
    String? selectedCheckoutItem;
    List<String?> selectedIngredients = [null]; // at least one row
    List<TextEditingController> quantityControllers = [TextEditingController()];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Create Item Bundle"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [           
                  DropdownButtonFormField<String>(
                    value: selectedCheckoutItem,
                    decoration: const InputDecoration(labelText: "Checkout Item"),
                    items: checkoutLabels.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.name,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCheckoutItem = val),
                  ),
                  const SizedBox(height: 16),
                  const Text("Ingredients"),
                  ...List.generate(selectedIngredients.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedIngredients[index],
                            decoration: const InputDecoration(labelText: "Ingredient"),
                            items: _inventoryItems.map((item) {
                              return DropdownMenuItem(
                                value: item.name,
                                child: Text(item.name),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => selectedIngredients[index] = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: quantityControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Qty"),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          onPressed: () {
                            setState(() {
                              selectedIngredients.removeAt(index);
                              quantityControllers.removeAt(index);
                            });
                          },
                        )
                      ],
                    );
                  }),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedIngredients.add(null);
                        quantityControllers.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Ingredient"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCheckoutItem == null) {
                    _showErrorDialog("Select a checkout item.");
                    return;
                  }

                  for (int i = 0; i < selectedIngredients.length; i++) {
                    final ingredient = selectedIngredients[i];
                    final qty = int.tryParse(quantityControllers[i].text);
                    if (ingredient == null || qty == null || qty <= 0) {
                      _showErrorDialog("Please fill all ingredients with valid quantities.");
                      return;
                    }
                  }

                  // Save each ingredient mapping
                  for (int i = 0; i < selectedIngredients.length; i++) {
                    await InventoryHelper.insertBundleItem(
                      checkoutItem: selectedCheckoutItem!,
                      ingredientName: selectedIngredients[i]!,
                      quantityUsed: int.parse(quantityControllers[i].text),
                    );
                  }

                  Navigator.pop(context);
                  _loadBundleItems(); // refresh
                },
                child: const Text("Save Bundle"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemBundlesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Bundled Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Text(
          "Manage your product bundles with related ingredients",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showCreateBundleDialog,
          icon: const Icon(Icons.add),
          label: const Text("Create New Bundle"),
        ),
        const SizedBox(height: 16),

        if (_bundleItems.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: Text("No item bundles defined."),
            ),
          )
        else
          DataTable(
            columnSpacing: 16,
            columns: const [
              DataColumn(label: Text('Bundle Name')),
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Items Included')),
              DataColumn(label: Text('Sale Price')),
              DataColumn(label: Text('Stock Status')),
              DataColumn(label: SizedBox.shrink()), // View button
            ],
            rows: _bundleItems.map((bundle) {
              return DataRow(cells: [
                DataCell(Text(bundle.name)),
                DataCell(Text(bundle.sku)),
                DataCell(Text(bundle.ingredients.join(', '))),
                DataCell(Text('\$${bundle.salePrice.toStringAsFixed(2)}')),
                DataCell(_buildBundleStatusBadge(bundle.status)),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      _showBundleDetailsDialog(bundle);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('View'),
                  ),
                ),
              ]);
            }).toList(),
          ),
      ],
    );
  }
}