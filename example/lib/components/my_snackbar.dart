import 'package:flutter/material.dart';

class MySnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.red,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: behavior,
        duration: duration,
      ),
    );
  }
}
