import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';
import 'package:flutter_unity_widget_example/services/module_view_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_repository.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_repository.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    //! LISTEN TO COURSES
    final moduleViewModel = context.read<ModuleViewModel>();
    moduleViewModel.listenToModules();
  }

  @override
  void didUpdateWidget(CoursesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear cache when widget updates to recalculate status
    _courseStatusCache.clear();
  }

  //? COLORS
  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color yellowish = Color(0xFFFFF59D);

  Map<String, bool> _expandedCourses = {};
  Map<String, String?> _courseStatusCache =
      {}; // Cache for module+assessment status

  //! TOGGLE COURSE METHOD
  void _toggleCourse(String courseTitle) {
    //! SET STATE
    setState(() {
      _expandedCourses[courseTitle] = !(_expandedCourses[courseTitle] ?? false);
    });
  }

  //! GET COMPLETE COURSE STATUS (INCLUDING ASSESSMENTS)
  Future<String> _getCompleteCourseStatus(
      ModuleModel course, String userId) async {
    try {
      // ALL LESSONS COMPLETED CHECK
      final lessonStatus = course.getStatusForUser(userId);

      // IF LESSONS AREN'T ALL COMPLETED, RETURN EARLY
      if (lessonStatus != 'completed') {
        return lessonStatus;
      }

      // All lessons completed - now check assessments
      final assessmentRepo = AssessmentRepository();

      final assessments =
          await assessmentRepo.listenToAssessmentsByModule(course.title).first;

      // If no assessments, course is completed based on lessons only
      if (assessments.isEmpty) {
        return 'completed';
      }

      // Check if all assessments have been passed (>= 60%)
      final quizAttemptRepo = QuizAttemptRepository();
      bool allAssessmentsPassed = true;

      for (var assessment in assessments) {
        if (assessment.documentId == null) continue;

        final quizAttempt = await quizAttemptRepo.getQuizAttempt(
          userId,
          assessment.documentId!,
        );

        // If no attempt recorded or best score below passing threshold, not completed
        if (quizAttempt == null || quizAttempt.scores.isEmpty) {
          allAssessmentsPassed = false;
          break;
        }

        final passingScore = (assessment.questions.length * 0.6).ceil();
        if (quizAttempt.bestScore < passingScore) {
          allAssessmentsPassed = false;
          break;
        }
      }

      return allAssessmentsPassed ? 'completed' : 'in_progress';
    } catch (e) {
      return course.getStatusForUser(userId);
    }
  }

  //! GET STATUS COLOR
  Color _getStatusColor(String status, bool isUnlocked) {
    if (!isUnlocked) return Colors.grey.shade600; // Locked
    switch (status) {
      case 'completed':
        return Colors.green.shade600;
      case 'in_progress':
        return Colors.orange.shade600;
      case 'not_started':
      default:
        return Colors.blue.shade600; // Not started but unlocked
    }
  }

  //! GET STATUS ICON
  IconData _getStatusIcon(String status, bool isUnlocked) {
    if (!isUnlocked) return Icons.lock; // Locked

    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle_filled;
      case 'not_started':
      default:
        return Icons.lock_open; // Not started but unlocked
    }
  }

  //! GET STATUS TEXT
  String _getStatusText(String status, bool isUnlocked) {
    if (!isUnlocked) return 'Locked';

    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'not_started':
      default:
        return 'Not Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    //! Note: In Firebase, 'modules' are our 'courses', and 'lessons' are our 'modules'
    return Consumer<ModuleViewModel>(
      builder: (context, moduleViewModel, child) {
        //! COURSES
        final courses = moduleViewModel.modules;

        //! CURRENT USER ID
        final currentUserId = FirebaseService.currentUsersId ?? '';

        final validCourseIds = courses.map((course) => course.id).toSet();
        _courseStatusCache
            .removeWhere((courseId, _) => !validCourseIds.contains(courseId));

        return Column(
          children: [
            Expanded(
              child: Container(
                color: yellowish,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      //! AVAILABLE COURSES TEXT HEADER
                      const Text(
                        'Available Courses',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),

                      const SizedBox(height: 20),

                      //! SHOW MESSAGE IF NO COURSES ARE AVAILABLE
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              courses.isEmpty
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.school_outlined,
                                              size: 80,
                                              color: royalBlue.withValues(
                                                  alpha: 0.5),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No courses available yet',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: royalBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )

                                  //! IF COURSES ARE AVAILABLE, SHOW THEM IN A LIST
                                  : Column(
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              courses.length, //! COURSE LENGTH
                                          itemBuilder: (context, index) {
                                            final course = courses[
                                                index]; //! SINGLE COURSE

                                            final isExpanded = _expandedCourses[
                                                    course.title] ??
                                                false; //! IS EXPANDED

                                            // Use FutureBuilder for async status calculation
                                            return FutureBuilder<String>(
                                              future: _getCompleteCourseStatus(
                                                  course, currentUserId),
                                              initialData: _courseStatusCache[
                                                      course.id] ??
                                                  course.getStatusForUser(
                                                      currentUserId),
                                              builder:
                                                  (context, statusSnapshot) {
                                                final courseStatus = statusSnapshot
                                                        .data ??
                                                    'not_started'; //! COURSE STATUS (lessons + assessments)

                                                // Cache the result
                                                if (statusSnapshot.hasData &&
                                                    statusSnapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                  _updateCourseStatus(
                                                      course.id, courseStatus);
                                                }

                                                //! CHECK IF PREVIOUS COURSE IS COMPLETED TO UNLOCK THIS ONE
                                                final isPreviousCourseCompleted =
                                                    index == 0
                                                        ? true
                                                        : (_courseStatusCache[
                                                                courses[index -
                                                                        1]
                                                                    .id] ==
                                                            'completed');

                                                final isUnlocked = index == 0 ||
                                                    courseStatus ==
                                                        'in_progress' ||
                                                    courseStatus ==
                                                        'completed' ||
                                                    isPreviousCourseCompleted;

                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 16),
                                                  child: Column(
                                                    children: [
                                                      //! COURSE CARD HEADER SECTION
                                                      GestureDetector(
                                                        onTap: isUnlocked
                                                            ? () => _toggleCourse(
                                                                course
                                                                    .title) //! TOGGLE COURSE (only if unlocked)
                                                            : null, // Not tappable if locked
                                                        child: Opacity(
                                                          opacity:
                                                              isUnlocked //! OPACITY IF UNLOCKED
                                                                  ? 1.0
                                                                  : 0.6, // Dimmed if locked
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: royalBlue,
                                                              borderRadius:
                                                                  isExpanded
                                                                      ? const BorderRadius
                                                                          .only(
                                                                          topLeft:
                                                                              Radius.circular(12),
                                                                          topRight:
                                                                              Radius.circular(12),
                                                                        )
                                                                      : BorderRadius
                                                                          .circular(
                                                                              12),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                // Security Shield Icon
                                                                Container(
                                                                  width: 80,
                                                                  height: 80,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          2),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withValues(
                                                                            alpha:
                                                                                0.2),
                                                                  ),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/cyber_sec.png',
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                // Course Details
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      //! COURSE TITLE TEXT
                                                                      Text(
                                                                        course
                                                                            .title,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              4),
                                                                      //! COURSE NUMBER TEXT
                                                                      Text(
                                                                        'Course: ${course.moduleNumber}',
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      //! STATUS CARD SECTION
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              6,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: _getStatusColor(
                                                                              courseStatus,
                                                                              isUnlocked),
                                                                          borderRadius:
                                                                              BorderRadius.circular(16),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.white.withValues(alpha: 0.3),
                                                                            width:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Icon(
                                                                              _getStatusIcon(courseStatus, isUnlocked),
                                                                              color: Colors.white,
                                                                              size: 14,
                                                                            ),
                                                                            const SizedBox(width: 6),
                                                                            Flexible(
                                                                              child: FittedBox(
                                                                                fit: BoxFit.scaleDown,
                                                                                child: Text(
                                                                                  _getStatusText(courseStatus, isUnlocked),
                                                                                  style: const TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontSize: 12,
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
                                                                //! IF NOT UNLOCKED, SHOW LOCK ICON
                                                                if (!isUnlocked)
                                                                  const Icon(
                                                                    Icons.lock,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 24,
                                                                  )
                                                                //! IF UNLOCKED, SHOW EXPAND/COLLAPSE ICON
                                                                else
                                                                  // Expand/Collapse Icon
                                                                  Icon(
                                                                    isExpanded
                                                                        ? Icons
                                                                            .keyboard_arrow_up
                                                                        : Icons
                                                                            .keyboard_arrow_down,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 24,
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      //! EXPANDED COURSE DETAILS SECTION
                                                      if (isExpanded &&
                                                          isUnlocked)
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(12),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            border: Border.all(
                                                                color:
                                                                    royalBlue,
                                                                width: 1),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              //! COURSE DESCRIPTION TEXT HEADER
                                                              const Text(
                                                                'Course Description:',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      royalBlue,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),

                                                              //! DESCRIPTION OF COURSE
                                                              Text(
                                                                course
                                                                    .description,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),

                                                              const SizedBox(
                                                                  height: 16),

                                                              //! MODULES TEXT HEADER
                                                              const Text(
                                                                'Modules:',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      royalBlue,
                                                                ),
                                                              ),

                                                              const SizedBox(
                                                                  height: 12),

                                                              //! MODULE LESSONS LIST
                                                              ...course.lessons
                                                                  .asMap()
                                                                  .entries
                                                                  .map<Widget>(
                                                                      (entry) {
                                                                //! MODULE INDEX
                                                                final moduleIndex =
                                                                    entry.key;
                                                                //! MODULE ITEM
                                                                final moduleItem =
                                                                    entry.value;

                                                                //! MODULE ITEM STATUS
                                                                final moduleItemStatus =
                                                                    moduleItem.status[
                                                                            currentUserId] ??
                                                                        'not_started';

                                                                return Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          4),
                                                                  child: Row(
                                                                    children: [
                                                                      //! MODULE ITEM STATUS ICON
                                                                      Icon(
                                                                        moduleItemStatus ==
                                                                                'completed'
                                                                            ? Icons.check_circle
                                                                            : Icons.play_circle_outline,
                                                                        color: moduleItemStatus ==
                                                                                'completed'
                                                                            ? Colors.green
                                                                            : Colors.orange,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      //! MODULE ITEM TITLE LIST
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'Module ${moduleIndex + 1}: ${moduleItem.title}',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                royalBlue,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              }).toList(),
                                                              const SizedBox(
                                                                  height: 16),

                                                              //! BUTTON TO GO TO COURSE MODULES SCREEN
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    final initialLessonIndex =
                                                                        _findFirstIncompleteLessonIndex(
                                                                      course,
                                                                      currentUserId,
                                                                    );

                                                                    Navigator.of(
                                                                            context)
                                                                        .pushNamed(
                                                                      '/course-modules',
                                                                      arguments: {
                                                                        'courseId':
                                                                            course.id,
                                                                        if (initialLessonIndex !=
                                                                            null)
                                                                          'initialLessonIndex':
                                                                              initialLessonIndex,
                                                                      },
                                                                    );
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        royalBlue,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                  ),
                                                                  child: Text(courseStatus ==
                                                                              'completed' ||
                                                                          courseStatus ==
                                                                              'in_progress'
                                                                      ? 'Continue Course'
                                                                      : 'Start Course'),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ); // Close FutureBuilder
                                          },
                                        ),

                                        //! OVERALL RESULT TEXT BELOW THE LISTVIEW
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            final allCoursesCompleted =
                                                courses.isNotEmpty &&
                                                    courses.every((course) =>
                                                        _courseStatusCache[
                                                            course.id] ==
                                                        'completed');

                                            Navigator.of(context).pushNamed(
                                              '/overall-result',
                                              arguments: {
                                                'allCourseDone':
                                                    allCoursesCompleted,
                                              },
                                            );
                                          },
                                          child: const Text(
                                            'VIEW OVERALL RESULT',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: royalBlue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateCourseStatus(String courseId, String status) {
    if (_courseStatusCache[courseId] == status) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _courseStatusCache[courseId] = status;
      });
    });
  }

  int? _findFirstIncompleteLessonIndex(
      ModuleModel course, String currentUserId) {
    for (var i = 0; i < course.lessons.length; i++) {
      final lesson = course.lessons[i];
      final status = lesson.status[currentUserId] ?? 'not_started';
      if (status != 'completed') {
        return i;
      }
    }
    return null;
  }
}
