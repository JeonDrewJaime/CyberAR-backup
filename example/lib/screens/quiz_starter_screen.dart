import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_repository.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_view_model.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';

class QuizStarterScreen extends StatefulWidget {
  final AssessmentModel? assessment;
  final String? courseId;
  final String? assessmentId;
  final String? moduleTitle;
  final bool forceFetchAssessment;

  const QuizStarterScreen({
    super.key,
    this.assessment,
    this.courseId,
    this.assessmentId,
    this.moduleTitle,
    this.forceFetchAssessment = false,
  });

  @override
  State<QuizStarterScreen> createState() => _QuizStarterScreenState();
}

class _QuizStarterScreenState extends State<QuizStarterScreen> {
  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  late ScrollController _scrollController;
  bool _showScrollHint = false;
  bool _isScrollable = false;
  bool _isStartingAttempt = false;
  bool _isLoadingAssessment = false;
  String? _assessmentError;
  AssessmentModel? _assessment;
  String? _assessmentId;

  final AssessmentRepository _assessmentRepository = AssessmentRepository();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _assessment = widget.assessment;
    _assessmentId = widget.assessmentId ?? widget.assessment?.documentId;

    if (_assessmentId == null || _assessment == null ||
        widget.forceFetchAssessment) {
      _loadAssessment();
    }

    // Check if content is scrollable after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollability();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isAtBottom = position.pixels >= position.maxScrollExtent - 10;

    setState(() {
      _showScrollHint = _isScrollable && !isAtBottom;
    });
  }

  void _checkScrollability() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final canScroll = position.maxScrollExtent > 0;
    final isAtBottom = position.pixels >= position.maxScrollExtent - 10;

    setState(() {
      _isScrollable = canScroll;
      _showScrollHint = canScroll && !isAtBottom;
    });
  }

  Future<void> _loadAssessment() async {
    if (_isLoadingAssessment) return;

    setState(() {
      _isLoadingAssessment = true;
      _assessmentError = null;
    });

    try {
      AssessmentModel? fetched;
      if (widget.assessmentId != null) {
        fetched = await _assessmentRepository
            .fetchAssessmentById(widget.assessmentId!);
      } else if (widget.moduleTitle != null) {
        fetched = await _assessmentRepository
            .fetchFirstAssessmentByModule(widget.moduleTitle!);
      }

      if (!mounted) return;

      setState(() {
        _assessment = fetched;
        _assessmentId = fetched?.documentId ?? _assessmentId;
        if (fetched == null) {
          _assessmentError = 'Assessment information not available.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _assessmentError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAssessment = false;
        });
      }
    }
  }

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
              // Scrollable content area
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //! ASSESSMENT TIME TITLE
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
                            textAlign: TextAlign.center,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInstruction(
                                  'This assessment has ${_assessment?.questions.length ?? widget.assessment?.questions.length ?? 15} questions.'),
                              const _buildInstruction(
                                  'You have 60 seconds to answer each question.'),
                              const _buildInstruction(
                                  'Just tap on an answer, and you\'ll instantly see if it\'s correct or wrong'),
                              const _buildInstruction(
                                  'After seeing the correct answer, tap "Next" or wait for the timer to expire.'),
                              const _buildInstruction(
                                  'Before the first Question appears, there\'s a 15-second "Get Ready" countdown when you tap Start.'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Scroll hint at bottom of scrollable area
                    if (_showScrollHint)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                royalBlue.withOpacity(0.8),
                                royalBlue,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Scroll down for more',
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 236, 255, 24)
                                            .withOpacity(0.8),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons (fixed at bottom)
              Column(
                children: [
                  // START Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isStartingAttempt || _isLoadingAssessment
                          ? null
                          : () async {
                              if (_assessmentId == null) {
                                await _loadAssessment();
                                if (_assessmentId == null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_assessmentError ??
                                          'Assessment information not available.'),
                                    ),
                                  );
                                  return;
                                }
                              }

                              if (_assessmentId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Assessment information not available.'),
                                  ),
                                );
                                return;
                              }

                              final userId = FirebaseService.currentUsersId;
                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'You must be signed in to take the quiz.'),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _isStartingAttempt = true;
                              });

                              try {
                                final quizAttemptViewModel =
                                    context.read<QuizAttemptViewModel>();
                                await quizAttemptViewModel.startQuizAttempt(
                                  userId,
                                  _assessmentId!,
                                );

                                if (!mounted) return;
                                Navigator.of(context).pushNamed(
                                  '/quiz-countdown',
                                  arguments: {
                                    'assessment': _assessment,
                                    'courseId': widget.courseId,
                                    'assessmentId': _assessmentId,
                                  },
                                );
                              } catch (e) {
                                if (!mounted) return;
                                final message = e.toString();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isStartingAttempt = false;
                                  });
                                }
                              }
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
                      child: _isStartingAttempt
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'START',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_assessmentError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _assessmentError!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),

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
