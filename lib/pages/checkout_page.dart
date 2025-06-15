import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/checkout_item.dart';
import '../pages/payment_processing_page.dart';
import '../providers/cart_provider.dart';
import '../widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../providers/analytics_service.dart';
import '../providers/inventory_helper.dart';
import '../models/checkout_catalog.dart';

final List<CheckoutItem> buttonLabels = checkoutLabels;

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int checkoutState = 0;
  int _selectedPaymentIndex = 99;

  final double taxRate = 0.13;
  double tip = 0.0;

  late TextEditingController _cashInputController;
  String? _cashError;
  double? _cashChange;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cashInputController = TextEditingController();
  }

  @override
  void dispose() {
    _cashInputController.dispose();
    super.dispose();
  }

  void _checkoutHelper(int toggle) {
    setState(() {
      checkoutState = toggle;
    });
  }

  double _calculateSubtotal(List<String> cartItems) {
    double subtotal = 0.0;
    for (var item in cartItems) {
      final price = buttonLabels.firstWhere((e) => e.name == item).price ?? 0.0;
      subtotal += price;
    }
    return subtotal;
  }

  void _setPaymentMethod(int index) {
    setState(() {
      _selectedPaymentIndex = index;
    });
  }

  Future<void> _processPayment(double total) async {
    final cartItems = context.read<ShoppingCartList>().items;
    final subtotal = _calculateSubtotal(cartItems);
    final tax = subtotal * taxRate;
    final fullTotal = subtotal + tax + tip;

    if (_selectedPaymentIndex == 2) {
      final cash = double.tryParse(_cashInputController.text) ?? 0.0;
      if (cash < fullTotal) {
        setState(() {
          _cashError = 'Insufficient cash provided.';
          _cashChange = null;
        });
        return;
      } else {
        setState(() {
          _cashError = null;
          _cashChange = cash - fullTotal;
        });
      }
    }
    await _saveCompletedOrder(cartItems, subtotal, tax, tip, fullTotal);

    _checkoutHelper(2);
  }

  Future<void> _saveCompletedOrder(List<String> cartItems, double subtotal,
      double tax, double tip, double total) async {
    final Map<String, int> itemCounts = {};
    for (var itemName in cartItems) {
      itemCounts[itemName] = (itemCounts[itemName] ?? 0) + 1;
    }

    final List<OrderItem> orderItems = itemCounts.entries.map((entry) {
      final item = buttonLabels.firstWhere((e) => e.name == entry.key);
      return OrderItem(
        name: item.name,
        price: item.price,
        quantity: entry.value,
      );
    }).toList();

    final order = Order(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      items: orderItems,
      subtotal: subtotal,
      tax: tax,
      tip: tip,
      total: total,
    );

    await AnalyticsService.saveOrder(order);

    for (final item in orderItems) {
      await InventoryHelper.deductIngredientsForCheckoutItem(item.name, item.quantity);
    }
  }

  void _handleExternalService(String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redirecting to $service...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = context.watch<ShoppingCartList>().items;

    return Row(
      children: [
        Flexible(
          flex: 7,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: buttonLabels.length,
            itemBuilder: (context, index) {
              final item = buttonLabels[index];
              final isAddItem = item.name == 'Add Item';

              return ElevatedButton(
                onPressed: isAddItem
                    ? () async {
                        String? newName;
                        String? newDesc;
                        double? newPrice;

                        final nameCtrl = TextEditingController();
                        final priceCtrl = TextEditingController();
                        final descCtrl = TextEditingController();

                        await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Add Item'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                    controller: nameCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Name')),
                                TextField(
                                    controller: priceCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Price', prefixText: '\$'),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true)),
                                TextField(
                                    controller: descCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Description')),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () {
                                  newName = nameCtrl.text;
                                  newPrice = double.tryParse(priceCtrl.text);
                                  newDesc = descCtrl.text;

                                  if (newName == null ||
                                      newName!.isEmpty ||
                                      newPrice == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Invalid input.')),
                                    );
                                    return;
                                  }

                                  Navigator.of(context).pop();

                                  setState(() {
                                    buttonLabels.insert(
                                        buttonLabels.length - 1,
                                        CheckoutItem(
                                            newName!, newPrice!, newDesc));
                                  });
                                  context
                                      .read<ShoppingCartList>()
                                      .add(newName!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Added: $newName (\$$newPrice)')),
                                  );
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        );
                      }
                    : () {
                        context.read<ShoppingCartList>().add(item.name);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You added ${item.name} to the cart')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAddItem
                      ? Colors.green
                      : const Color.fromARGB(255, 73, 158, 227),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(item.name,
                    style: const TextStyle(fontSize: 17, color: Colors.white)),
              );
            },
          ),
        ),
        Flexible(
          flex: 4,
          child: _buildCheckoutState(cartItems),
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
        return _buildConfirmation();
      case 3:
        return _buildTippingPage(cartItems);
      default:
        return _buildCartPanel(cartItems);
    }
  }

  Widget _buildCartPanel(List<String> cartItems) {
    final subtotal = _calculateSubtotal(cartItems);
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: cartItems.isEmpty
                ? const Text(
                    'No items in cart',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  )
                : const Text(
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
          child: cartItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                  itemCount: cartItems.toSet().length,
                  itemBuilder: (context, index) {
                    final uniqueItems = cartItems.toSet().toList();
                    String item = uniqueItems[index];
                    int itemCount = cartItems.where((i) => i == item).length;
                    final itemPrice =
                        buttonLabels.firstWhere((e) => e.name == item).price;

                    return ListTile(
                      title: Text(item),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${itemPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black38),
                          ),
                          Text(
                            'Total: \$${(itemPrice * itemCount).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                context.read<ShoppingCartList>().remove(item),
                          ),
                          Text('$itemCount',
                              style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                context.read<ShoppingCartList>().add(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => context
                                .read<ShoppingCartList>()
                                .removeAll(item),
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
              buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
              buildPriceRow('Tax (${(taxRate * 100).toStringAsFixed(2)}%)',
                  '\$${tax.toStringAsFixed(2)}'),
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
            children: cartItems.isEmpty
                ? const [
                    Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$0.00',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ]
                : [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: cartItems.isEmpty
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
                    onPressed: () => _checkoutHelper(3),
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

  Widget _buildTippingPage(List<String> cartItems) {
    final subtotal = _calculateSubtotal(cartItems);

    final tipOptions = [
      {
        'label': '10%',
        'sub': '\$${(subtotal * 0.10).toStringAsFixed(2)}',
        'value': 0.10
      },
      {
        'label': '15%',
        'sub': '\$${(subtotal * 0.15).toStringAsFixed(2)}',
        'value': 0.15
      },
      {
        'label': '20%',
        'sub': '\$${(subtotal * 0.20).toStringAsFixed(2)}',
        'value': 0.20
      },
      {
        'label': '25%',
        'sub': '\$${(subtotal * 0.25).toStringAsFixed(2)}',
        'value': 0.25
      },
      {'label': 'No Tip', 'sub': '', 'value': 0.0},
      {'label': 'Custom', 'sub': '', 'value': null},
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Add a tip:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Your total: \$${subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: tipOptions.map((tipOption) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 123, 179),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final value = tipOption['value'];
                    if (value == null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Enter Custom Tip'),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Tip Amount',
                                suffixText: '%',
                              ),
                              onChanged: (val) {
                                final percent = double.tryParse(val);
                                if (percent != null) {
                                  setState(() {
                                    tip = subtotal * (percent / 100);
                                  });
                                }
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _checkoutHelper(1);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(() {
                        tip = subtotal * (value as double);
                        _checkoutHelper(1);
                      });
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tipOption['label'] as String,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      if ((tipOption['sub'] as String).isNotEmpty)
                        Text(
                          tipOption['sub'] as String,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(List<String> cartItems) {
    final subtotal = _calculateSubtotal(cartItems);
    final tax = subtotal * taxRate;
    final total = subtotal + tax + tip;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Select payment method',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _paymentButton(
                Icons.credit_card,
                'Credit Card',
                isSelected: _selectedPaymentIndex == 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentProcessingPage(
                        cartItems: cartItems,
                        priceLookup: buttonLabels,
                        tip: tip,
                      ),
                    ),
                  );
                },
              ),
              _paymentButton(
                Icons.credit_card,
                'Debit Card',
                isSelected: _selectedPaymentIndex == 1,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentProcessingPage(
                        cartItems: cartItems,
                        priceLookup: buttonLabels,
                        tip: tip,
                      ),
                    ),
                  );
                },
              ),
              _paymentButton(Icons.attach_money, 'Cash',
                  isSelected: _selectedPaymentIndex == 2,
                  onTap: () => _setPaymentMethod(2)),
              _paymentButton(Icons.share, 'Other',
                  isSelected: _selectedPaymentIndex == 3,
                  onTap: () => _setPaymentMethod(3)),
            ],
          ),

          const SizedBox(height: 24),

          // Cash
          if (_selectedPaymentIndex == 2) ...[
            const Text('Cash Payment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            buildInputField('Enter Cash Received',
                prefixText: '\$',
                controller: _cashInputController,
                keyboardType: TextInputType.number),
            if (_cashError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_cashError!,
                    style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 12),
            if (_cashChange != null)
              Text('Change: \$${_cashChange!.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
          ],

          // Other Payment Options
          if (_selectedPaymentIndex == 3) ...[
            const Text('Other Payment Methods',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _handleExternalService('PayPal'),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('PayPal'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleExternalService('Venmo'),
                  icon: const Icon(Icons.send),
                  label: const Text('Venmo'),
                ),
              ],
            )
          ],

          if (_selectedPaymentIndex == 99) ...[
            const SizedBox(height: 16),
            const Text('No payment method selected.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _checkoutHelper(0),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: const Color.fromARGB(255, 196, 222, 243),
                  ),
                  onPressed: _isProcessing
                      ? null // disables the button while processing
                      : () async {
                          setState(() {
                            _isProcessing = true;
                          });

                          await _processPayment(total);

                          final provider = context.read<ShoppingCartList>();
                          for (var item in provider.items.toSet()) {
                            provider.removeAll(item);
                          }

                          setState(() {
                            _isProcessing = false;
                          });
                        },
                  child: const Text('Complete Sale'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text('Payment Complete!'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _checkoutHelper(0),
            child: const Text('Start New Order'),
          )
        ],
      ),
    );
  }

  Widget _paymentButton(
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
