import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/app_drawer.dart';

class QuizQuestionsScreen extends StatefulWidget {
  const QuizQuestionsScreen({super.key});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  Timer? _timer;
  int _currentQuestion = 0;
  int _timeRemaining = 300; // 5 minutes (300 seconds) for entire quiz
  String? _selectedAnswer;
  bool _showFeedback = false;
  int _correctAnswers = 0;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  // Quiz questions data
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the best way to prevent ransomware attacks?',
      'options': [
        'Use weak passwords',
        'Avoid updating the operating system',
        'Regularly back up important files',
        'Open email attachments from unknown senders',
      ],
      'correctAnswer': 2, // Index of correct answer (C)
      'explanation':
          'Backups help restore data without paying the ransom if files are encrypted.',
    },
    {
      'question': 'Which of the following is NOT a type of malware?',
      'options': [
        'Virus',
        'Firewall',
        'Trojan',
        'Worm',
      ],
      'correctAnswer': 1, // Index of correct answer (B)
      'explanation':
          'A firewall is a security device, not malware. Viruses, Trojans, and Worms are all types of malware.',
    },
    {
      'question': 'What does the CIA Triad stand for in cybersecurity?',
      'options': [
        'Central Intelligence Agency',
        'Confidentiality, Integrity, Availability',
        'Computer Information Assurance',
        'Cyber Intelligence Analysis',
      ],
      'correctAnswer': 1, // Index of correct answer (B)
      'explanation':
          'The CIA Triad represents the three fundamental principles of information security.',
    },
    {
      'question': 'Which authentication method is considered the most secure?',
      'options': [
        'Password only',
        'Username and password',
        'Multi-factor authentication',
        'Biometric authentication only',
      ],
      'correctAnswer': 2, // Index of correct answer (C)
      'explanation':
          'Multi-factor authentication combines multiple verification methods for enhanced security.',
    },
    {
      'question': 'What is the primary purpose of a firewall?',
      'options': [
        'To store backup data',
        'To monitor and control network traffic',
        'To encrypt files',
        'To scan for viruses',
      ],
      'correctAnswer': 1, // Index of correct answer (B)
      'explanation':
          'Firewalls act as barriers between networks, monitoring and controlling incoming and outgoing traffic.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Only start timer if it's not already running
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _timeRemaining--;
        });

        if (_timeRemaining <= 0) {
          _timer?.cancel();
          _showResults();
        }
      });
    }
  }

  void _selectAnswer(int answerIndex) {
    if (_showFeedback) return;

    setState(() {
      _selectedAnswer = answerIndex.toString();
      _showFeedback = true;
      // Don't cancel timer - let it continue running

      if (answerIndex ==
          (_questions[_currentQuestion]['correctAnswer'] as int)) {
        _correctAnswers++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showFeedback = false;
      });
      // Timer continues running - don't restart it
    } else {
      // Quiz completed - stop timer and navigate to results
      _timer?.cancel();
      _showResults();
    }
  }

  void _showResults() {
    // Check if user passed (assuming 70% is passing)
    final passingScore = (_questions.length * 0.7).ceil();
    final passed = _correctAnswers >= passingScore;

    if (passed) {
      // Navigate to success result screen
      Navigator.of(context).pushNamed(
        '/quiz-result-success',
        arguments: {
          'score': _correctAnswers,
          'totalQuestions': _questions.length,
        },
      );
    } else {
      // Navigate to failed result screen
      Navigator.of(context).pushNamed(
        '/quiz-result-failed',
        arguments: {
          'score': _correctAnswers,
          'totalQuestions': _questions.length,
          'hasNextModule':
              false, // This is the last module (Module 4), no more modules after quiz
        },
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    return (300 - _timeRemaining) / 300;
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentQuestion];

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
      body: Column(
        children: [
          // Question Progress Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: royalBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'Question ${_currentQuestion + 1}/5',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Question Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: yellowish,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentQ['question'],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Timer Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text(
                  'TIME:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _getProgress(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: yellowish,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatTime(_timeRemaining),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Answer Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (int i = 0; i < currentQ['options'].length; i++) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed:
                            _showFeedback ? () {} : () => _selectAnswer(i),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getOptionColor(i),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              String.fromCharCode(65 + i), // A, B, C, D
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currentQ['options'][i],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_getOptionIcon(i) != null) ...[
                              const SizedBox(width: 8),
                              _getOptionIcon(i)!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Feedback Section
          if (_showFeedback) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Correct Answer is ${String.fromCharCode(65 + (currentQ['correctAnswer'] as int))}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQ['explanation'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Next Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _showFeedback ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: yellowish,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentQuestion < _questions.length - 1 ? 'NEXT >' : 'FINISH',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getOptionColor(int index) {
    if (!_showFeedback) {
      return const Color(0xFFE8F4FD); // Light blue default
    }

    final correctIndex = _questions[_currentQuestion]['correctAnswer'] as int;
    final selectedIndex = int.parse(_selectedAnswer!);

    if (index == correctIndex) {
      return const Color(0xFFC8E6C9); // Light green for correct answer
    } else if (index == selectedIndex && selectedIndex != correctIndex) {
      return const Color(0xFFFFCDD2); // Light red for wrong selected answer
    } else {
      return const Color(0xFFE8F4FD); // Light blue for unselected options
    }
  }

  Widget? _getOptionIcon(int index) {
    if (!_showFeedback) return null;

    final correctIndex = _questions[_currentQuestion]['correctAnswer'] as int;
    final selectedIndex = int.parse(_selectedAnswer!);

    if (index == correctIndex) {
      return const Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 20,
      );
    } else if (index == selectedIndex && selectedIndex != correctIndex) {
      return const Icon(
        Icons.cancel,
        color: Colors.white,
        size: 20,
      );
    }
    return null;
  }
}
