import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class QuizResultSuccessScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultSuccessScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: royalBlue,
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
        height: double.infinity,
        decoration: BoxDecoration(
          color: royalBlue,
          border: Border.all(color: yellowish, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Check Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: yellowish,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.black,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),

              // "CONGRATULATIONS!" Message
              const Text(
                'CONGRATULATIONS!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // "Panel 1!" Text
              const Text(
                'Panel 1!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Score and Success Message
              Text(
                'You scored $score/$totalQuestions. Excellent work! You have successfully completed the assessment.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Action Buttons
              Column(
                children: [
                  // CONTINUE TO NEXT MODULE Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to next module or course modules
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/course-modules',
                          (route) => false,
                          arguments: {
                            'courseTitle': 'Introduction to Cybersecurity',
                            'moduleCount': 5,
                          },
                        );
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
                        'CONTINUE TO NEXT MODULE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // VIEW RESULTS Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show detailed results or certificate
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Quiz Results'),
                            content: Text(
                              'You scored $score out of $totalQuestions questions.\n\n'
                              'This represents a ${((score / totalQuestions) * 100).toStringAsFixed(1)}% success rate.\n\n'
                              'Well done on completing the cybersecurity assessment!',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
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
                        'VIEW RESULTS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // BACK Button
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
                        'BACK',
                        style: TextStyle(
                          fontSize: 14,
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

