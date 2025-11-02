import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/app_drawer.dart';

class QuizCountdownScreen extends StatefulWidget {
  const QuizCountdownScreen({super.key});

  @override
  State<QuizCountdownScreen> createState() => _QuizCountdownScreenState();
}

class _QuizCountdownScreenState extends State<QuizCountdownScreen> {
  Timer? _timer;
  int _countdown = 15; // 15 seconds countdown
  double _progress = 0.0;
  int _textIndex = 0;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  // Motivational messages that change every 4 seconds
  final List<String> _motivationalTexts = [
    'Your brain is a powerhouse—time to use it!',
    'Focus and let your knowledge shine!',
    'You\'ve got this! Trust your instincts!',
    'Every second counts—make them matter!',
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        _progress = (15 - _countdown) / 15; // Progress from 0 to 1

        // Change text every 4 seconds
        if ((15 - _countdown) % 4 == 0 && _countdown < 15) {
          _textIndex = ((15 - _countdown) ~/ 4) % _motivationalTexts.length;
        }
      });

      if (_countdown <= 0) {
        timer.cancel();
        _navigateToQuiz();
      }
    });
  }

  void _navigateToQuiz() {
    Navigator.of(context).pushReplacementNamed('/quiz-questions');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    return '00:${seconds.toString().padLeft(2, '0')}';
  }

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
          border: Border.all(color: yellowish, width: 4),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: royalBlue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GET READY! Title
                const Text(
                  'GET READY!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),

                // Countdown Timer
                Text(
                  _formatTime(_countdown),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Bar
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: yellowish,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Motivational Message
                Text(
                  _motivationalTexts[_textIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
