import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/services/user_view_model.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';

class QuizResultFailedScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final bool hasNextModule;
  final String? courseId;
  final String? assessmentId;
  final String? moduleTitle;
  final AssessmentModel? assessment;

  const QuizResultFailedScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.hasNextModule = true,
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
  State<QuizResultFailedScreen> createState() => _QuizResultFailedScreenState();
}

class _QuizResultFailedScreenState extends State<QuizResultFailedScreen> {
  @override
  void initState() {
    super.initState();
    //! LISTEN TO USER
    final userId = FirebaseService.currentUsersId;
    if (userId != null) {
      final userViewModel = context.read<UserViewModel>();
      userViewModel.listenToUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuizResultFailedScreen.royalBlue,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: QuizResultFailedScreen.royalBlue,
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
          color: QuizResultFailedScreen.royalBlue,
          border: Border.all(color: QuizResultFailedScreen.yellowish, width: 2),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Warning Triangle Icon
                  Container(
                    width: 120,
                    height: 120,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0), // adjust as needed
                        child: Image.asset(
                          'assets/images/warning.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // "YOU CAN TRY AGAIN!" Message
                  const Text(
                    'YOU CAN TRY AGAIN!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
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
                  // Score and Encouragement Message
                  Text(
                    'You scored ${widget.score}/${widget.totalQuestions}. No worries—review the modules and try again. Every attempt helps you learn more!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Column(
                    children: [
                      // CONTINUE TO NEXT MODULE Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              widget.hasNextModule && widget.courseId != null
                                  ? () {
                                      _navigateToCourseModules(context);
                                    }
                                  : widget.hasNextModule
                                      ? () {
                                          _navigateToCourses(context);
                                        }
                                      : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.hasNextModule
                                ? QuizResultFailedScreen.royalBlue
                                : const Color.fromARGB(255, 194, 113, 113),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: widget.hasNextModule
                                    ? Colors.white
                                    : Colors.grey.shade400,
                                width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.hasNextModule
                                ? 'CONTINUE TO NEXT MODULE'
                                : 'NO MORE MODULES',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.hasNextModule
                                  ? Colors.white
                                  : Colors.grey.shade400,
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
                            final assessmentId = widget.assessmentId;
                            if (assessmentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Assessment information not available.'),
                                ),
                              );
                              return;
                            }

                            Navigator.of(context).pushNamed(
                              '/quiz-starter',
                              arguments: {
                                'assessment': widget.assessment,
                                'assessmentId': assessmentId,
                                'courseId': widget.courseId,
                                'moduleTitle': widget.moduleTitle,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuizResultFailedScreen.royalBlue,
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
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
                          onPressed: widget.courseId != null
                              ? () {
                                  _navigateToCourseModules(context);
                                }
                              : () {
                                  _navigateToCourses(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: QuizResultFailedScreen.royalBlue,
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.white, width: 2),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCourseModules(BuildContext context) {
    final courseId = widget.courseId;
    if (courseId == null) {
      _navigateToCourses(context);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/course-modules',
      _retainBaseRoutes,
      arguments: {
        'courseId': courseId,
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
