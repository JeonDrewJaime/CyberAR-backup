import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class QuizStarterScreen extends StatelessWidget {
  const QuizStarterScreen({super.key});

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
          'Courses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: royalBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: yellowish, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assessment Time Title
              const Text(
                'ASSESSMENT TIME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Congratulations Message
              const Text(
                'Congratulations on completing\nthe module!\nBut the journey isn\'t over yet.\nLet\'s put your knowledge to the\ntest with this assessment.\nReady to Go?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Instructions Header
              const Text(
                'INSTRUCTIONS:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Instructions List
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstruction('This Assessment has 15 questions.'),
                  _buildInstruction(
                      'You have 60 seconds to answer each question.'),
                  _buildInstruction(
                      'Just tap on an answer, and you\'ll instantly see if it\'s correct or wrong'),
                  _buildInstruction(
                      'After seeing the correct answer, tap "Next" or wait for the timer to expire.'),
                  _buildInstruction(
                      'Before the first Question appears, there\'s a 15-second "Get Ready" countdown when you tap Start.'),
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  // START Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/quiz-countdown');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'START',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Exit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _buildInstruction extends StatelessWidget {
  final String text;

  const _buildInstruction(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
