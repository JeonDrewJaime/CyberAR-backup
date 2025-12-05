import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_repository.dart';
import 'package:flutter_unity_widget_example/services/module_view_model.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_unity_widget_example/model/cyber_tip_model.dart';
import 'dialog_flashcards.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class ModuleDetailsScreen extends StatefulWidget {
  //! COURSE ID
  final String courseId;

  //! CURRENT INDEX
  final int currentIndex;

  const ModuleDetailsScreen({
    super.key,
    required this.courseId,
    required this.currentIndex,
  });

  @override
  State<ModuleDetailsScreen> createState() => _ModuleDetailsScreenState();
}

class _ModuleDetailsScreenState extends State<ModuleDetailsScreen> {
  double _textSize = 16.0;
  late ScrollController _scrollController;

  //! DON'T SHOW TIPS AGAIN
  bool _dontShowTipsAgain = false;

  //! DON'T SHOW AR AGAIN
  bool _dontShowARAgain = false;

  SharedPreferences? _preferences;

  static const String _tipsDialogPrefKey = 'module_details_hide_tips_dialog';
  static const String _arDialogPrefKey = 'module_details_hide_ar_dialog';

  //! HAS SCROLLED TO BOTTOM
  bool _hasScrolledToBottom = false;

  //! SUPER SCROLL
  static const double _superScrollTriggerThreshold = 40.0;
  double _topOverscrollExtent = 0;
  double _bottomOverscrollExtent = 0;
  bool _isSuperScrollOnCooldown = false;
  Timer? _superScrollCooldownTimer;

  //! ASSESSMENT & QUIZ STATUS
  final AssessmentRepository _assessmentRepository = AssessmentRepository();
  final QuizAttemptRepository _quizAttemptRepository = QuizAttemptRepository();
  StreamSubscription<List<AssessmentModel>>? _assessmentSubscription;
  AssessmentModel? _currentAssessment;
  String? _lastAssessmentModuleTitle;
  bool _canTakeQuiz = true;
  bool _isCheckingQuizAvailability = false;

  // Dark blue color
  static const Color darkBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    //! LISTEN TO MODULE
    final moduleViewModel = context.read<ModuleViewModel>();
    moduleViewModel.listenToModule(widget.courseId);

    //! SHOW TIPS DIALOG WHEN MODULE DETAILS PAGE IS OPENED
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDialogs();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final moduleViewModel = context.watch<ModuleViewModel>();
    final course = moduleViewModel.currentModule;

    if (course != null && course.title != _lastAssessmentModuleTitle) {
      _lastAssessmentModuleTitle = course.title;
      _listenToAssessments(course.title);
    }
  }

  Future<void> _initializeDialogs() async {
    await _loadDialogPreferences();
    _showTipsDialog();
    //! CHECK IF CONTENT IS SCROLLABLE AFTER LAYOUT
    _checkIfScrollable();
  }

  Future<void> _loadDialogPreferences() async {
    _preferences ??= await SharedPreferences.getInstance();
    final hideTips = _preferences?.getBool(_tipsDialogPrefKey) ?? false;
    final hideAR = _preferences?.getBool(_arDialogPrefKey) ?? false;

    if (!mounted) return;

    setState(() {
      _dontShowTipsAgain = hideTips;
      _dontShowARAgain = hideAR;
    });
  }

  void _listenToAssessments(String moduleTitle) {
    _assessmentSubscription?.cancel();
    _assessmentSubscription = _assessmentRepository
        .listenToAssessmentsByModule(moduleTitle)
        .listen((assessments) async {
      if (!mounted) return;

      setState(() {
        _currentAssessment = assessments.isNotEmpty ? assessments.first : null;
      });

      await _evaluateQuizAvailability();
    });
  }

  Future<void> _evaluateQuizAvailability() async {
    final userId = FirebaseService.currentUsersId;
    if (!mounted) return;

    setState(() {
      _isCheckingQuizAvailability = true;
    });

    if (_currentAssessment == null || _currentAssessment?.documentId == null) {
      setState(() {
        _canTakeQuiz = false;
        _isCheckingQuizAvailability = false;
      });
      return;
    }

    if (userId == null) {
      setState(() {
        _canTakeQuiz = false;
        _isCheckingQuizAvailability = false;
      });
      return;
    }

    try {
      final attempt = await _quizAttemptRepository.getQuizAttempt(
        userId,
        _currentAssessment!.documentId!,
      );

      final passingScore = (_currentAssessment!.questions.length * 0.6).ceil();
      final canTake = attempt == null || attempt.bestScore < passingScore;

      if (!mounted) return;
      setState(() {
        _canTakeQuiz = canTake;
        _isCheckingQuizAvailability = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _canTakeQuiz = true;
        _isCheckingQuizAvailability = false;
      });
    }
  }

  Future<void> _saveDialogPreference(String key, bool value) async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setBool(key, value);
  }

  //! Check if content is scrollable, if not auto-enable buttons
  void _checkIfScrollable() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        final position = _scrollController.position;
        //! IF CONTENT DOESN'T NEED SCROLLING (MAX SCROLL EXTENT IS 0 OR VERY SMALL)
        if (position.maxScrollExtent <= 10) {
          setState(() {
            _hasScrolledToBottom = true;
          });
          _markLessonAsCompleted();
        }
      }
    });
  }

  //! DISPOSE
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _assessmentSubscription?.cancel();
    _superScrollCooldownTimer?.cancel();
    super.dispose();
  }

  //! ON SCROLL
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;

    //! CHECK IF SCROLLED TO THE VERY BOTTOM
    if (position.pixels >= position.maxScrollExtent - 10) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
        _markLessonAsCompleted(); //! MARK AS COMPLETED WHEN REACHING BOTTOM
      }
    }
  }

  void _resetSuperScrollTracking() {
    _topOverscrollExtent = 0;
    _bottomOverscrollExtent = 0;
  }

  void _startSuperScrollCooldown() {
    _superScrollCooldownTimer?.cancel();
    _isSuperScrollOnCooldown = true;
    _superScrollCooldownTimer = Timer(const Duration(milliseconds: 600), () {
      _isSuperScrollOnCooldown = false;
    });
  }

  void _handleSuperScrollNavigation({
    required bool forward,
    required int totalLessons,
  }) {
    if (_isSuperScrollOnCooldown) return;

    if (forward) {
      if (_hasScrolledToBottom) {
        _navigateToNext(totalLessons);
      }
    } else if (widget.currentIndex > 0) {
      _navigateToPrevious();
    }

    _startSuperScrollCooldown();
    _resetSuperScrollTracking();
  }

  //! MARK LESSON AS COMPLETED
  Future<void> _markLessonAsCompleted() async {
    final moduleViewModel = context.read<ModuleViewModel>();
    final currentUserId = FirebaseService.currentUsersId;

    if (currentUserId != null && moduleViewModel.currentModule != null) {
      final currentLesson =
          moduleViewModel.currentModule!.lessons[widget.currentIndex];

      await moduleViewModel.updateLessonStatus(
        moduleId: widget.courseId,
        lessonId: currentLesson.id,
        userId: currentUserId,
        status: 'completed',
      );
    }
  }

  //! NAVIGATE TO PREVIOUS MODULE
  void _navigateToPrevious() {
    if (widget.currentIndex > 0) {
      Navigator.of(context).pushReplacementNamed(
        '/module-details',
        arguments: {
          'courseId': widget.courseId,
          'currentIndex': widget.currentIndex - 1,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the first module'),
        ),
      );
    }
  }

  //! NAVIGATE TO NEXT MODULE
  Future<void> _navigateToNext(int totalModules) async {
    final moduleViewModel = context.read<ModuleViewModel>();
    final course = moduleViewModel.currentModule;

    // Check if this is the final lesson in the course
    if (widget.currentIndex == totalModules - 1) {
      if (!_canTakeQuiz) {
        return;
      }

      AssessmentModel? assessment = _currentAssessment;

      if ((assessment == null || assessment.documentId == null) &&
          course != null) {
        assessment = await _assessmentRepository.fetchFirstAssessmentByModule(
          course.title,
        );

        if (!mounted) return;

        if (assessment != null) {
          setState(() {
            _currentAssessment = assessment;
          });
        }
      }

      if (assessment == null || assessment.documentId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assessment information not available.'),
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushNamed(
        '/quiz-starter',
        arguments: {
          'assessment': assessment,
          'assessmentId': assessment.documentId,
          'courseId': widget.courseId,
          'moduleTitle': course?.title,
        },
      );
    } else if (widget.currentIndex < totalModules - 1) {
      Navigator.of(context).pushReplacementNamed(
        '/module-details',
        arguments: {
          'courseId': widget.courseId,
          'currentIndex': widget.currentIndex + 1,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the last module'),
        ),
      );
    }
  }

//! GET PHISHING FLASHCARDS
  List<CyberTipModel> _getPhishingFlashcards() {
    return [
      CyberTipModel(
        imagePath: 'assets/images/phishing_1.png',
        order: 1,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_2.png',
        order: 2,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_3.png',
        order: 3,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_4.png',
        order: 4,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_5.png',
        order: 5,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_6.png',
        order: 6,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_7.png',
        order: 7,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_8.png',
        order: 8,
      ),
      CyberTipModel(
        imagePath: 'assets/images/phishing_9.png',
        order: 9,
      ),
    ];
  }

  //! GET RANSOMWARE FLASHCARDS
  List<CyberTipModel> _getRansomwareFlashcards() {
    return [
      CyberTipModel(
        imagePath: 'assets/images/ransomware_1.png',
        order: 1,
      ),
      CyberTipModel(
        imagePath: 'assets/images/ransomware_2.png',
        order: 2,
      ),
      CyberTipModel(
        imagePath: 'assets/images/ransomware_3.png',
        order: 3,
      ),
      CyberTipModel(
        imagePath: 'assets/images/ransomware_4.png',
        order: 4,
      ),
      CyberTipModel(
        imagePath: 'assets/images/ransomware_5.png',
        order: 5,
      ),
      CyberTipModel(
        imagePath: 'assets/images/ransomware_6.png',
        order: 6,
      ),
    ];
  }

  //! GET SOCIAL ENGINEERING FLASHCARDS
  List<CyberTipModel> _getSocialEngineeringFlashcards() {
    // Social engineering tips based on the images
    return [
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_1.png',
        order: 1,
      ),
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_2.png',
        order: 2,
      ),
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_3.png',
        order: 3,
      ),
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_4.png',
        order: 4,
      ),
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_5.png',
        order: 5,
      ),
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_6.png',
        order: 6,
      ),
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_7.png',
        order: 7,
      ),
      CyberTipModel(
        imagePath: 'assets/images/social_engineering_8.png',
        order: 8,
      ),
    ];
  }

  //! SHOW FLASHCARDS DIALOG
  void _showFlashcardsDialog(String lessonTitle) {
    // Check if lesson title is "social engineering" (case-insensitive)
    if (lessonTitle.toLowerCase().contains('social engineering') ||
        lessonTitle.toLowerCase().contains('phishing') ||
        lessonTitle.toLowerCase().contains('ransomware')) {
      List<CyberTipModel> flashcards = [];

      if (lessonTitle.toLowerCase().contains('social engineering')) {
        flashcards = _getSocialEngineeringFlashcards();
      } else if (lessonTitle.toLowerCase().contains('phishing')) {
        flashcards = _getPhishingFlashcards();
      } else if (lessonTitle.toLowerCase().contains('ransomware')) {
        flashcards = _getRansomwareFlashcards();
      }

      DialogFlashcards.show(
        context,
        cyberTips: flashcards,
        title: 'Courses',
        mainTitle: 'ESSENTIAL CYBER TIPS',
        backgroundColor: const Color(0xFFFFEB3B),
        headerColor: const Color(0xFF1565C0),
        cardBackgroundColor: const Color(0xFFC8E6C9),
        cardBorderColor: const Color(0xFF81C784),
        barrierDismissible: false,
      );
    }
  }

  //! SHOW TIPS DIALOG
  void _showTipsDialog() {
    if (_dontShowTipsAgain) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkBlue, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Light bulb icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Icon(
                          Icons.lightbulb,
                          color: Colors.black,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Message text
                      const Text(
                        'Whenever you see a light bulb next to a title, it means helpful tips are waiting for you. Tap the icon to learn how to stay safe and protect yourself!',
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 20),

                      // Don't show again checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _dontShowTipsAgain,
                            onChanged: (value) {
                              final newValue = value ?? false;
                              setState(() {
                                _dontShowTipsAgain = newValue;
                              });
                              _saveDialogPreference(
                                  _tipsDialogPrefKey, newValue);
                            },
                            activeColor: darkBlue,
                            checkColor: Colors.white,
                          ),
                          Expanded(
                            child: const Text(
                              'Don\'t show this again.',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Next button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Show AR dialog after tips dialog is dismissed
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              _showARDialog(); //! SHOW AR DIALOG
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'NEXT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
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

  //! SHOW AR DIALOG
  void _showARDialog() {
    if (_dontShowARAgain) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkBlue, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // AR Holographic Icon
                      Container(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Base platform (oval)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: 50,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      color: Colors.purple, width: 2),
                                ),
                              ),
                            ),
                            // Holographic cone/projector
                            Positioned(
                              bottom: 15,
                              child: Container(
                                width: 40,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.cyan.withOpacity(0.8),
                                      Colors.blue.withOpacity(0.6),
                                      Colors.purple.withOpacity(0.4),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  children: [
                                    // Holographic lines effect
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      right: 5,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 5,
                                      right: 5,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 15,
                                      left: 5,
                                      right: 5,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Floating AR object (pink cube)
                            Positioned(
                              top: 5,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Additional floating elements
                            Positioned(
                              top: 15,
                              left: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyan.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 10,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Message text
                      const Text(
                        'Whenever you see this icon\nnext to a topic title, it\nindicates that Augmented\nReality content is available.\nTap the icon to Explore.',
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Don't show again checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _dontShowARAgain,
                            onChanged: (value) {
                              final newValue = value ?? false;
                              setState(() {
                                _dontShowARAgain = newValue;
                              });
                              _saveDialogPreference(_arDialogPrefKey, newValue);
                            },
                            activeColor: darkBlue,
                            checkColor: Colors.white,
                          ),
                          Expanded(
                            child: const Text(
                              'Don\'t show this again.',
                              style: TextStyle(
                                color: darkBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // OKAY button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'OKAY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
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

  //! SHOW AR SCREEN (Launch external AR app)
  Future<void> _showUnityScreen() async {
    await _launchApp();
  }

  String? _deriveArCategory(String lessonTitle) {
    final normalized = lessonTitle.toLowerCase();
    if (normalized.contains('social engineering')) {
      return 'social engineering';
    }
    if (normalized.contains('phishing')) {
      return 'phishing';
    }
    if (normalized.contains('ransomware')) {
      return 'ransomware';
    }
    return null;
  }

  Future<void> _recordArInteraction({
    required String category,
    required String lessonTitle,
  }) async {
    try {
      final deviceModel = await _getDeviceModelLabel();
      final docId = _sanitizeDocId(deviceModel);

      await FirebaseService.firestore
          .collection('devices')
          .doc(docId)
          .set(
        {
          'deviceModel': deviceModel,
          'topic': category,
          'lessonTitle': lessonTitle,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log AR interaction: $error'),
        ),
      );
    }
  }

  Future<String> _getDeviceModelLabel() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (kIsWeb) {
        final info = await deviceInfoPlugin.webBrowserInfo;
        return info.userAgent ??
            info.vendor ??
            info.browserName.name ??
            'web-device';
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await deviceInfoPlugin.androidInfo;
          final manufacturer = info.manufacturer ?? 'Android';
          final model = info.model ?? 'Device';
          return '$manufacturer $model';
        case TargetPlatform.iOS:
          final info = await deviceInfoPlugin.iosInfo;
          return info.utsname.machine ?? info.name ?? 'iOS Device';
        case TargetPlatform.macOS:
          final info = await deviceInfoPlugin.macOsInfo;
          return info.model ?? info.hostName ?? 'macOS Device';
        case TargetPlatform.windows:
          final info = await deviceInfoPlugin.windowsInfo;
          return info.computerName ?? 'Windows Device';
        case TargetPlatform.linux:
          final info = await deviceInfoPlugin.linuxInfo;
          return info.prettyName ?? 'Linux Device';
        case TargetPlatform.fuchsia:
          return 'Fuchsia Device';
      }
    } catch (_) {
      // ignore and fall through to default
    }
    return 'unknown-device';
  }

  String _sanitizeDocId(String input) {
    final sanitized =
        input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]+'), '-');
    if (sanitized.isEmpty) {
      return 'unknown-device';
    }
    return sanitized;
  }

  //! LAUNCH APP USING PACKAGE NAME (Local App)
  Future<void> _launchApp() async {
    try {
      final packageName = 'com.DefaultCompany.CyberAR';
      debugPrint('_launchApp: Attempting to launch app with package: $packageName');
      debugPrint('_launchApp: Platform = ${defaultTargetPlatform}');
      
      // Check if app is installed first (Android only) - but don't rely on it completely
      bool isInstalledCheck = true; // Default to true, try launching anyway
      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          final isInstalled = await LaunchApp.isAppInstalled(
            androidPackageName: packageName,
          );
          debugPrint('_launchApp: App installed check = $isInstalled');
          isInstalledCheck = isInstalled ?? true; // If null, assume true and try anyway
          
          if (isInstalledCheck == false) {
            debugPrint('_launchApp: isAppInstalled returned false, but will attempt launch anyway');
            debugPrint('_launchApp: Note: isAppInstalled check may be unreliable');
          }
        } catch (checkError) {
          debugPrint('_launchApp: Error checking if app is installed: $checkError');
          debugPrint('_launchApp: Will attempt to launch anyway (check may be unreliable)');
          // Continue anyway, try to launch
        }
      }
      
      // Attempt to launch the app (even if check said it's not installed)
      debugPrint('_launchApp: Attempting to launch app with package: $packageName');
      debugPrint('_launchApp: Package name verification - make sure this matches exactly: $packageName');
      
      bool launchFailed = false;
      String failureReason = '';
      
      // Try method 1: external_app_launcher
      try {
        debugPrint('_launchApp: Trying method 1: external_app_launcher');
        final result = await LaunchApp.openApp(
          androidPackageName: packageName,
          iosUrlScheme: '$packageName://',
          openStore: false,
        );
        
        debugPrint('_launchApp: Launch result = $result (type: ${result.runtimeType})');
        
        // Check for failure cases
        if (result is bool) {
          if (result == false) {
            launchFailed = true;
            failureReason = 'Launch returned false';
          } else {
            debugPrint('_launchApp: Launch successful (boolean true)');
            return; // Success, exit early
          }
        } else if (result is int) {
          if (result == 0) {
            // 0 typically means failure in Android
            launchFailed = true;
            failureReason = 'Launch returned 0';
            debugPrint('_launchApp: Method 1 failed, trying alternative method...');
          } else {
            debugPrint('_launchApp: Launch successful (result code: $result)');
            return; // Success, exit early
          }
        } else {
          debugPrint('_launchApp: Launch completed with result: $result');
          return; // Assume success
      }
    } catch (e) {
        debugPrint('_launchApp: Method 1 error: $e');
        launchFailed = true;
        failureReason = 'Method 1 failed: $e';
      }
      
      // Don't use fallback methods that might open Play Store
      // If method 1 fails, just show install dialog
      
      // All methods failed
      if (launchFailed) {
        debugPrint('_launchApp: All launch methods failed');
        debugPrint('_launchApp: Please verify:');
        debugPrint('_launchApp:   1. Package name is correct: $packageName');
        debugPrint('_launchApp:   2. App is installed on device');
        debugPrint('_launchApp:   3. App has proper permissions');
        debugPrint('_launchApp:   4. Try: adb shell pm list packages | grep $packageName');
        debugPrint('_launchApp:   5. Try: adb shell monkey -p $packageName -c android.intent.category.LAUNCHER 1');
        if (!mounted) return;
        // Show install dialog instead of snackbar
        await _showInstallApkDialog();
      }
    } catch (e, stackTrace) {
      debugPrint('_launchApp Error: $e');
      debugPrint('_launchApp Error Type: ${e.runtimeType}');
      debugPrint('_launchApp Stack Trace: $stackTrace');
      if (!mounted) return;
      // Show install dialog on error
      await _showInstallApkDialog();
      rethrow; // Re-throw to be caught by the calling function
    }
  }

  //! SHOW INSTALL APK DIALOG
  Future<void> _showInstallApkDialog() async {
    if (!mounted) return;
    
    final shouldInstall = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: yellowish,
          title: const Text(
            'AR App Not Found',
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'The CyberAR Service app is required to use AR features. Would you like to install it now?',
            style: TextStyle(
              color: darkBlue,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: darkBlue, width: 2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: darkBlue),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Install'),
            ),
          ],
        );
      },
    );

    if (shouldInstall == true) {
      await _installApkFromAssets();
    }
  }

  //! INSTALL APK FROM ASSETS
  Future<void> _installApkFromAssets() async {
    try {
      debugPrint('_installApkFromAssets: Starting APK installation process');
      
      if (!mounted) return;
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get the APK from assets
      final ByteData data = await rootBundle.load('assets/CyberAR_service.apk');
      final List<int> bytes = data.buffer.asUint8List();

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String apkPath = '${tempDir.path}/CyberAR_service.apk';
      final File apkFile = File(apkPath);

      // Write APK to temporary file
      await apkFile.writeAsBytes(bytes);
      debugPrint('_installApkFromAssets: APK written to $apkPath');

      // Request install packages permission (required for Android 8.0+)
      if (Platform.isAndroid) {
        debugPrint('_installApkFromAssets: Checking install packages permission');
        var status = await Permission.requestInstallPackages.status;
        debugPrint('_installApkFromAssets: Current permission status = $status');
        
        if (!status.isGranted) {
          debugPrint('_installApkFromAssets: Requesting install packages permission');
          status = await Permission.requestInstallPackages.request();
          debugPrint('_installApkFromAssets: Permission request result = $status');
        }
        
        if (!status.isGranted) {
          // Close loading dialog
          if (mounted) {
            Navigator.of(context).pop();
          }
          
          if (mounted) {
            // Show dialog explaining permission is needed
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                backgroundColor: yellowish,
                title: const Text(
                  'Permission Required',
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: const Text(
                  'To install the AR app, please grant the "Install unknown apps" permission. This will open your device settings where you can enable this permission.',
                  style: TextStyle(color: darkBlue),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: darkBlue, width: 2),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: darkBlue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
          return;
        }
        
        debugPrint('_installApkFromAssets: Install packages permission granted');
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Open the APK file to trigger system installer
      debugPrint('_installApkFromAssets: Opening APK file with installer');
      final result = await OpenFile.open(apkPath);
      debugPrint('_installApkFromAssets: Open file result: ${result.message}');

      if (mounted) {
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening installer... Please follow the installation prompts.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open installer: ${result.message}'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('_installApkFromAssets Error: $e');
      debugPrint('_installApkFromAssets Stack Trace: $stackTrace');
      
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst || !route.willHandlePopInternally);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to install APK: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  //! SHOW DRAWER (ADJUST TEXT SIZE AND BACK TO MODULE LIST)
  void _showDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: yellowish,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(color: darkBlue, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text Size Adjustment
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: darkBlue, width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Adjust Text Size <${_textSize.toInt()}>',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _textSize,
                          min: 12.0,
                          max: 24.0,
                          divisions: 12,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                          onChanged: (value) {
                            setState(() {
                              _textSize = value;
                            });
                            // Also update the main widget's state
                            this.setState(() {
                              _textSize = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Back to Module List Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: darkBlue, width: 1),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close drawer
                        Navigator.of(context).pop(); // Go back to module list
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Back to Module List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModuleViewModel>(
      builder: (context, moduleViewModel, child) {
        //! COURSE
        final course = moduleViewModel.currentModule;

        //! COURSE IS NULL THEN DISPLAY THIS
        if (course == null) {
          return Scaffold(
            backgroundColor: yellowish,
            appBar: AppBar(
              backgroundColor: darkBlue,
              elevation: 0,
              title: const Text(
                'COURSES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: darkBlue,
              ),
            ),
          );
        }

        //! CURRENT INDEX IS GREATER THAN OR EQUAL TO COURSE LESSONS LENGTH THEN DISPLAY (MODULE NOT FOUND)
        if (widget.currentIndex >= course.lessons.length) {
          return Scaffold(
            backgroundColor: yellowish,
            appBar: AppBar(
              backgroundColor: darkBlue,
              elevation: 0,
              title: const Text(
                'COURSES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(
              child: Text('Module not found'),
            ),
          );
        }

        //! CURRENT LESSON
        final currentLesson = course.lessons[widget.currentIndex];
        final int totalLessons = course.lessons.length;
        final bool isLastLesson = widget.currentIndex == totalLessons - 1;
        final lessonTitle = currentLesson.title.toLowerCase();
        final arCategory = _deriveArCategory(currentLesson.title);
        final hasArEnhancement = arCategory != null;

        return Scaffold(
          backgroundColor: yellowish,
          drawer: const AppDrawer(),
          appBar: AppBar(
            backgroundColor: darkBlue,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text(
              'COURSES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Main Content Area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Module Title with Icons
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentLesson.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Light bulb icon for tips (only show if lesson matches keywords)
                          if (hasArEnhancement) ...[
                            GestureDetector(
                              onTap: () {
                                // Check if lesson title is "social engineering" to show flashcards
                                if (currentLesson.title
                                        .toLowerCase()
                                        .contains('social engineering') ||
                                    currentLesson.title
                                        .toLowerCase()
                                        .contains('phishing') ||
                                    currentLesson.title
                                        .toLowerCase()
                                        .contains('ransomware')) {
                                  _showFlashcardsDialog(currentLesson.title);
                                } else {
                                  // Show the informational tips dialog for other lessons
                                  _showTipsDialog();
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                                child: const Icon(
                                  Icons.lightbulb,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // AR icon for augmented reality
                            GestureDetector(
                              onTap: () async {
                                try {
                                  debugPrint('AR Button: Starting AR launch process');
                                  
                                  if (arCategory == null) {
                                    debugPrint('AR Button: arCategory is null, cannot proceed');
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('AR category not available for this lesson.'),
                                      ),
                                    );
                                    return;
                                  }
                                  
                                  debugPrint('AR Button: arCategory = $arCategory, lessonTitle = ${currentLesson.title}');
                                  
                                  // Record AR interaction
                                await _recordArInteraction(
                                  category: arCategory,
                                  lessonTitle: currentLesson.title,
                                );
                                  debugPrint('AR Button: AR interaction recorded successfully');
                                  
                                  // Launch the external AR app
                                  debugPrint('AR Button: Attempting to launch external AR app...');
                                  await _showUnityScreen();
                                  debugPrint('AR Button: AR app launch completed');
                                } catch (e, stackTrace) {
                                  debugPrint('AR Button Error: $e');
                                  debugPrint('AR Button Stack Trace: $stackTrace');
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to launch AR app: $e'),
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Base platform
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 20,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.purple, width: 1),
                                        ),
                                      ),
                                    ),
                                    // Holographic cone
                                    Positioned(
                                      bottom: 4,
                                      child: Container(
                                        width: 16,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.cyan
                                                  .withValues(alpha: 0.8),
                                              Colors.blue
                                                  .withValues(alpha: 0.6),
                                              Colors.purple
                                                  .withValues(alpha: 0.4),
                                              Colors.transparent,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    // Floating AR object
                                    Positioned(
                                      top: 2,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.pink
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 3,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      //! Module Content
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            final metrics = notification.metrics;

                            if (metrics.outOfRange) {
                              if (metrics.pixels < metrics.minScrollExtent) {
                                _topOverscrollExtent =
                                    (metrics.minScrollExtent - metrics.pixels)
                                        .clamp(0, double.infinity)
                                        .toDouble();

                                if (widget.currentIndex > 0 &&
                                    _topOverscrollExtent >=
                                        _superScrollTriggerThreshold) {
                                  _handleSuperScrollNavigation(
                                    forward: false,
                                    totalLessons: totalLessons,
                                  );
                                }
                              } else if (metrics.pixels >
                                  metrics.maxScrollExtent) {
                                _bottomOverscrollExtent =
                                    (metrics.pixels - metrics.maxScrollExtent)
                                        .clamp(0, double.infinity)
                                        .toDouble();

                                if (_hasScrolledToBottom &&
                                    _bottomOverscrollExtent >=
                                        _superScrollTriggerThreshold) {
                                  _handleSuperScrollNavigation(
                                    forward: true,
                                    totalLessons: totalLessons,
                                  );
                                }
                              }
                            } else if (_topOverscrollExtent > 0 ||
                                _bottomOverscrollExtent > 0) {
                              _resetSuperScrollTracking();
                            }

                            if (notification is ScrollEndNotification) {
                              _resetSuperScrollTracking();
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                currentLesson.content,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _textSize,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (isLastLesson)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Builder(builder: (context) {
                            final bool showLoading =
                                _isCheckingQuizAvailability;
                            final bool isQuizEnabled = _hasScrolledToBottom &&
                                _canTakeQuiz &&
                                !showLoading;

                            final String label = showLoading
                                ? 'Checking...'
                                : _canTakeQuiz
                                    ? 'Take Quiz'
                                    : 'Quiz Completed';

                            final Widget icon = showLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _canTakeQuiz
                                        ? Icons.arrow_forward
                                        : Icons.check_circle_outline,
                                  );

                            return ElevatedButton.icon(
                              onPressed: isQuizEnabled
                                  ? () => _navigateToNext(totalLessons)
                                  : null,
                              icon: icon,
                              label: Text(label),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isQuizEnabled
                                    ? Colors.white
                                    : Colors.grey[400],
                                foregroundColor:
                                    isQuizEnabled ? darkBlue : Colors.grey[600],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }),
                        ),

                      // Scroll to bottom hint
                      if (!_hasScrolledToBottom)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Text(
                              'Scroll to bottom, then super scroll to navigate',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      //! HAMBURGER MENU
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: _showDrawer,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

