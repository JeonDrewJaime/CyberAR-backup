import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_repository.dart';
import 'package:flutter_unity_widget_example/services/module_view_model.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_repository.dart';
import 'package:flutter_unity_widget_example/services/user_view_model.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';

class QuizResultSuccessScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String? courseId;
  final String? assessmentId;
  final String? moduleTitle;
  final AssessmentModel? assessment;

  const QuizResultSuccessScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.courseId,
    this.assessmentId,
    this.moduleTitle,
    this.assessment,
  });

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  State<QuizResultSuccessScreen> createState() =>
      _QuizResultSuccessScreenState();
}

class _QuizResultSuccessScreenState extends State<QuizResultSuccessScreen> {
  final AssessmentRepository _assessmentRepository = AssessmentRepository();
  final QuizAttemptRepository _quizAttemptRepository = QuizAttemptRepository();
  @override
  void initState() {
    super.initState();
    //! LISTEN TO USER
    final userId = FirebaseService.currentUsersId;
    if (userId != null) {
      final userViewModel = context.read<UserViewModel>();
      userViewModel.listenToUser(userId);
    }
    //! Ensure module data is available
    final moduleViewModel = context.read<ModuleViewModel>();
    moduleViewModel.listenToModules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuizResultSuccessScreen.royalBlue,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: QuizResultSuccessScreen.royalBlue,
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
          color: QuizResultSuccessScreen.royalBlue,
          border:
              Border.all(color: QuizResultSuccessScreen.yellowish, width: 2),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Success Check Icon
                  Container(
                    width: 120,
                    height: 120,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // adjust as needed
                        child: Image.asset(
                          'assets/images/check.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // "CONGRATULATIONS!" Message
                  const Text(
                    'CONGRATULATIONS!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Name from users collection
                  Consumer<UserViewModel>(
                    builder: (context, userViewModel, child) {
                      return Text(
                        '${userViewModel.user?.name ?? "Student"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Score and Success Message
                  Text(
                    'You scored ${widget.score}/${widget.totalQuestions}. Excellent work! You have successfully completed the assessment.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Consumer<ModuleViewModel>(
                    builder: (context, moduleViewModel, child) {
                      final modules = moduleViewModel.modules;
                      final currentIndex = widget.courseId != null
                          ? modules.indexWhere((m) => m.id == widget.courseId)
                          : -1;
                      final hasNextModule = currentIndex >= 0 &&
                          currentIndex < modules.length - 1;

                      return Column(
                        children: [
                          // CONTINUE TO NEXT MODULE Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                                  (widget.courseId != null && hasNextModule)
                                      ? () {
                                          _continueToNextModule(context);
                                        }
                                      : (widget.courseId == null
                                          ? () {
                                              _navigateToCourses(context);
                                            }
                                          : null),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    QuizResultSuccessScreen.royalBlue,
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white, width: 2),
                                disabledBackgroundColor: Colors.grey.shade700,
                                disabledForegroundColor: Colors.white70,
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
                                      'You scored ${widget.score} out of ${widget.totalQuestions} questions.\n\n'
                                      'This represents a ${((widget.score / widget.totalQuestions) * 100).toStringAsFixed(1)}% success rate.\n\n'
                                      'Well done on completing the cybersecurity assessment!',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    QuizResultSuccessScreen.royalBlue,
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white, width: 2),
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
                              onPressed: widget.courseId != null
                                  ? () {
                                      _navigateToCourseModules(context);
                                    }
                                  : () {
                                      _navigateToCourses(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    QuizResultSuccessScreen.royalBlue,
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white, width: 2),
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
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueToNextModule(BuildContext context) async {
    final courseId = widget.courseId;
    final userId = FirebaseService.currentUsersId;
    if (userId == null) {
      _navigateToCourses(context);
      return;
    }

    final moduleViewModel = context.read<ModuleViewModel>();
    final modules = moduleViewModel.modules;

    if (modules.isEmpty) {
      _navigateToCourses(context);
      return;
    }

    final currentIndex = courseId == null
        ? -1
        : modules.indexWhere((module) => module.id == courseId);

    if (courseId != null && currentIndex >= 0) {
      final currentCourse = modules[currentIndex];
      final currentStatus = await _getCourseStatus(currentCourse, userId);

      if (currentStatus != 'completed') {
        final nextLesson = _findNextLesson(currentCourse, userId);
        if (nextLesson != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/module-details',
            _retainBaseRoutes,
            arguments: {
              'courseId': currentCourse.id,
              'currentIndex': nextLesson.lessonIndex,
            },
          );
        } else {
          _navigateToCourseModules(context, courseId: currentCourse.id);
        }
        return;
      }
    }

    final startIndex = currentIndex >= 0 ? currentIndex : modules.length - 1;
    for (int offset = 1; offset <= modules.length; offset++) {
      final nextIndex = (startIndex + offset) % modules.length;
      if (nextIndex == currentIndex) {
        break;
      }

      final module = modules[nextIndex];
      final status = await _getCourseStatus(module, userId);

      if (status != 'completed') {
        final nextLesson = _findNextLesson(module, userId);
        if (nextLesson != null) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/module-details',
            _retainBaseRoutes,
            arguments: {
              'courseId': module.id,
              'currentIndex': nextLesson.lessonIndex,
            },
          );
        } else {
          _navigateToCourseModules(context, courseId: module.id);
        }
        return;
      }
    }

    if (courseId != null) {
      _navigateToCourseModules(context, courseId: courseId);
    } else {
      _navigateToCourses(context);
    }
  }

  _NextLessonInfo? _findNextLesson(ModuleModel course, String userId) {
    for (var i = 0; i < course.lessons.length; i++) {
      final lesson = course.lessons[i];
      final status = lesson.status[userId] ?? 'not_started';
      if (status != 'completed') {
        return _NextLessonInfo(lessonIndex: i);
      }
    }
    return null;
  }

  Future<String> _getCourseStatus(ModuleModel course, String userId) async {
    final lessonStatus = course.getStatusForUser(userId);
    if (lessonStatus != 'completed') {
      return lessonStatus;
    }

    final assessments = await _assessmentRepository
        .listenToAssessmentsByModule(course.title)
        .first;

    if (assessments.isEmpty) {
      return 'completed';
    }

    for (final assessment in assessments) {
      if (assessment.documentId == null) {
        continue;
      }

      final quizAttempt = await _quizAttemptRepository.getQuizAttempt(
        userId,
        assessment.documentId!,
      );

      if (quizAttempt == null) {
        return 'in_progress';
      }

      final passingScore = (assessment.questions.length * 0.6).ceil();
      if (quizAttempt.bestScore < passingScore) {
        return 'in_progress';
      }
    }

    return 'completed';
  }

  void _navigateToCourseModules(BuildContext context, {String? courseId}) {
    final targetCourseId = courseId ?? widget.courseId;
    if (targetCourseId == null) {
      _navigateToCourses(context);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/course-modules',
      _retainBaseRoutes,
      arguments: {
        'courseId': targetCourseId,
      },
    );
  }

  void _navigateToCourses(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/courses',
      _retainBaseRoutes,
    );
  }

  bool _retainBaseRoutes(Route<dynamic> route) {
    final name = route.settings.name;
    return name == '/student-dashboard' ||
        name == '/teacher-dashboard' ||
        name == '/courses' ||
        route.isFirst;
  }
}

class _NextLessonInfo {
  final int lessonIndex;

  const _NextLessonInfo({required this.lessonIndex});
}
