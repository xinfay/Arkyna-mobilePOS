import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory_item.dart';
import '../models/bundled_item.dart';
import '../models/checkout_item.dart';
import 'checkout_page.dart';
import 'dart:collection';

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
  List<BundledItem> itemBundles = [
    BundledItem('Cappuccino', 'CB-001', 4.50)
      ..items = [
        InventoryItem('Coffee Beans', 'CB-001', 'Ingredients', 12.99, 45,
            'In Stock', 10, 'Supplier A'),
        InventoryItem('Whole Milk', 'WM-001', 'Ingredients', 4.99, 12,
            'Low Stock', 15, 'Supplier B'),
  ]
      ..stockStatus = 'In Stock',
    BundledItem('Chicken Sandwich', 'CS-002', 11.00)
      ..items = [
        InventoryItem('Sandwich Bread', 'SB-001', 'Ingredients', 4.50, 0,
            'Out of Stock', 15, 'Local Bakery'),
        InventoryItem('Chicken Breast', 'CB-002', 'Food', 8.99, 20,
              'In Stock', 5, 'Supplier C'),
      ]
      ..stockStatus = 'Low Stock',
  ];



  // List<BundledItem> itemBundles = [
  //   BundledItem('Cappuccino', 'CB-001', 4.50)
  //     ..items = {
  //       InventoryItem('Coffee Beans', 'CB-001', 'Ingredients', 12.99, 45,
  //           'In Stock', 10, 'Supplier A'): 2,
  //       InventoryItem('Whole Milk', 'WM-001', 'Ingredients', 4.99, 12,
  //           'Low Stock', 15, 'Supplier B'): 1,
  //     }
  //     ..stockStatus = 'In Stock',
  //   BundledItem('Bakery Bundle', 'BB-001', 15.99)
  //     ..items = {
  //       InventoryItem('Sandwich Bread', 'SB-001', 'Ingredients', 4.50, 0,
  //           'Out of Stock', 15, 'Local Bakery'): 1,
  //       InventoryItem('Croissant', 'CR-001', 'Bakery', 2.50, 20, 'In Stock', 5,
  //           'Local Bakery'): 3,
  //     }
  //     ..stockStatus = 'Low Stock',
  // ]

  Set<String> selectedCategories = {
    'Ingredients',
    'Supplies',
    'Bakery',
    'Drinks',
    'Food'
  };
  Set<String> selectedStatuses = {'In Stock', 'Low Stock', 'Out of Stock'};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
      itemBundles[0].itemCounts = LinkedHashMap<String, int>.from({
    'Coffee Beans': 2,
    'Whole Milk': 1,
  });
    itemBundles[1].itemCounts = LinkedHashMap<String, int>.from({
      'Sandwich Bread': 2,
      'Chicken Breast': 1,
    });
    loadInventory();
  }

  Future<void> saveInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final itemList =
        inventoryItems.map((item) => jsonEncode(item.toJson())).toList();
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
          InventoryItem('Coffee Beans', 'CB-001', 'Ingredients', 12.99, 45,
              'In Stock', 10, 'Supplier A'),
          InventoryItem('Whole Milk', 'WM-001', 'Ingredients', 4.99, 12,
              'Low Stock', 15, 'Supplier B'),
          InventoryItem('Sandwich Bread', 'SB-001', 'Ingredients', 4.50, 0,
              'Out of Stock', 15, 'Local Bakery'),
          InventoryItem('Chicken Breast', 'CB-002', 'Food', 8.99, 20,
              'In Stock', 5, 'Supplier C'),
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
        .where((item) =>
            item.status == "Low Stock" || item.status == "Out of Stock")
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
                    const Text('Categories',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    ...['Ingredients', 'Supplies', 'Bakery', 'Drinks', 'Food']
                        .map((cat) => CheckboxListTile(
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
                    const Text('Stock Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    ...['In Stock', 'Low Stock', 'Out of Stock']
                        .map((status) => CheckboxListTile(
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

  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    return items
        .where((item) =>
            selectedCategories.contains(item.category) &&
            selectedStatuses.contains(item.status) &&
            (searchQuery.isEmpty ||
                item.name.toLowerCase().contains(searchQuery.toLowerCase())))
        .toList();
  }

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8), // Less rounded
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // All Items Button
                          ElevatedButton(
                            onPressed: () => _inventoryHelper(0),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: inventoryState == 0
                                  ? Colors.white
                                  : Colors.grey[200],
                              foregroundColor: inventoryState == 0
                                  ? Colors.black
                                  : Colors.grey[700],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // All corners same
                              ),
                              minimumSize: const Size(110, 44),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 16),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            child: const Text('All Items'),
                          ),
                          // Low Stock Button with badge
                          ElevatedButton(
                            onPressed: () => _inventoryHelper(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: inventoryState == 1
                                  ? Colors.white
                                  : Colors.grey[200],
                              foregroundColor: inventoryState == 1
                                  ? Colors.black
                                  : Colors.grey[700],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // All corners same
                              ),
                              minimumSize: const Size(110, 44),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 12),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Low Stock'),
                                const SizedBox(width: 6),
                                Container(
                                  height: 28,
                                  constraints:
                                      const BoxConstraints(minWidth: 28),
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    '${_countLowStock()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Item Bundles Button
                          ElevatedButton(
                            onPressed: () => _inventoryHelper(2),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: inventoryState == 2
                                  ? Colors.white
                                  : Colors.grey[200],
                              foregroundColor: inventoryState == 2
                                  ? Colors.black
                                  : Colors.grey[700],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // All corners same
                              ),
                              minimumSize: const Size(110, 44),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 16),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            child: const Text('Item Bundles'),
                          ),
                        ],
                      ),
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
                          hintText: inventoryState == 2
                              ? 'Search item bundles...'
                              : 'Search inventory...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
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
                    if (inventoryState == 0 || inventoryState == 1)
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
                                        onChanged: (value) =>
                                            newCategory = value,
                                      ),
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Price',
                                          prefixText: '\$',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        onChanged: (value) =>
                                            newPrice = double.tryParse(value),
                                      ),
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Stock',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: false),
                                        onChanged: (value) =>
                                            newStock = int.tryParse(value),
                                      ),
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Minimum Stock',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: false),
                                        onChanged: (value) =>
                                            newMinStock = int.tryParse(value),
                                      ),
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Supplier',
                                        ),
                                        onChanged: (value) =>
                                            newSupplier = value,
                                      ),
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                            labelText: 'Status'),
                                        items: [
                                          'In Stock',
                                          'Low Stock',
                                          'Out of Stock'
                                        ]
                                            .map((status) =>
                                                DropdownMenuItem<String>(
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
                                            inventoryItems.add(InventoryItem(
                                                newName!,
                                                newSku!,
                                                newCategory!,
                                                newPrice!,
                                                newStock!,
                                                newStatus!,
                                                newMinStock!,
                                                newSupplier!));
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
                    // Add Bundle Button (only for Item Bundles tab)
                    if (inventoryState == 2) ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          String? selectedBundleName;
                          bool isNewBundle = false;
                          String newName = '';
                          String newSku = '';
                          double? newPrice;
                          List<CheckoutItem> selectedCheckoutItems = [];

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return AlertDialog(
                                    title: const Text('Add Bundle Item'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                                labelText:
                                                    'Select Existing Bundle'),
                                            value: selectedBundleName,
                                            items: [
                                              ...itemBundles
                                                  .map((b) => DropdownMenuItem(
                                                        value: b.name,
                                                        child: Text(b.name),
                                                      )),
                                              const DropdownMenuItem(
                                                value: '__new__',
                                                child: Text('New Bundle'),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              setDialogState(() {
                                                if (val == '__new__') {
                                                  isNewBundle = true;
                                                  selectedBundleName = null;
                                                } else {
                                                  isNewBundle = false;
                                                  selectedBundleName = val;
                                                }
                                              });
                                            },
                                          ),
                                          if (isNewBundle) ...[
                                            TextFormField(
                                              decoration: const InputDecoration(
                                                  labelText: 'Bundle Name'),
                                              onChanged: (val) => newName = val,
                                            ),
                                            TextFormField(
                                              decoration: const InputDecoration(
                                                  labelText: 'SKU'),
                                              onChanged: (val) => newSku = val,
                                            ),
                                            TextFormField(
                                              decoration: const InputDecoration(
                                                  labelText: 'Price'),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              onChanged: (val) => newPrice =
                                                  double.tryParse(val),
                                            ),
                                          ],
                                          const SizedBox(height: 16),
                                          const Text('Add Items to Bundle:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            height:
                                                340, // increased height for a taller dialog
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: GridView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                mainAxisSpacing: 10,
                                                crossAxisSpacing: 10,
                                                childAspectRatio: 2.2,
                                              ),
                                              itemCount: buttonLabels.length -
                                                  1, // Exclude 'Add Item' (last element)
                                              itemBuilder: (context, idx) {
                                                final item = buttonLabels[idx];
                                                final isSelected =
                                                    selectedCheckoutItems
                                                        .contains(item);
                                                return InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  onTap: () {
                                                    setDialogState(() {
                                                      if (isSelected) {
                                                        selectedCheckoutItems
                                                            .remove(item);
                                                      } else {
                                                        selectedCheckoutItems
                                                            .add(item);
                                                      }
                                                    });
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 180),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? Colors.blue[700]
                                                          : Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? Colors.blueAccent
                                                            : Colors.grey[300]!,
                                                        width: isSelected
                                                            ? 2.2
                                                            : 1.2,
                                                      ),
                                                      boxShadow: isSelected
                                                          ? [
                                                              BoxShadow(
                                                                  color: Colors
                                                                      .blue
                                                                      .withOpacity(
                                                                          0.08),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      Offset(
                                                                          0, 2))
                                                            ]
                                                          : [],
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      item.name,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Colors.black87,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Map<String, int> tempCounts = { for (var item in inventoryItems) item.name: 0 };
                                          bool savePressed = false;
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setDialogState) {
                                                  return AlertDialog(
                                                    title: const Text('Select Item Quantities'),
                                                    content: SizedBox(
                                                      width: 400,
                                                      child: ListView(
                                                        shrinkWrap: true,
                                                        children: inventoryItems.map((item) {
                                                          return Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                            child: Row(
                                                              children: [
                                                                Expanded(child: Text(item.name)),
                                                                IconButton(
                                                                  icon: const Icon(Icons.remove_circle_outline),
                                                                  onPressed: () {
                                                                    setDialogState(() {
                                                                      if (tempCounts[item.name]! > 0) {
                                                                        tempCounts[item.name] = tempCounts[item.name]! - 1;
                                                                      }
                                                                    });
                                                                  },
                                                                ),
                                                                Text('${tempCounts[item.name]}'),
                                                                IconButton(
                                                                  icon: const Icon(Icons.add_circle_outline),
                                                                  onPressed: () {
                                                                    setDialogState(() {
                                                                      tempCounts[item.name] = tempCounts[item.name]! + 1;
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          savePressed = true;
                                                          Navigator.of(context).pop(tempCounts);
                                                          Navigator.of(context).pop(); // Close the outer dialog
                                                        },
                                                        child: const Text('Save'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ).then((result) {
                                            if (savePressed && result != null && result is Map<String, int>) {
                                              if (isNewBundle && newName.isNotEmpty && newSku.isNotEmpty && newPrice != null) {
                                                setState(() {
                                                  // Get the list of InventoryItems matching the selected names in itemCounts (with count > 0)
                                                  final selectedItemNames = result.keys.where((k) => result[k]! > 0).toSet();
                                                  final selectedItems = inventoryItems.where((item) => selectedItemNames.contains(item.name)).toList();
                                                  final newBundle = BundledItem(newName, newSku, newPrice!)
                                                    ..checkoutItems = List<CheckoutItem>.from(selectedCheckoutItems)
                                                    ..itemCounts = LinkedHashMap<String, int>.from(
                                                      result..removeWhere((key, value) => value == 0),
                                                    )
                                                    ..items = selectedItems;
                                                  itemBundles.add(newBundle);
                                                });
                                              } else if (!isNewBundle && selectedBundleName != null) {
                                                final bundle = itemBundles.firstWhere((b) => b.name == selectedBundleName);
                                                setState(() {
                                                  bundle.checkoutItems ??= [];
                                                  bundle.checkoutItems!.addAll(selectedCheckoutItems);
                                                  if (bundle.itemCounts == null) {
                                                    bundle.itemCounts = LinkedHashMap<String, int>();
                                                  }
                                                  result.forEach((key, value) {
                                                    if (value > 0) {
                                                      bundle.itemCounts![key] = (bundle.itemCounts![key] ?? 0) + value;
                                                    }
                                                  });
                                                });
                                              }
                                            }
                                          });
                                        },
                                        child: const Text('Next'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.add_box),
                        label: const Text('Add to Bundle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
    //TODO: import from checkout and have edit functionality in display to add ingredient counts.
    final filteredBundles = searchQuery.isEmpty
        ? itemBundles
        : itemBundles
            .where((bundle) =>
                bundle.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    for (var bundle in itemBundles) {
      bundle.calculateStockStatus();
    }
    // final displayItems = _getFilteredItems(items);
    // Placeholder for item bundles logic
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: const [
              Expanded(
                  child: Text('Bundle Name',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('SKU',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  flex: 2,
                  child: Text('Items Included',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Sale Price',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  child: Text('Stock Status',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(
                  flex: 1,
                  child: Text('Actions',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(),
        // Table rows
        ...filteredBundles.map(
          (bundle) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(child: Text(bundle.name)),
                  Expanded(child: Text(bundle.sku)),
                  Expanded(
                      flex: 2,
                      child: Text(
                          bundle.items?.map((item) => item.name).join(', ') ??
                              '')),
                  Expanded(child: Text('\$${bundle.price.toStringAsFixed(2)}')),
                  // Expanded(child: Text(item.stock.toString())),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: bundle.stockStatus == 'Ready'
                            ? Colors.green[100]
                            : bundle.stockStatus == 'Low Stock'
                                ? Colors.yellow[100]
                                : bundle.stockStatus == 'Missing Items'
                                    ? Colors.red[300]
                                    : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        bundle.stockStatus!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Items included in bundle:'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (bundle.itemCounts != null && bundle.itemCounts!.isNotEmpty) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: bundle.itemCounts!.entries.map((entry) =>
                                                Row(
                                                  children: [
                                                    Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                                                    Text('x${entry.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  ],
                                                )
                                              ).toList(),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        const Text('Items in this bundle:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        if (bundle.checkoutItems != null &&
                                            bundle.checkoutItems!.isNotEmpty)
                                          ...bundle.checkoutItems!
                                              .map((item) => Text(item.name))
                                              .toList()
                                        else
                                          const Text('No items in this bundle.'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('View'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                // Handle edit action
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String? editedName = bundle.name;
                                    String? editedSku = bundle.sku;
                                    //String? editedCategory = item.category;
                                    double? editedPrice = bundle.price;
                                    //int? editedStock = item.stock;
                                    //String? editedStatus = item.status;
                                    //int? editedMinStock = item.minStock;
                                    //String? editedSupplier = item.supplier;

                                    return AlertDialog(
                                      title: const Text('Edit Item'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              labelText: 'Name',
                                            ),
                                            initialValue: bundle.name,
                                            onChanged: (value) =>
                                                editedName = value,
                                          ),
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              labelText: 'SKU',
                                            ),
                                            initialValue: bundle.sku,
                                            onChanged: (value) =>
                                                editedSku = value,
                                          ),

                                          TextFormField(
                                            decoration: const InputDecoration(
                                              labelText: 'Price',
                                              prefixText: '\$',
                                            ),
                                            keyboardType: TextInputType
                                                .numberWithOptions(
                                                    decimal: true),
                                            initialValue:
                                                bundle.price.toStringAsFixed(2),
                                            onChanged: (value) => editedPrice =
                                                double.tryParse(value),
                                          ),
                                          // DropdownButtonFormField<String>(
                                          //   decoration: const InputDecoration(
                                          //       labelText: 'Status'),
                                          //   value: item.status,
                                          //   items: [
                                          //     'In Stock',
                                          //     'Low Stock',
                                          //     'Out of Stock'
                                          //   ]
                                          //       .map((status) =>
                                          //           DropdownMenuItem<String>(
                                          //             value: status,
                                          //             child: Text(status),
                                          //           ))
                                          //       .toList(),
                                          //   onChanged: (value) => editedStatus = value,
                                          // ),
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
                                                editedPrice != null) {
                                              setState(() {
                                                bundle.name = editedName!;
                                                bundle.sku = editedSku!;
                                                bundle.price = editedPrice!;
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
                              child: const Text('Edit Bundle'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildLowStock(List<InventoryItem> items) {
    final lowStockItems = items
        .where((item) =>
            item.status == 'Low Stock' || item.status == 'Out of Stock')
        .toList();

    if (lowStockItems.isEmpty) {
      return const Center(
        child: Text('No low stock items found.',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    } else {
      final displayItems = _getFilteredItems(lowStockItems);
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
                        textAlign: TextAlign.center,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.stock == 0
                                ? Colors.red
                                : const Color.fromARGB(255, 244, 241, 241),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.stock.toString(),
                            style: TextStyle(
                              color:
                                  item.stock == 0 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Text(item.minStock.toString())),
                    Expanded(child: Text(item.supplier)),
                    Expanded(
                      flex: 1,
                      child: Center(
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
                                        onChanged: (value) =>
                                            editedName = value,
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
                                        onChanged: (value) =>
                                            editedCategory = value,
                                      ),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Price',
                                          prefixText: '\$',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        initialValue:
                                            item.price.toStringAsFixed(2),
                                        onChanged: (value) => editedPrice =
                                            double.tryParse(value),
                                      ),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Stock',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: false),
                                        initialValue: item.stock.toString(),
                                        onChanged: (value) =>
                                            editedStock = int.tryParse(value),
                                      ),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Minimum Stock',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: false),
                                        initialValue: item.minStock.toString(),
                                        onChanged: (value) => editedMinStock =
                                            int.tryParse(value),
                                      ),
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Supplier',
                                        ),
                                        initialValue: item.supplier,
                                        onChanged: (value) =>
                                            editedSupplier = value,
                                      ),
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                            labelText: 'Status'),
                                        value: item.status,
                                        items: [
                                          'In Stock',
                                          'Low Stock',
                                          'Out of Stock'
                                        ]
                                            .map((status) =>
                                                DropdownMenuItem<String>(
                                                  value: status,
                                                  child: Text(status),
                                                ))
                                            .toList(),
                                        onChanged: (value) =>
                                            editedStatus = value,
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
                    ),
                  ],
                
              )),
      
          )
        ]
      );
    }
  }

  Widget _buildAllItems(List<InventoryItem> items) {
    final displayItems = _getFilteredItems(items);
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
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(),
        // Table rows
        ...displayItems.map(
          (item) => Padding(
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
                    flex: 1,
                    child: Center(
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
                                      onChanged: (value) =>
                                          editedCategory = value,
                                    ),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Price',
                                        prefixText: '\$',
                                      ),
                                      keyboardType: TextInputType
                                          .numberWithOptions(
                                              decimal: true),
                                      initialValue: item.price.toStringAsFixed(2),
                                      onChanged: (value) => editedPrice =
                                          double.tryParse(value),
                                    ),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Stock',
                                      ),
                                      keyboardType: TextInputType
                                          .numberWithOptions(
                                              decimal: false),
                                      initialValue: item.stock.toString(),
                                      onChanged: (value) =>
                                          editedStock = int.tryParse(value),
                                    ),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Minimum Stock',
                                      ),
                                      keyboardType: TextInputType
                                          .numberWithOptions(
                                              decimal: false),
                                      initialValue: item.minStock.toString(),
                                      onChanged: (value) => editedMinStock =
                                          int.tryParse(value),
                                    ),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Supplier',
                                      ),
                                      initialValue: item.supplier,
                                      onChanged: (value) =>
                                          editedSupplier = value,
                                    ),
                                    DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                          labelText: 'Status'),
                                      value: item.status,
                                      items: [
                                        'In Stock',
                                        'Low Stock',
                                        'Out of Stock'
                                      ]
                                          .map((status) =>
                                              DropdownMenuItem<String>(
                                                value: status,
                                                child: Text(status),
                                              ))
                                          .toList(),
                                      onChanged: (value) =>
                                          editedStatus = value,
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
                  ),
                ],
              )),
        ),
      ],
    );
  }
}
