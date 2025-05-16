import 'package:flutter/material.dart';
import 'package:mobile_pos/models/shopping_cart_list.dart';
import 'package:provider/provider.dart';


class CheckoutPage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final cart_items = context.watch<ShoppingCartList>().items;
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
                  context.read<ShoppingCartList>().add(buttonLabels[index]);
                  // Define button behavior here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('You added ${buttonLabels[index]} to the cart'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 73, 158, 227), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Makes the button square
                  ),
                ),
                child: Text(
                  buttonLabels[index],
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              );
            },
          ),
          // child: Container(

          //   color: const Color.fromARGB(255, 223, 240, 224),
          // ),
        ),
        // Cart panel
        Flexible(
          flex: 4, // This takes 4/11 of the available space
          child: Column(
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
                              color: Colors.black87),
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
                        itemCount:
                            cart_items.toSet().length, // Unique items only
                        itemBuilder: (context, index) {
                          final uniqueItems =
                              cart_items.toSet().toList(); // Get unique items
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
                                    context
                                        .read<ShoppingCartList>()
                                        .remove(item);
                                  },
                                ),
                                Text(
                                  '$itemCount',
                                  style: TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    context.read<ShoppingCartList>().add(item);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    context
                                        .read<ShoppingCartList>()
                                        .removeAll(item);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  child: cart_items.isEmpty
                      ? ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text('Checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                        )
                      : ElevatedButton.icon(
                    onPressed: () {
                      // Checkout functionality here
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('Checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 27, 126, 207),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
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
