import 'package:flutter/material.dart';

class CircularProgressBar extends StatelessWidget {
  String status;
  CircularProgressBar(
      {super.key, required this.status});

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      content: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(status),
        ]),
      ),
    );
  }
}
