import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class QuizResultFailedScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final bool hasNextModule;

  const QuizResultFailedScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.hasNextModule = true,
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
              // Warning Triangle Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: yellowish,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning,
                  color: Colors.black,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),

              // "YOU CAN TRY AGAIN!" Message
              const Text(
                'YOU CAN TRY AGAIN!',
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

              // Score and Encouragement Message
              Text(
                'You scored $score/$totalQuestions. No worries—review the modules and try again. Every attempt helps you learn more!',
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
                      onPressed: hasNextModule
                          ? () {
                              // Navigate to next module or course modules
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/course-modules',
                                (route) => false,
                                arguments: {
                                  'courseTitle':
                                      'Introduction to Cybersecurity',
                                  'moduleCount': 5,
                                },
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            hasNextModule ? royalBlue : Colors.grey,
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: hasNextModule
                                ? Colors.white
                                : Colors.grey.shade400,
                            width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        hasNextModule
                            ? 'CONTINUE TO NEXT MODULE'
                            : 'NO MORE MODULES',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // RETAKE ASSESSMENT Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to quiz starter
                        Navigator.of(context).pushNamed('/quiz-starter');
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
                        'RETAKE ASSESSMENT',
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
