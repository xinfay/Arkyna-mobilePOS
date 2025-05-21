import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final shoppingCartList = ShoppingCartList();

  runApp(
      ChangeNotifierProvider(create: (_) => shoppingCartList, child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'mobile_pos',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(237, 249, 255, 1)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // How would the inventory be stored? possibly import a csv file w/ categories:
  // name, sku, category, price, stock, status

  // currently using mock data to test
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);
  void add(String i) {
    _items.add(i);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class ShoppingCartList extends ChangeNotifier {
  final List<String> _items = [];
  List<String> get items => List.unmodifiable(_items);

  void add(String item) {
    _items.add(item);
    notifyListeners();
  }

  void remove(String item) {
    _items.remove(item);
    notifyListeners();
  }

  void removeAll(String item) {
    _items.removeWhere((i) => i == item);
    notifyListeners();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page = Placeholder();
    switch (selectedIndex) {
      case 0:
        page = Placeholder();
      case 1:
        page = Placeholder();
      case 2:
        page = InventoryPage();
      case 3:
        page = Placeholder();
      case 4:
        page = CheckoutPage();
      case 5:
        page = Placeholder();
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: true,
              indicatorColor: Colors.blueGrey[100],
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minExtendedWidth: 200,
              leading: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('mobilePOS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
                    )),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.house_siding),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  label: Text('Analytics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('Inventory'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_applications_sharp),
                  label: Text('Configurations'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  label: Text('Checkout'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.content_paste_go_sharp),
                  label: Text('Transactions'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryPage extends StatelessWidget {
  final List<String> buttonLabels = [
    'Button 1',
    'Button 2',
    'Button 3',
    'Button 4',
    'Button 5',
    'Button 6',
    'Button 7',
    'Button 8',
    'Button 9',
    'Button 10',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Grid Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 8.0, // Spacing between columns
            mainAxisSpacing: 8.0, // Spacing between rows
          ),
          itemCount: buttonLabels.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              onPressed: () {
                // Define button behavior here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You pressed ${buttonLabels[index]}'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Makes the button square
                ),
              ),
              child: Text(
                buttonLabels[index],
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CheckoutItem {
  String? name;
  //int quantity;
  double? price;
  String? description;

  CheckoutItem(
    this.name,
    this.price,
    this.description,
  );
}

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  var checkoutState = 0;
  final double taxRate = 0.13;
  double subtotal = 0.0;

  double _calculateSubtotal(List<String> cart_items) {
    double subtotal = 0.0;
    for (var item in cart_items) {
      final price = buttonLabels.firstWhere((e) => e.name == item).price ?? 0.0;
      subtotal += price;
    }
    return subtotal;
  }

  final List<CheckoutItem> buttonLabels = [
    CheckoutItem(
      'Cappuccino',
      4.50,
      'A classic cappuccino with espresso, steamed milk, and foam.',
    ),
    CheckoutItem(
      'Latte',
      4.00,
      'A smooth latte with espresso and steamed milk.',
    ),
    CheckoutItem(
      'Americano',
      3.50,
      'A strong Americano with espresso and hot water.',
    ),
    CheckoutItem(
      'Mocha',
      4.75,
      'A rich mocha with espresso, steamed milk, and chocolate.',
    ),
    CheckoutItem(
      'Cold Brew',
      3.00,
      'A refreshing cold brew coffee served over ice.',
    ),
    CheckoutItem(
      'Croissant',
      2.50,
      'A buttery croissant, perfect for breakfast.',
    ),
    CheckoutItem(
      'Blueberry Muffin',
      2.75,
      'A delicious blueberry muffin, fresh from the oven.',
    ),
    CheckoutItem(
      'Chocolate Chip Cookie',
      1.50,
      'A classic chocolate chip cookie, warm and gooey.',
    ),
    CheckoutItem(
      'Chicken Sandwich',
      5.00,
      'A grilled chicken sandwich with lettuce and tomato.',
    ),
    CheckoutItem(
      'Caesar Salad',
      4.50,
      'A fresh Caesar salad with romaine lettuce and croutons.',
    ),
    CheckoutItem(
      'Fresh Fruit Cup',
      0.50,
      'A refreshing cup of mixed seasonal fruits.',
    ),
    CheckoutItem(
      'Water Bottle',
      1.00,
      'A bottle of refreshing water.',
    ),
    CheckoutItem(
      'Add Item',
      0.00,
      'Add a new item to the menu.',
    )
  ];

  void _checkoutHelper(var toggle) {
    setState(() {
      checkoutState = toggle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart_items = context.watch<ShoppingCartList>().items;
    print(cart_items);

    return Row(
      children: [
        Flexible(
          flex: 7, // Left side: menu buttons
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: buttonLabels.length,
            itemBuilder: (context, index) {
              // Check if the button is "Add Item"
              if (buttonLabels[index].name == 'Add Item') {
                return ElevatedButton(
                  onPressed: () async {
                    String? newName;
                    String? newDescription;
                    double? newPrice;

                    final nameController = TextEditingController();
                    final priceController = TextEditingController();
                    final descController = TextEditingController();

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Add New Item'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(labelText: 'Name'),
                              ),
                              TextField(
                                controller: priceController,
                                decoration: InputDecoration(labelText: 'Price', prefixText: '\$'),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                              ),
                              TextField(
                                controller: descController,
                                decoration:
                                    InputDecoration(labelText: 'Description'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                newName = nameController.text;
                                newDescription = descController.text;
                                newPrice =
                                    double.tryParse(priceController.text);

                                if (newName == null || newName!.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Invalid name entered.'),
                                    ),
                                  );
                                  return;
                                }

                                if (newPrice == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Invalid price entered.'),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.of(context).pop();
                              },
                              child: Text('Submit'),
                            ),
                          ], // actions
                        );
                      },
                    );

                    // Now newName, newPrice, newDescription hold the user input (null if cancelled)
                    if (newName != null &&
                        newName!.isNotEmpty &&
                        newPrice != null) {
                      // You can now use newName, newPrice, newDescription as needed
                      CheckoutItem newItem = CheckoutItem(
                        newName,
                        newPrice,
                        newDescription,
                      );
                      buttonLabels.insert(buttonLabels.length - 1, newItem);
                      context.read<ShoppingCartList>().add(newName!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added: $newName (\$$newPrice)'),
                        ),
                      );
                      // Optionally, add to your buttonLabels or item list here
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    buttonLabels[index].name!,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                );
              } else {
                return ElevatedButton(
                  onPressed: () {
                    context
                        .read<ShoppingCartList>()
                        .add(buttonLabels[index].name!);
                    subtotal += buttonLabels[index].price!;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'You added ${buttonLabels[index].name} to the cart'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 73, 158, 227),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    buttonLabels[index].name!,
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                );
              }

              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text(
              //           'You added ${buttonLabels[index].name} to the cart'),
              //     ),
              //   );
              // },
              // style: ElevatedButton.styleFrom(
              //   backgroundColor: const Color.fromARGB(255, 73, 158, 227),
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.zero,
              //   ),
              // ),
              // child: Text(
              //   buttonLabels[index].name!,
              //   style: TextStyle(fontSize: 17, color: Colors.white),
              // ),
              // );
            },
          ),
        ),

        // Right side: your cart panel
        Flexible(
          flex: 4,
          child: _buildCheckoutState(cart_items),
        ),
      ],
    );
  }

  Widget _buildCheckoutState(List<String> cartItems) {
    switch (checkoutState) {
      case 0:
        return _buildCartPanel(cartItems);
      case 1:
        return _buildPaymentOption(cartItems);
      case 2:
        return _buildPaymentConfirm();
      default:
        return _buildCartPanel(cartItems); // fallback
    }
  }

  Widget _buildCartPanel(
    List<String> cart_items,
  ) {
    final subtotal = _calculateSubtotal(cart_items);
    final tax = subtotal * taxRate;
    final total = subtotal + tax;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: cart_items.isEmpty
                ? Text(
                    'No items in cart',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  )
                : Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
          ),
        ),
        Expanded(
          child: cart_items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Your cart is empty',
                          style:
                              TextStyle(fontSize: 18, color: Colors.black54)),
                      Text('Add items from the menu',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: cart_items.toSet().length,
                  itemBuilder: (context, index) {
                    final uniqueItems = cart_items.toSet().toList();
                    String item = uniqueItems[index];
                    int itemCount = cart_items.where((i) => i == item).length;

                    return ListTile(
                      title: Text(item),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        // keep both numbers or only the total?
                        children: [
                          Text(
                            '\$${buttonLabels.firstWhere((e) => e.name == item).price?.toStringAsFixed(2) ?? '0.00'}',
                            style:
                                TextStyle(fontSize: 15, color: Colors.black38),
                          ),
                          Text(
                            'Total: \$${((buttonLabels.firstWhere((e) => e.name == item).price ?? 0) * itemCount).toStringAsFixed(2)}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              context.read<ShoppingCartList>().remove(item);
                            },
                          ),
                          Text('$itemCount', style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              context.read<ShoppingCartList>().add(item);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              context.read<ShoppingCartList>().removeAll(item);
                              itemCount * buttonLabels[index].price!;
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
              _buildPriceRow('Tax (${(taxRate * 100).toStringAsFixed(2)}%)',
                  '\$${(subtotal * taxRate).toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Icon(Icons.local_offer_outlined, color: Colors.black54),
                  SizedBox(width: 8),
                  Text(
                    'Add Discount',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: cart_items.isEmpty
                ? const [
                    Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$0.00',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ]
                : [
                    Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: cart_items.isEmpty
                ? ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      _checkoutHelper(1);
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 27, 126, 207),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _paymentButton(IconData icon, String label,
      {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            SizedBox(width: 8),
            Text(label,
                style:
                    TextStyle(color: isSelected ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label, {
    bool obscure = false,
    String? hint,
    String? prefixText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  int _selectedPaymentIndex = 0;
  late TextEditingController _cardNumberController;
  late TextEditingController _expController;
  late TextEditingController _cvvController;
  late TextEditingController _zipController;
  late TextEditingController _cashInputController;

  String? _cashError;
  double? _cashChange;

  void _setPaymentMethod(int index) {
    setState(() {
      _selectedPaymentIndex = index;
    });
  }

  void _processPayment(double total) {
    if (_selectedPaymentIndex == 2) {
      final cash = double.tryParse(_cashInputController.text) ?? 0.0;
      if (cash < total) {
        setState(() {
          _cashError = 'Insufficient cash provided.';
          _cashChange = null;
        });
      } else {
        setState(() {
          _cashError = null;
          _cashChange = cash - total;
        });
        _checkoutHelper(2);
      }
    } else {
      // validate other methods here as needed
      _checkoutHelper(2);
    }
  }

  void _handleExternalService(String serviceName) {
    // Placeholder: In a real app, this would initiate an SDK or redirect flow
    print('Redirecting to $serviceName...');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redirecting to $serviceName...')),
    );
  }

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expController = TextEditingController();
    _cvvController = TextEditingController();
    _zipController = TextEditingController();
    _cashInputController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expController.dispose();
    _cvvController.dispose();
    _zipController.dispose();
    _cashInputController.dispose();
    super.dispose();
  }

  Widget _buildPaymentOption(cartItems) {
    final subtotal = _calculateSubtotal(cartItems);
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Payment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Select payment method',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 16),

          // Payment method buttons
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _paymentButton(Icons.credit_card, 'Credit Card',
                  isSelected: _selectedPaymentIndex == 0,
                  onTap: () => _setPaymentMethod(0)),
              _paymentButton(Icons.credit_card, 'Debit Card',
                  isSelected: _selectedPaymentIndex == 1,
                  onTap: () => _setPaymentMethod(1)),
              _paymentButton(Icons.attach_money, 'Cash',
                  isSelected: _selectedPaymentIndex == 2,
                  onTap: () => _setPaymentMethod(2)),
              _paymentButton(Icons.share, 'Other',
                  isSelected: _selectedPaymentIndex == 3,
                  onTap: () => _setPaymentMethod(3)),
            ],
          ),
          SizedBox(height: 24),

          // Credit Card
          if (_selectedPaymentIndex == 0) ...[
            Text('Credit Card',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildInputField('Card Number', controller: _cardNumberController),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildInputField('Expiration Date',
                        hint: 'MM/YY', controller: _expController)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildInputField('CVV', controller: _cvvController)),
              ],
            ),
            SizedBox(height: 8),
            Text('No ZIP required. Secure processing.',
                style: TextStyle(color: Colors.grey)),
          ],

          // Debit Card
          if (_selectedPaymentIndex == 1) ...[
            Text('Debit Card',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildInputField('Card Number', controller: _cardNumberController),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildInputField('Expiration Date',
                        hint: 'MM/YY', controller: _expController)),
                SizedBox(width: 12),
                Expanded(
                    child: _buildInputField('CVV', controller: _cvvController)),
              ],
            ),
            SizedBox(height: 12),
            _buildInputField('ZIP Code',
                hint: '12345', controller: _zipController),
          ],

          // Cash
          if (_selectedPaymentIndex == 2) ...[
            Text('Cash Payment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildInputField('Enter Cash Received',
                prefixText: '\$',
                controller: _cashInputController,
                keyboardType: TextInputType.number),
            if (_cashError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_cashError!, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 12),
            if (_cashChange != null)
              Text('Change: \$${_cashChange!.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold)),
          ],

          // Other
          if (_selectedPaymentIndex == 3) ...[
            Text('Other Payment Methods',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _handleExternalService('PayPal'),
                  icon: Icon(Icons.account_balance_wallet),
                  label: Text('PayPal'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExternalService('Venmo'),
                  icon: Icon(Icons.send),
                  label: Text('Venmo'),
                ),
              ],
            )
          ],

          Spacer(),

          // Total and Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _checkoutHelper(0),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor:const Color.fromARGB(255, 196, 222, 243),
),
                    onPressed: () {
                    

                    _processPayment(total); 
                    final cartProvider = context.read<ShoppingCartList>();
                    final uniqueItems = cartProvider.items.toSet().toList();
                    for (var item in uniqueItems) {
                      cartProvider.removeAll(item);
                    }

                    },
                  child: Text('Complete Sale'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentConfirm() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 16),
          Text(
            'Thank you for your purchase!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Your order has been placed.'),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              // Reset to initial state
              setState(() {
                checkoutState = 0;
                _selectedPaymentIndex = 0;
                _cashError = null;
                _cashChange = null;
                _cardNumberController.clear();
                _expController.clear();
                _cvvController.clear();
                _zipController.clear();
                _cashInputController.clear();
              });
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 1, 87, 157)
,
              foregroundColor: Colors.white,
            ),
            child: Text('Start New Order'),
            
          )
        ],
      ),
    );
  }

  static Widget _buildPriceRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(amount, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
