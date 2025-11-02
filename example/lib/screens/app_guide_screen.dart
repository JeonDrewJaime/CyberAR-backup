import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

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
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: royalBlue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'App Guide',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
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

