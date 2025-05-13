import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'dart:collection';

void main() {
  final shopping_cart_list = ShoppingCartList();
  

  


  runApp(ChangeNotifierProvider(create: (_) => shopping_cart_list, child: MyApp()));
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
  // var current = WordPair.random();

  // void getNext() {
  //   current = WordPair.random();
  //   notifyListeners();
  // }

  // var favorites = <WordPair>[];

  // void toggleFavorite() {
  //   if (favorites.contains(current)) {
  //     favorites.remove(current);
  //   } else {
  //     favorites.add(current);
  //   }
  //   notifyListeners();
  // }

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

// ...


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
}


class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Placeholder(); // Placeholder for the dashboard page
      case 1:
        page = Placeholder(); // Placeholder for the analytics page
      case 2:
        page = InventoryPage(); // Placeholder for the inventory page
      case 3:
        page = Placeholder(); // Placeholder for the pos config page
      case 4:
        page = CheckoutPage(); // Placeholder for the checkout page
      case 5:
        page = Placeholder(); // Placeholder for the transactions page
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        // make body a column that contains a text and a row
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.analytics),
                    label: Text('Analytics'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory),
                    label: Text('Inventory'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('POS Config'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_grocery_store),
                    label: Text('Checkout'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.assignment),
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
    });
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

/*
class CheckoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    if (favorites.isEmpty) {
      return Center (
        child: Text(
          "No favourites yet :(",
          style: TextStyle(fontSize: 28),
        ),
      );
    }
    else {
      return ListView(
        children: [
          Padding (
            padding: const EdgeInsets.all(20),
            child: Text("You have ${favorites.length} favorites:", style: TextStyle(fontSize: 28)),
          ),

          for (var pair in favorites) 
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(pair.asLowerCase, style: TextStyle(fontSize: 24)),
            ),
          
        ],
      );
    }

  }
}
*/


class CheckoutPage extends StatelessWidget {
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
    context.read<ShoppingCartList>().add("test item");
    context.read<ShoppingCartList>().add("test item 2");
    LinkedHashMap<String, int> cart = LinkedHashMap();

    // would we import the menu options? read from csv/txt file?

    // mock data for testing
    cart.addAll({
      'Cappuccino': 0,
      'Latte': 1,
      'Americano': 2,
      'Espresso': 0,
    });

          final cart_items = context.watch<ShoppingCartList>().items;
          print(cart_items);

          return Row(
            children: [
              /*
            Flexible(
              flex: 7, // This takes 7/11 of the available space
              child: Column(
                children: [
                  Container(
                    color: Colors.red,
                    child: GridButton(
                      textStyle: textStyle,
                      borderColor: Colors.grey[300],
                      borderWidth: 2,
                      onPressed: (dynamic val) {
                        _focusNode.requestFocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val.toString()),
                            duration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      items: [
                        /*
                        [
                          GridButtonItem(
                            title: "Cappuccino",
                            color: Colors.blue,
                            textStyle: textStyle.copyWith(color: Colors.white),
                          ),
                          GridButtonItem(
                            title: "Latte",
                            color: Colors.green,
                            textStyle: textStyle.copyWith(color: Colors.white),
                          ),
                        ],
                        [
                          GridButtonItem(
                              child: const Icon(
                                Icons.image_outlined,
                                size: 50,
                              ),
                              focusNode: _focusNode,
                              textStyle: textStyle.copyWith(color: Colors.white),
                              value: 'image',
                              color: Colors.blue,
                              shape: const BorderSide(width: 4),
                              borderRadius: 30)
                        ],
                        [
                          const GridButtonItem(title: "7"),
                          const GridButtonItem(title: "8"),
                          const GridButtonItem(title: "9"),
                          GridButtonItem(title: "×", color: Colors.grey[300]),
                        ],
                        [
                          const GridButtonItem(title: "4"),
                          const GridButtonItem(title: "5"),
                          const GridButtonItem(title: "6"),
                          GridButtonItem(title: "-", color: Colors.grey[300]),
                        ], */
                        [
                          const GridButtonItem(title: "1"),
                          const GridButtonItem(title: "2"),
                          const GridButtonItem(title: "3"),
                          GridButtonItem(title: "+", color: Colors.grey[300]),
                        ],
                        [
                          const GridButtonItem(title: "0"),
                          const GridButtonItem(
                              title: "000", flex: 2, longPressValue: 400),
                          GridButtonItem(title: "=", color: Colors.grey[300]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ), */

              Flexible(
                flex: 7, // This takes 7/11 of the available space
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
                          borderRadius:
                              BorderRadius.zero, // Makes the button square
                        ),
                      ),
                      child: Text(
                        buttonLabels[index],
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
                // child: Container(

                //   color: const Color.fromARGB(255, 223, 240, 224),
                // ),
              ),
              // Current Order panel
              Flexible(
                flex: 4, // This takes 4/11 of the available space
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No items in cart',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      
                      child: cart_items.isEmpty
                        ? Center(
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.receipt_long,
                              size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 18, color: Colors.black54),
                            ),
                            Text(
                            'Add items from the menu',
                            style: TextStyle(color: Colors.grey),
                            ),
                          ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: cart_items.length,
                          itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(cart_items[index]),
                            trailing: IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              context
                                .read<ShoppingCartList>()
                                .remove(cart_items[index]);
                            },
                            ),
                          );
                          },
                        ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          _buildPriceRow('Subtotal', '\$0.00'),
                          _buildPriceRow('Tax (7.25%)', '\$0.00'),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.local_offer_outlined,
                                  color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'Add Discount',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Total',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('\$0.00',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text('Checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

/*
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Order'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No items in cart',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  Text(
                    'Add items from the menu',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
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
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
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
              child: ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
              ),
            ),
          ),
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


*/

/*
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
