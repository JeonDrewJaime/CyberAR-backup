import 'package:flutter/material.dart';

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowish,
      body: const Center(
        child: Text(
          'App Guide Screen\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: royalBlue,
          ),
        ),
      ),
    );
  }
}
