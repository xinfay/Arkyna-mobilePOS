import 'package:flutter/material.dart';

Widget buildPriceRow(String label, String amount) {
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

Widget buildInputField(String label, {
  TextEditingController? controller,
  String? hint,
  String? prefixText,
  TextInputType keyboardType = TextInputType.text,
  bool obscure = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    ],
  );
}
