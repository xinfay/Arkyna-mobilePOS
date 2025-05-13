import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mobile_pos/models/shopping_cart_list.dart';
import 'package:provider/provider.dart';

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

    LinkedHashMap<String, int> cart = LinkedHashMap();

    // would we import the menu options? read from csv/txt file?

    // mock data for testing
    cart.addAll({
      'Cappuccino': 0,
      'Latte': 1,
      'Americano': 2,
      'Espresso': 0,
    });

          final cart_items = Provider.of<ShoppingCartList>(context).items;
          print(cart_items);

          return Row(
            children: [
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
                        context.read<ShoppingCartList>().add("button $index");
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
