import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  final String text;
  const StatusBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Text(text),
    );
  }
}
