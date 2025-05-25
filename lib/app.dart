import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/analytics_page.dart';
import 'pages/inventory_page.dart';
import 'pages/configuration_page.dart';
import 'pages/checkout_page.dart';
import 'pages/transactions_page.dart';
import 'providers/cart_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;
  final List<Widget> pages = const [
    DashboardPage(),
    AnalyticsPage(),
    InventoryPage(),
    ConfigurationPage(),
    CheckoutPage(),
    TransactionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingCartList(),
      child: MaterialApp(
        title: 'mobile_pos',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
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
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.house), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(Icons.analytics), label: Text('Analytics')),
                    NavigationRailDestination(icon: Icon(Icons.inventory), label: Text('Inventory')),
                    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Configurations')),
                    NavigationRailDestination(icon: Icon(Icons.shopping_cart), label: Text('Checkout')),
                    NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Transactions')),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        ),
      ),
    );
  }
}
