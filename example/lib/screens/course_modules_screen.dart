import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';
import 'package:flutter_unity_widget_example/services/module_view_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_view_model.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_view_model.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/model/quiz_attempt_model.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';

class CourseModulesScreen extends StatefulWidget {
  //! COURSE ID
  final String courseId;

  //! OPTIONAL INITIAL LESSON TO OPEN
  final int? initialLessonIndex;

  const CourseModulesScreen({
    super.key,
    required this.courseId,
    this.initialLessonIndex,
  });

  @override
  State<CourseModulesScreen> createState() => _CourseModulesScreenState();
}

class _CourseModulesScreenState extends State<CourseModulesScreen> {
  Timer? _regenerationTimer;
  bool _initialLessonOpened = false;

  @override
  void initState() {
    super.initState();
    //! SCROLL CONTROLLER
    _scrollController = ScrollController();
    //! LISTEN TO MODULE
    final moduleViewModel = context.read<ModuleViewModel>();
    moduleViewModel.listenToModule(widget.courseId);

    //! Start timer to update UI every second for countdown
    _regenerationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh UI to update countdown timers
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //! LISTEN TO ASSESSMENT - Need to wait for course data to get the title
    final moduleViewModel = context.watch<ModuleViewModel>();
    //! LISTEN TO ASSESSMENT
    final assessmentViewModel = context.read<AssessmentViewModel>();

    //! IF CURRENT MODULE IS NOT NULL, LISTEN TO ASSESSMENT
    if (moduleViewModel.currentModule != null) {
      //! LISTEN TO ASSESSMENT BY MODULE TITLE
      assessmentViewModel
          .listenToAssessmentByModule(moduleViewModel.currentModule!.title);
    }

    _maybeOpenInitialLesson(moduleViewModel.currentModule);
  }

  void _maybeOpenInitialLesson(ModuleModel? course) {
    if (_initialLessonOpened || course == null) {
      return;
    }

    final index = widget.initialLessonIndex;
    if (index == null) {
      _initialLessonOpened = true;
      return;
    }

    final userId = FirebaseService.currentUsersId;
    if (userId == null) {
      _initialLessonOpened = true;
      return;
    }

    if (index < 0 || index >= course.lessons.length) {
      _initialLessonOpened = true;
      return;
    }

    final hasAnyCompleted = course.lessons.any((lesson) {
      final status = lesson.status[userId] ?? 'not_started';
      return status == 'completed';
    });

    if (!hasAnyCompleted) {
      _initialLessonOpened = true;
      return;
    }

    _initialLessonOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        '/module-details',
        arguments: {
          'courseId': widget.courseId,
          'currentIndex': index,
        },
      );
    });
  }

  //! SCROLL CONTROLLER
  late ScrollController _scrollController;

  //! COLORS
  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color yellowish = Color(0xFFFFF59D);

  //! DISPOSE
  @override
  void dispose() {
    _scrollController.dispose();
    _regenerationTimer?.cancel();
    super.dispose();
  }

  //! BUILD STATUS WIDGET
  Widget _buildStatusWidget(String status) {
    //! SWITCH CASE FOR STATUS
    switch (status) {
      //! IN PROGRESS
      case 'in_progress':
        return Row(
          children: [
            const Icon(
              Icons.hourglass_empty,
              color: Colors.yellow,
              size: 16,
            ),
            const SizedBox(width: 4),
            const Text(
              'In Progress',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      //! COMPLETED
      case 'completed':
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Completed',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case 'not_started': //! NOT STARTED
      default:
        return const SizedBox.shrink(); //! BLANK
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModuleViewModel>(
      builder: (context, moduleViewModel, child) {
        //! COURSE
        final course = moduleViewModel.currentModule;

        _maybeOpenInitialLesson(course);

        //! CURRENT USER ID
        final currentUserId = FirebaseService.currentUsersId ?? '';

        return Scaffold(
          backgroundColor: yellowish,
          //! DRAWER
          drawer: const AppDrawer(),

          //! APP BAR
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

          body: course == null
              //! COURSE IS NULL THEN DISPLAY THIS
              ? Container(
                  color: yellowish,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated security shield icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: royalBlue,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: royalBlue.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 24),

                        //! LOADING TEXT
                        const Text(
                          'Loading Course Modules...',
                          style: TextStyle(
                            color: royalBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        //! LOADING SPINNER
                        const CircularProgressIndicator(
                          color: royalBlue,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    //! BACK BUTTON
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pop(); //! POP THE CURRENT ROUTE
                            },
                            child: const Text(
                              '< Back',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    //! COURSE TITLE SECTION
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: royalBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(${course.lessons.length} Modules)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    //! QUIZ LIST
                    Expanded(
                      child: Consumer<AssessmentViewModel>(
                        builder: (context, assessmentViewModel, child) {
                          //! GET ALL ASSESSMENTS/QUIZZES
                          final assessments =
                              assessmentViewModel.currentAssessments;

                          //! GET THE TOTAL ITEMS (LESSONS + ASSESSMENTS)
                          final totalItems =
                              course.lessons.length + assessments.length;

                          return Stack(
                            children: [
                              ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                itemCount: totalItems,
                                itemBuilder: (context, index) {
                                  //! Check if this is a quiz card (after all lessons)
                                  if (index >= course.lessons.length) {
                                    // Calculate which assessment this is
                                    //! GET THE ASSESSMENT INDEX
                                    final assessmentIndex =
                                        index - course.lessons.length;

                                    //! GET THE ASSESSMENT
                                    final assessment =
                                        assessments[assessmentIndex];

                                    //! Quiz Card with Retry System
                                    //! Create a unique key for this assessment's quiz attempt listener
                                    return _QuizCard(
                                      assessment: assessment,
                                      courseId: widget.courseId,
                                      assessmentIndex: assessmentIndex +
                                          1, // 1-indexed for display
                                    );
                                  }

                                  //! REGULAR MODULE CARD
                                  //! GET THE LESSON
                                  final lesson = course.lessons[index];

                                  //! GET THE LESSON STATUS
                                  final lessonStatus =
                                      lesson.status[currentUserId] ??
                                          'not_started';

                                  //! GESTURE DETECTOR FOR MODULE CARD
                                  return GestureDetector(
                                    onTap: () {
                                      //! NAVIGATE TO MODULE DETAILS - PASS ONLY COURSE ID AND CURRENT INDEX
                                      Navigator.of(context).pushNamed(
                                        '/module-details',
                                        arguments: {
                                          'courseId': widget.courseId,
                                          'currentIndex': index,
                                        },
                                      );
                                    },
                                    //! CONTAINER FOR MODULE CARD
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: royalBlue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          // Module Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //! MODULE NUMBER
                                                Text(
                                                  'Module ${index + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),

                                                //! MODULE TITLE
                                                Text(
                                                  lesson.title,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Status
                                          _buildStatusWidget(lessonStatus),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              //! ARROW UP
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        yellowish.withValues(alpha: 0.8),
                                        yellowish.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.keyboard_arrow_up,
                                      color: royalBlue,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              //! ARROW DOWN
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        yellowish.withValues(alpha: 0.8),
                                        yellowish.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: royalBlue,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// QUIZ CARD WIDGET
class _QuizCard extends StatefulWidget {
  //! ASSESSMENT
  final AssessmentModel assessment;
  //! COURSE ID
  final String courseId;
  //! ASSESSMENT INDEX
  final int assessmentIndex;

  const _QuizCard({
    required this.assessment,
    required this.courseId,
    required this.assessmentIndex,
  });

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  //! COLORS
  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  Widget build(BuildContext context) {
    //! CURRENT USER ID
    final currentUserId = FirebaseService.currentUsersId;
    //! ASSESSMENT ID
    final assessmentId = widget.assessment.documentId;

    //! SAFETY CHECK
    if (currentUserId == null || assessmentId == null) {
      return const SizedBox.shrink();
    }

    //! USE STREAM BUILDER TO INDEPENDENTLY TRACK THIS ASSESSMENT'S QUIZ ATTEMPTS.
    return StreamBuilder<QuizAttemptModel?>(
      stream: context
          .read<QuizAttemptViewModel>()
          .repository
          .listenToQuizAttempt(currentUserId, assessmentId),
      builder: (context, snapshot) {
        //! GET THE QUIZ ATTEMPT
        final quizAttempt = snapshot.data;
        //! HAS ATTEMPTED
        final hasAttempted =
            quizAttempt != null && quizAttempt.scores.isNotEmpty;
        //! HAS PERFECT SCORE
        final hasPerfectScore =
            quizAttempt?.hasPerfectScore(widget.assessment.questions.length) ??
                false;
        //! CAN ATTEMPT
        final canAttempt =
            quizAttempt?.canAttempt(widget.assessment.questions.length) ?? true;
        //! SHOW COOLDOWN
        final showCooldown = quizAttempt != null &&
            quizAttempt.isCooldownActive &&
            quizAttempt.remainingAttempts <= 0;

        //! GESTURE DETECTOR FOR QUIZ CARD
        return GestureDetector(
          onTap: canAttempt
              ? () {
                  //! NAVIGATE TO QUIZ STARTER WITH ASSESSMENT DATA
                  Navigator.of(context).pushNamed(
                    '/quiz-starter',
                    arguments: {
                      'assessment': widget.assessment,
                      'courseId': widget.courseId,
                      'assessmentId': widget.assessment.documentId,
                    },
                  );
                }
              : null,
          //! OPACITY FOR QUIZ CARD
          child: Opacity(
            opacity: canAttempt ? 1.0 : 0.7,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6, top: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade600,
                    Colors.deepOrange.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Quiz Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.quiz,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Quiz Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // 'ASSESSMENT ${widget.assessmentIndex}',
                              'ASSESSMENT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.assessment.questions.length} Questions',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            // Show score if attempted
                            if (hasAttempted) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Score: ${quizAttempt.latestScore!.score}/${widget.assessment.questions.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Button or Icon
                      if (canAttempt && !hasPerfectScore)
                        hasAttempted
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: yellowish,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  'Retake',
                                  style: TextStyle(
                                    color: royalBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 24,
                              )
                      else if (!canAttempt)
                        const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 22,
                        ),
                    ],
                  ),

                  //! STATUS MESSAGE AND REMAINING TRIES
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Perfect score message
                        if (hasPerfectScore)
                          const Text(
                            'You\'ve already achieved the perfect score for this quiz. Good job!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        // No attempts remaining - waiting for regeneration
                        else if (showCooldown)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'You\'ve used all your attempts for this quiz. Please wait 10 minutes before trying again.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Next retry in: ${quizAttempt.formattedCooldownTime}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        // Remaining tries (after some attempts used)
                        else if (hasAttempted)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining Tries: ${quizAttempt.remainingAttempts}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (quizAttempt.currentAttemptsUsed > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Next retry in: ${quizAttempt.formattedCooldownTime}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          )
                        // First time
                        else
                          const Text(
                            'Tap to Start Quiz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
