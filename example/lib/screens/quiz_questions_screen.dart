import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_view_model.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../services/inactivity_service.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final AssessmentModel? assessment;
  final String? courseId;
  final String? assessmentId;

  const QuizQuestionsScreen({
    super.key,
    this.assessment,
    this.courseId,
    this.assessmentId,
  });

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  Timer? _timer;
  int _currentQuestion = 0;
  int _timeRemaining = 60; // 60 seconds per question
  String? _selectedAnswer;
  bool _showFeedback = false;
  int _correctAnswers = 0;
  bool _hasSubmitted = false; // Prevent double submission
  late final List<Question> _shuffledQuestions;
  final InactivityService _inactivityService = InactivityService();

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  // Get questions from assessment
  List<Question> get _questions => _shuffledQuestions;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions =
        List<Question>.from(widget.assessment?.questions ?? []);
    _shuffledQuestions.shuffle();

    if (_shuffledQuestions.isNotEmpty) {
      _startTimer();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inactivityService.resetTimer(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    setState(() {
      _timeRemaining = 60; // Reset to 60 seconds for this question
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
      });

      if (_timeRemaining <= 0) {
        _timer?.cancel();
        // Time's up - auto advance to next question
        _autoAdvanceQuestion();
      }
    });
  }

  void _selectAnswer(int answerIndex) {
    if (_showFeedback) return;

    _registerActivity();

    final isCorrect =
        _questions[_currentQuestion].choices[answerIndex].isCorrect;

    setState(() {
      _selectedAnswer = answerIndex.toString();
      _showFeedback = true;
      // Cancel timer when answer is selected
      _timer?.cancel();

      if (isCorrect) {
        _correctAnswers++;
        print('Correct answers now: $_correctAnswers');
      }
    });
  }

  void _autoAdvanceQuestion() async {
    // Auto-advance when timer expires
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showFeedback = false;
      });
      _startTimer(); // Start timer for next question
    } else {
      // Last question - finish quiz
      _timer?.cancel();
      await _finishQuiz();
    }
  }

  void _nextQuestion() async {
    if (_currentQuestion < _questions.length - 1) {
      _registerActivity();

      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _showFeedback = false;
      });
      _startTimer(); // Restart timer for next question
    } else {
      // Quiz completed - finish quiz
      _timer?.cancel();
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    // Prevent double submission
    if (_hasSubmitted) {
      print('Quiz already submitted, preventing duplicate');
      return;
    }

    setState(() {
      _hasSubmitted = true;
    });

    await _saveQuizResults();
    _showResults();
  }

  Future<void> _saveQuizResults() async {
    final currentUserId = FirebaseService.currentUsersId;
    if (currentUserId == null || widget.assessmentId == null) return;

    print('Saving quiz results: Score: $_correctAnswers/${_questions.length}');

    try {
      final quizAttemptViewModel = context.read<QuizAttemptViewModel>();
      await quizAttemptViewModel.recordQuizAttempt(
        currentUserId,
        widget.assessmentId!,
        _correctAnswers,
        _questions.length,
        incrementAttempt: false,
      );
      print('Quiz results saved successfully');
    } catch (e) {
      print('Error saving quiz results: $e');
    }
  }

  void _showResults() {
    // Prevent navigation if already navigating
    if (!mounted) return;

    // Check if user passed (assuming 60% is passing)
    final passingScore = (_questions.length * 0.6).ceil();
    final passed = _correctAnswers >= passingScore;

    if (passed) {
      // Navigate to success result screen
      Navigator.of(context).pushReplacementNamed(
        '/quiz-result-success',
        arguments: {
          'score': _correctAnswers,
          'totalQuestions': _questions.length,
          'courseId': widget.courseId,
          'assessmentId': widget.assessmentId,
          'moduleTitle': widget.assessment?.module,
          'assessment': widget.assessment,
        },
      );
    } else {
      // Navigate to failed result screen
      Navigator.of(context).pushReplacementNamed(
        '/quiz-result-failed',
        arguments: {
          'score': _correctAnswers,
          'totalQuestions': _questions.length,
          'hasNextModule': false,
          'courseId': widget.courseId,
          'assessmentId': widget.assessmentId,
          'moduleTitle': widget.assessment?.module,
          'assessment': widget.assessment,
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
    return (60 - _timeRemaining) / 60;
  }

  @override
  Widget build(BuildContext context) {
    // Safety check: if no questions, show error/loading screen

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: royalBlue,
        appBar: AppBar(
          backgroundColor: royalBlue,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: const Text(
            'Quiz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No quiz questions available or you have used all available attempts for this quiz.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellowish,
                  foregroundColor: royalBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQ = _questions[_currentQuestion];

    return Listener(
      onPointerDown: (_) => _registerActivity(),
      onPointerMove: (_) => _registerActivity(),
      onPointerUp: (_) => _registerActivity(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
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
                'Question ${_currentQuestion + 1}/${_questions.length}',
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
                currentQ.statement,
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

            const SizedBox(height: 12),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Answer Options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          for (int i = 0; i < currentQ.choices.length; i++) ...[
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ElevatedButton(
                                onPressed: _showFeedback
                                    ? () {}
                                    : () => _selectAnswer(i),
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
                                        currentQ.choices[i].statement,
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

                    // Feedback Section
                    if (_showFeedback) ...[
                      const SizedBox(height: 8),
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
                              'The Correct Answer is ${String.fromCharCode(65 + currentQ.choices.indexWhere((c) => c.isCorrect))}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQ.description,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Next Button (fixed at bottom)
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
                  _currentQuestion < _questions.length - 1
                      ? 'NEXT >'
                      : 'FINISH',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _registerActivity() {
    if (mounted) {
      _inactivityService.resetTimer(context);
    }
  }

  Color _getOptionColor(int index) {
    if (!_showFeedback) {
      return const Color(0xFFE8F4FD); // Light blue default
    }

    final isCorrect = _questions[_currentQuestion].choices[index].isCorrect;
    final selectedIndex = int.tryParse(_selectedAnswer ?? '-1') ?? -1;

    if (isCorrect) {
      return const Color(0xFFC8E6C9); // Light green for correct answer
    } else if (index == selectedIndex && !isCorrect) {
      return const Color(0xFFFFCDD2); // Light red for wrong selected answer
    } else {
      return const Color(0xFFE8F4FD); // Light blue for unselected options
    }
  }

  Widget? _getOptionIcon(int index) {
    if (!_showFeedback) return null;

    final isCorrect = _questions[_currentQuestion].choices[index].isCorrect;
    final selectedIndex = int.tryParse(_selectedAnswer ?? '-1') ?? -1;

    if (isCorrect) {
      return const Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 20,
      );
    } else if (index == selectedIndex && !isCorrect) {
      return const Icon(
        Icons.cancel,
        color: Colors.white,
        size: 20,
      );
    }
    return null;
  }
}
