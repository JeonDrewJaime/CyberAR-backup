import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class CyberNewsScreen extends StatelessWidget {
  const CyberNewsScreen({super.key});

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
          'CyberNews',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Headline Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Informed, Stay Secure',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Get the Latest cybersecurity news, threats, and updates in the philippines. Stay ahead of the scams, data breaches amd digital security risks.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Featured Content Block
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: royalBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Logo on the left side
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: royalBlue, width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Shield shape
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        // Blue top section with stars
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 30,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: royalBlue,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '★ ★ ★',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Red and yellow diagonal sections
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 50,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Eagle/Bird icon
                        const Center(
                          child: Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content on the right side
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Understanding modes-of-threat in DeepSeek and other AI technologies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'The term "DeepSeek" is being used flexibly and in reference to more than one thing. This is confusing in the cyber security context since it means the "DeepSeek" risks are different things to different people.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fill remaining space with yellow background
          Expanded(
            child: Container(
              width: double.infinity,
              color: yellowish,
            ),
          ),
        ],
      ),
    );
  }
}
