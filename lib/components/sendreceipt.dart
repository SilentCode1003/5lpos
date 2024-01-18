import 'package:flutter/material.dart';

class SendReceipt extends StatefulWidget {
  const SendReceipt({super.key});

  @override
  State<SendReceipt> createState() => _SendReceiptState();
}

class _SendReceiptState extends State<SendReceipt> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customer Email'),
      content: const Text(''),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Send')),
        TextButton(onPressed: () {}, child: const Text('Close')),
      ],
    );
  }
}
