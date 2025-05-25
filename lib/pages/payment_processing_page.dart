import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/checkout_item.dart';

class PaymentProcessingPage extends StatefulWidget {
  final List<String> cartItems;
  final List<CheckoutItem> priceLookup;

  PaymentProcessingPage({
    required this.cartItems,
    required this.priceLookup,
  });

  @override
  _PaymentProcessingPageState createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCheckout();
  }

  Future<void> _startCheckout() async {
    try {
      final itemNames = widget.cartItems.join(', ');

      double subtotal = 0.0;
      for (var item in widget.cartItems) {
        final itemPrice = widget.priceLookup
            .firstWhere((e) => e.name == item)
            .price ?? 0.0;
        subtotal += itemPrice;
      }

      const taxRate = 0.13;
      final tax = subtotal * taxRate;
      final total = subtotal + tax;
      final int amountInCents = (total * 100).round();

      final response = await http.post(
        Uri.parse("http://localhost:3000/create-checkout"), // Replace with ngrok URL if testing on a device
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "itemNames": itemNames,
          "amount": amountInCents,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final checkoutUrl = data['checkoutUrl'];

        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
          Navigator.pop(context);
        } else {
          throw Exception('Could not launch checkout URL');
        }
      } else {
        throw Exception('Backend error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connecting to Square')),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Redirecting to checkout...'),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 20),
                  Text('Failed to load checkout.'),
                  SizedBox(height: 8),
                  Text(
                    _error ?? 'Unknown error',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back'),
                  )
                ],
              ),
      ),
    );
  }
}
