<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

void main() {
  final shoppingCartList = ShoppingCartList();

  runApp(ChangeNotifierProvider(create: (_) => shoppingCartList, child: MyApp()));
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
                child: Text(
                  'mobilePOS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:  FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                  )
                ),
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

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  var checkoutState = 0;

  final List<String> buttonLabels = [
    'Cappuccino',
    'Latte',
    'Americano',
    'Espresso',
    'Mocha',
    'Cold Brew',
    'Croissant',
    'Blueberry Muffin',
    'Chocolate Chip Cookie',
    'Chicken Sandwich',
    'Caesar Salad',
    'Fresh Fruit Cup',
    'Water Bottle',
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
              return ElevatedButton(
                onPressed: () {
                  context.read<ShoppingCartList>().add(buttonLabels[index]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You added ${buttonLabels[index]} to the cart'),
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
                  buttonLabels[index],
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              );
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
      return _buildPaymentOption();
    case 2:
      return _buildPaymentConfirm();
    default:
      return _buildCartPanel(cartItems); // fallback
  }
}

  Widget _buildCartPanel(List<String> cart_items) {
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
                          style: TextStyle(fontSize: 18, color: Colors.black54)),
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
                    int itemCount =
                        cart_items.where((i) => i == item).length;

                    return ListTile(
                      title: Text(item),
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
              _buildPriceRow('Subtotal', '\$0.00'),
              _buildPriceRow('Tax (7.25%)', '\$0.00'),
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
            children: const [
              Text('Total',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$0.00',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        backgroundColor:
                           const Color.fromARGB(255, 27, 126, 207),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
            ),
        ),
      ],
    );
  }

  Widget _paymentButton(IconData icon, String label, {bool isSelected = false}) {
  return Container(
    width: 140,
    height: 60,
    decoration: BoxDecoration(
      color: isSelected ? Colors.black : Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? Colors.white : Colors.black),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      ],
    ),
  );
}

Widget _buildInputField(String label, {bool obscure = false, String? hint}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      SizedBox(height: 4),
      TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    ],
  );
}

  Widget _buildPaymentOption() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Payment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Select payment method', style: TextStyle(fontSize: 16, color: Colors.grey)),

          SizedBox(height: 16),

          // Payment method buttons
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _paymentButton(Icons.credit_card, 'Card', isSelected: true),
              _paymentButton(Icons.attach_money, 'Cash'),
              _paymentButton(Icons.card_giftcard, 'Gift Card'),
              _paymentButton(Icons.share, 'Other'),
            ],
          ),

          SizedBox(height: 24),

          // Card Payment Form
          Text('Card Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _buildInputField('Card Number', obscure: true),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInputField('Expiration Date', hint: 'MM/YY')),
              SizedBox(width: 12),
              Expanded(child: _buildInputField('CVV', obscure: true)),
            ],
          ),
          SizedBox(height: 12),
          _buildInputField('ZIP Code', hint: '12345'),
          SizedBox(height: 8),
          Text('Payments processed securely through Square', style: TextStyle(color: Colors.grey)),

          Spacer(),

          // Total and buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$17.50', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () {
                    // Complete the sale
                    _checkoutHelper(2); // Go to confirmation page
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
      children: const [
        Icon(Icons.check_circle, color: Colors.green, size: 80),
        SizedBox(height: 16),
        Text(
          'Thank you for your purchase!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Your order has been placed.'),
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
=======
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

void main() {
  final shoppingCartList = ShoppingCartList();

  runApp(ChangeNotifierProvider(create: (_) => shoppingCartList, child: MyApp()));
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
                child: Text(
                  'mobilePOS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:  FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                  )
                ),
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

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool showCheckoutSummary = false;

  final List<String> buttonLabels = [
    'Cappuccino',
    'Latte',
    'Americano',
    'Espresso',
    'Mocha',
    'Cold Brew',
    'Croissant',
    'Blueberry Muffin',
    'Chocolate Chip Cookie',
    'Chicken Sandwich',
    'Caesar Salad',
    'Fresh Fruit Cup',
    'Water Bottle',
  ];

  void _checkoutHelper(bool toggle) {
    setState(() {
      showCheckoutSummary = toggle;
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
              return ElevatedButton(
                onPressed: () {
                  context.read<ShoppingCartList>().add(buttonLabels[index]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You added ${buttonLabels[index]} to the cart'),
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
                  buttonLabels[index],
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              );
            },
          ),
        ),

        // Right side: your cart panel
        Flexible(
          flex: 4,
          child: showCheckoutSummary
            ? _buildPaymentOption()
            : _buildCartPanel(cart_items),
        ),
      ],
    );
  }

  Widget _buildCartPanel(List<String> cart_items) {
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
                          style: TextStyle(fontSize: 18, color: Colors.black54)),
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
                    int itemCount =
                        cart_items.where((i) => i == item).length;

                    return ListTile(
                      title: Text(item),
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
              _buildPriceRow('Subtotal', '\$0.00'),
              _buildPriceRow('Tax (7.25%)', '\$0.00'),
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
            children: const [
              Text('Total',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$0.00',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    _checkoutHelper(true);
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                           const Color.fromARGB(255, 27, 126, 207),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
            ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.check_circle, color: Colors.green, size: 80),
        SizedBox(height: 16),
        Text(
          'Thank you for your purchase!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Your order has been placed.'),
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
>>>>>>> 02e906365f3adad6293ca5f0fa3c58429666c6e6
