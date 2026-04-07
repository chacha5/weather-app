import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  const MyIconButton({
    super.key,
    required this.imagePath, // Corrected parameter name
  });

  final String imagePath; // Corrected parameter name

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade600,
      ),
      child: Image.asset(
        imagePath, // Corrected parameter name
        height: 40,
      ),
    );
  }
}