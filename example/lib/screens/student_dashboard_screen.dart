import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_repository.dart';
import 'package:flutter_unity_widget_example/services/module_view_model.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_repository.dart';
import 'package:flutter_unity_widget_example/widgets/student_widget_tree.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _dontShowAgain = false;
  bool _dontShowWelcomeAgain = false;
  bool _moduleListenerInitialized = false;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      const Text(
                        'Disclaimer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content Text
                      const Text(
                        'All cybersecurity modules and materials presented in this application are based on the official curriculum and content provided by STI College Caloocan. All credits and acknowledgments belong to STI College Caloocan. This app is intended for educational purposes only.',
                        style: TextStyle(
                          fontSize: 16,
                          color: royalBlue,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _dontShowAgain,
                            onChanged: (value) {
                              setState(() {
                                _dontShowAgain = value ?? false;
                              });
                            },
                            activeColor: royalBlue,
                            checkColor: Colors.white,
                            side: const BorderSide(color: royalBlue, width: 2),
                          ),
                          const Expanded(
                            child: Text(
                              'Don\'t show this again',
                              style: TextStyle(
                                color: royalBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Next Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if (_dontShowAgain) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('dont_show_disclaimer', true);
                            }
                            // Show welcome dialog after disclaimer
                            _showWelcomeDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: royalBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Image.asset(
                            'assets/images/welcome_robot.png', // <-- your image path
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Welcome to the CyberAR App',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: royalBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Content Text
                      const Text(
                        'Need help navigating the app? You can view the App Guide from the menu to learn how to navigate and use the features of this app.',
                        style: TextStyle(
                          fontSize: 16,
                          color: royalBlue,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _dontShowWelcomeAgain,
                            onChanged: (value) {
                              setState(() {
                                _dontShowWelcomeAgain = value ?? false;
                              });
                            },
                            activeColor: royalBlue,
                            checkColor: Colors.white,
                            side: const BorderSide(color: royalBlue, width: 2),
                          ),
                          const Expanded(
                            child: Text(
                              'Don\'t show this again',
                              style: TextStyle(
                                color: royalBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Go to App Guide Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if (_dontShowWelcomeAgain) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('dont_show_welcome', true);
                            }
                            studentPageNotifier.value = 3;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: royalBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Go to App Guide',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Show disclaimer dialog after a short delay to ensure the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final dontShowDisclaimer = prefs.getBool('dont_show_disclaimer') ?? false;

      if (!dontShowDisclaimer) {
        _showDisclaimerDialog();
      } else {
        // Check if welcome dialog should be shown
        final dontShowWelcome = prefs.getBool('dont_show_welcome') ?? false;
        if (!dontShowWelcome) {
          _showWelcomeDialog();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_moduleListenerInitialized) {
      final moduleViewModel = context.read<ModuleViewModel>();
      moduleViewModel.listenToModules();
      _moduleListenerInitialized = true;
    }
  }

  //! VIEW ALL COURSES
  Future<void> _handleViewAllCourses(
      BuildContext context, List<ModuleModel> courses) async {
    // final moduleViewModel = context.read<ModuleViewModel>();
    // final courses = moduleViewModel.modules;
    final userId = FirebaseService.currentUsersId;

    if (userId == null || courses.isEmpty) {
      // No courses, navigate to courses screen
      studentPageNotifier.value = 1;
      return;
    }

    // Check for course in progress using similar logic to _CoursesInProgressSection
    final assessmentRepository = AssessmentRepository();
    final quizAttemptRepository = QuizAttemptRepository();

    for (final course in courses) {
      final lessons = course.lessons;
      final totalLessons = lessons.length;
      final completedCount = lessons
          .where((lesson) =>
              (lesson.status[userId] ?? 'not_started') == 'completed')
          .length;
      final bool hasLessons = totalLessons > 0;
      final bool partialProgress =
          completedCount > 0 && completedCount < totalLessons;
      final bool allLessonsCompleted =
          hasLessons && completedCount == totalLessons;

      if (partialProgress) {
        // Course in progress - navigate to course modules screen without opening lesson
        Navigator.of(context).pushNamed(
          '/course-modules',
          arguments: {
            'courseId': course.id,
            // Don't pass initialLessonIndex to avoid auto-opening lesson
          },
        );
        return;
      }

      // Check if assessment needs to be resumed
      final assessment =
          await assessmentRepository.fetchFirstAssessmentByModule(course.title);

      AssessmentModel? courseAssessment;
      if (assessment != null && assessment.documentId != null) {
        courseAssessment = assessment;
      }

      final attempt = courseAssessment != null
          ? await quizAttemptRepository.getQuizAttempt(
              userId,
              courseAssessment.documentId!,
            )
          : null;

      final bool quizAttempted = attempt != null &&
          attempt.scores.isNotEmpty &&
          attempt.bestScore >= 0;

      final int passingScore = courseAssessment != null
          ? (courseAssessment.questions.length * 0.6).ceil()
          : 0;
      final bool quizPassed =
          attempt != null && attempt.bestScore >= passingScore;

      final bool courseFullyCompleted = (allLessonsCompleted || !hasLessons) &&
          (courseAssessment == null || quizPassed || !hasLessons);

      // If all lessons completed but assessment not passed, navigate to course modules
      if (allLessonsCompleted && courseAssessment != null && !quizPassed) {
        Navigator.of(context).pushNamed(
          '/course-modules',
          arguments: {
            'courseId': course.id,
            // Don't pass initialLessonIndex to avoid auto-opening lesson
          },
        );
        return;
      }

      // If course has been attempted but no lessons completed
      if (completedCount == 0 && quizAttempted) {
        Navigator.of(context).pushNamed(
          '/course-modules',
          arguments: {
            'courseId': course.id,
            // Don't pass initialLessonIndex to avoid auto-opening lesson
          },
        );
        return;
      }

      // If course is not fully completed and has progress
      if (!courseFullyCompleted && (completedCount > 0 || quizAttempted)) {
        Navigator.of(context).pushNamed(
          '/course-modules',
          arguments: {
            'courseId': course.id,
            // Don't pass initialLessonIndex to avoid auto-opening lesson
          },
        );
        return;
      }
    }

    // No course in progress, navigate to courses screen
    studentPageNotifier.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.read<ModuleViewModel>().modules;
    return Scaffold(
      backgroundColor: yellowish,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const SizedBox(height: 10),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: royalBlue,
              ),
            ),
            const Text(
              'Student!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: royalBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start exploring and enhance your cybersecurity knowledge today!',
              style: TextStyle(
                fontSize: 16,
                color: royalBlue,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            // Courses in Progress Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Courses in Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: royalBlue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _handleViewAllCourses(context, courses);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 16,
                              color: royalBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _CoursesInProgressSection(userId: FirebaseService.currentUsersId),
            const SizedBox(height: 16),

            // Cyber News Section

            const Text(
              'Cyber News',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: royalBlue,
              ),
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: royalBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Image area
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        child: Image.asset(
                          'assets/images/cybersecurity_phil.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Understanding modes-of-threat in DeepSeek and other AI technologies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              studentPageNotifier.value = 2;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: royalBlue,
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Colors.white, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Read More',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CoursesInProgressSection extends StatelessWidget {
  final String? userId;

  const _CoursesInProgressSection({required this.userId});

  static const Color _cardBlue = Color(0xFF1E3A8A);

  static final AssessmentRepository _assessmentRepository =
      AssessmentRepository();

  static final QuizAttemptRepository _quizAttemptRepository =
      QuizAttemptRepository();

  int _nextLessonIndex(ModuleModel course) {
    if (userId == null) return 0;
    for (var i = 0; i < course.lessons.length; i++) {
      final status = course.lessons[i].status[userId] ?? 'not_started';
      if (status != 'completed') {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModuleViewModel>(
      builder: (context, moduleViewModel, child) {
        final courses = moduleViewModel.modules;

        if (userId == null || courses.isEmpty) {
          return _EmptyCoursesCard(
            color: _cardBlue,
            message:
                'Looks like you haven\'t started a course yet. Browse the Course section in the menu and pick a topic to begin!',
          );
        }

        return FutureBuilder<_ResumeFetchResult>(
          future: _determineResumeInfo(courses),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }

            final result = snapshot.data;

            if (result == null) {
              return const SizedBox.shrink();
            }

            if (!result.hasProgress) {
              return _EmptyCoursesCard(
                color: _cardBlue,
                message:
                    'Looks like you haven\'t started a course yet. Browse the Course section in the menu and pick a topic to begin!',
              );
            }

            if (result.resumeInfo != null) {
              return _buildResumeCard(context, result.resumeInfo!);
            }

            if (result.allCompleted) {
              return _EmptyCoursesCard(
                color: _cardBlue,
                message: 'Great job! You have completed all available courses.',
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Future<_ResumeFetchResult> _determineResumeInfo(
      List<ModuleModel> courses) async {
    if (userId == null) {
      return const _ResumeFetchResult();
    }

    bool hasProgress = false;
    bool allPreviousCoursesCompleted = true;
    bool allCompleted = true;

    for (final course in courses) {
      final lessons = course.lessons;
      final totalLessons = lessons.length;
      final completedCount = lessons
          .where((lesson) =>
              (lesson.status[userId] ?? 'not_started') == 'completed')
          .length;
      final bool hasLessons = totalLessons > 0;
      final bool partialProgress =
          completedCount > 0 && completedCount < totalLessons;
      final bool allLessonsCompleted =
          hasLessons && completedCount == totalLessons;

      if (completedCount > 0) {
        hasProgress = true;
      }

      if (partialProgress) {
        final nextIndex = _nextLessonIndex(course);
        return _ResumeFetchResult(
          resumeInfo: _ResumeInfo(
            course: course,
            resumeQuiz: false,
            lessonIndex: nextIndex,
            subtitle: 'Resume at Module ${nextIndex + 1}',
            buttonLabel: 'Resume Course',
          ),
          hasProgress: true,
          allCompleted: false,
        );
      }

      final assessment = await _assessmentRepository
          .fetchFirstAssessmentByModule(course.title);

      AssessmentModel? courseAssessment;

      if (assessment != null && assessment.documentId != null) {
        courseAssessment = assessment;
      }

      final attempt = courseAssessment != null
          ? await _quizAttemptRepository.getQuizAttempt(
              userId!,
              courseAssessment.documentId!,
            )
          : null;

      final bool quizAttempted = attempt != null &&
          attempt.scores.isNotEmpty &&
          attempt.bestScore >= 0;
      if (quizAttempted) {
        hasProgress = true;
      }

      final int passingScore = courseAssessment != null
          ? (courseAssessment.questions.length * 0.6).ceil()
          : 0;
      final bool quizPassed =
          attempt != null && attempt.bestScore >= passingScore;

      final bool courseFullyCompleted = (allLessonsCompleted || !hasLessons) &&
          (courseAssessment == null || quizPassed || !hasLessons);

      final bool courseNotStarted = completedCount == 0 && !quizAttempted;

      // If course is fully completed, skip it and continue to next course
      if (courseFullyCompleted) {
        // Mark that we've completed previous courses for the next iteration
        continue;
      }

      // If assessment has been attempted but no lessons completed, show course to resume
      // This handles the case where user attempted assessment without completing lessons
      // Check this early so we catch it before setting flags
      if (completedCount == 0 && quizAttempted) {
        return _ResumeFetchResult(
          resumeInfo: _ResumeInfo(
            course: course,
            resumeQuiz: false,
            lessonIndex: 0,
            subtitle: 'Resume Course - Start with Module 1',
            buttonLabel: 'Resume Course',
          ),
          hasProgress: true,
          allCompleted: false,
        );
      }

      // Check if it's a new course that hasn't been started
      // and all previous courses are completed
      if (courseNotStarted && allPreviousCoursesCompleted) {
        // All previous courses are completed, and this course hasn't been started
        return _ResumeFetchResult(
          resumeInfo: _ResumeInfo(
            course: course,
            resumeQuiz: false,
            lessonIndex: 0,
            subtitle: 'Ready to begin with Module 1',
            buttonLabel: 'Start Course',
          ),
          hasProgress: hasProgress,
          allCompleted: false,
        );
      }

      // If course has been started but is not fully completed
      if (!courseFullyCompleted && !courseNotStarted) {
        allCompleted = false;
        allPreviousCoursesCompleted = false;
      }

      // If all lessons are completed but assessment is not passed
      if (allLessonsCompleted && courseAssessment != null && !quizPassed) {
        return _ResumeFetchResult(
          resumeInfo: _ResumeInfo(
            course: course,
            resumeQuiz: true,
            assessment: courseAssessment,
            subtitle: 'Assessment ready to resume',
            buttonLabel: 'Resume Quiz',
          ),
          hasProgress: true,
          allCompleted: false,
        );
      }
    }

    return _ResumeFetchResult(
      resumeInfo: null,
      hasProgress: hasProgress,
      allCompleted: allCompleted && hasProgress,
    );
  }

  Widget _buildResumeCard(BuildContext context, _ResumeInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/cyber_sec.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      info.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (info.resumeQuiz) {
                  Navigator.of(context).pushNamed(
                    '/quiz-starter',
                    arguments: {
                      'assessment': info.assessment,
                      'assessmentId': info.assessment?.documentId,
                      'courseId': info.course.id,
                      'moduleTitle': info.course.title,
                      'forceFetchAssessment': info.assessment == null,
                    },
                  );
                } else {
                  Navigator.of(context).pushNamed(
                    '/course-modules',
                    arguments: {
                      'courseId': info.course.id,
                      'initialLessonIndex': info.lessonIndex ?? 0,
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _cardBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                info.buttonLabel,
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
}

class _ResumeInfo {
  final ModuleModel course;
  final bool resumeQuiz;
  final int? lessonIndex;
  final AssessmentModel? assessment;
  final String subtitle;
  final String buttonLabel;

  const _ResumeInfo({
    required this.course,
    required this.resumeQuiz,
    this.lessonIndex,
    this.assessment,
    required this.subtitle,
    required this.buttonLabel,
  });
}

class _ResumeFetchResult {
  final _ResumeInfo? resumeInfo;
  final bool hasProgress;
  final bool allCompleted;

  const _ResumeFetchResult({
    this.resumeInfo,
    this.hasProgress = false,
    this.allCompleted = false,
  });
}

class _EmptyCoursesCard extends StatelessWidget {
  final Color color;
  final String? message;

  const _EmptyCoursesCard({required this.color, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/courses.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message ??
                  'Looks like you haven\'t started a course yet. Browse the Course section in the menu and pick a topic to begin!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
