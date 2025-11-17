import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';
import 'package:flutter_unity_widget_example/model/quiz_attempt_model.dart';
import 'package:flutter_unity_widget_example/model/teacher_dashboard_model.dart';
import 'package:flutter_unity_widget_example/services/teacher_dashboard_repository.dart';

class TeacherDashboardViewModel extends ChangeNotifier {
  // CONSTRUCTOR
  TeacherDashboardViewModel(this._repository);
  final TeacherDashboardRepository _repository;

  // PRIVATE
  bool _initialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSection;

  // LISTS
  List<TeacherStudentProgress> _students = []; // STUDENT PROGRESS LIST
  List<String> _sections = []; // ALL SECTIONS
  List<ModuleModel> _modules = []; // ALL MODULES
  List<AssessmentModel> _assessments = []; // ALL ASSESSMENTS
  List<TeacherStudent> _currentStudents = []; // CURRENT STUDENTS

  // STREAM SUBSCRIPTIONS
  StreamSubscription<List<String>>?
      _sectionsSubscription; // SECTION SUBSCRIPTION
  StreamSubscription<List<TeacherStudent>>?
      _studentsSubscription; // STUDENT SUBSCRIPTION
  StreamSubscription<List<ModuleModel>>?
      _modulesSubscription; // MODULE SUBSCRIPTION
  StreamSubscription<List<AssessmentModel>>?
      _assessmentsSubscription; // ASSESSMENT SUBSCRIPTION

  final Map<String, Map<String, QuizAttemptModel?>> _attemptCache = {};
  final Map<String, Map<String, StreamSubscription<QuizAttemptModel?>>>
      _attemptSubscriptions = {};
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedSection => _selectedSection;
  List<String> get sections => _sections;
  List<TeacherStudentProgress> get students => _students;
  bool get hasStudents => _students.isNotEmpty;

  // INITIALIZE
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    // LISTENERS
    _listenToSections();
    _listenToModules();
    _listenToAssessments();
  }

  // CLEAR MESSAGE
  void clearMessage() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // SELECT SECTION
  void selectSection(String section, {bool force = false}) {
    // TRIM SECTION
    final trimmed = section.trim();

    // IF TRIMMED SECTION IS EMPTY, SET SELECTED SECTION TO NULL
    if (trimmed.isEmpty) {
      _selectedSection = null;
      _studentsSubscription?.cancel();
      _currentStudents = [];
      _students = [];
      _disposeAllAttemptSubscriptions();
      _setLoading(false);
      notifyListeners();
      return;
    }

    if (!force && trimmed == _selectedSection) return; // SAME SECTION CHECK

    _selectedSection = trimmed;
    _students = [];
    _currentStudents = [];
    _disposeAllAttemptSubscriptions();
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    _studentsSubscription?.cancel();

    //! LISTEN TO STUDENTS BY SECTION
    _studentsSubscription = _repository
        .listenToStudentsBySection(trimmed)
        .listen(_handleStudentsUpdate, onError: (error) {
      _errorMessage = error.toString();
      _setLoading(false);
      notifyListeners();
    });
  }

  // LISTEN TO SECTIONS
  void _listenToSections() {
    _sectionsSubscription?.cancel();
    _sectionsSubscription = _repository.listenToSections().listen(
      (sections) {
        _sections = sections;

        // IF SELECTED SECTION IS NULL AND SECTIONS ARE NOT EMPTY, SELECT THE FIRST SECTION
        if (_selectedSection == null && sections.isNotEmpty) {
          selectSection(sections.first);
        }

        // IF SELECTED SECTION IS NOT NULL AND SECTIONS ARE NOT EMPTY AND SELECTED SECTION IS NOT IN THE LIST,
        // SELECT THE FIRST SECTION
        else if (_selectedSection != null &&
            sections.isNotEmpty &&
            !sections.contains(_selectedSection)) {
          selectSection(sections.first);
        }

        // IF SECTIONS ARE EMPTY, SET SELECTED SECTION TO NULL
        else if (sections.isEmpty) {
          _selectedSection = null;
          _students = [];
          _setLoading(false);
          notifyListeners();
        }
        // ELSE NOTIFY LISTENERS
        else {
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // LISTEN TO MODULES
  void _listenToModules() {
    _modulesSubscription?.cancel();
    _modulesSubscription = _repository.listenToModules().listen(
      (modules) {
        _modules = modules;
        // RECOMPUTE PROGRESS WHEN THERE'S CHANGES IN MODULES
        _recomputeProgress();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // LISTEN TO ASSESSMENTS
  void _listenToAssessments() {
    _assessmentsSubscription?.cancel();
    _assessmentsSubscription = _repository.listenToAssessments().listen(
      (assessments) {
        _assessments = assessments;
        // SYNC ATTEMPT SUBSCRIPTIONS WHEN THERE'S CHANGES IN ASSESSMENTS
        _syncAttemptSubscriptions();
        // RECOMPUTE PROGRESS WHEN THERE'S CHANGES IN ASSESSMENTS
        _recomputeProgress();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // HANDLE STUDENTS UPDATE
  void _handleStudentsUpdate(List<TeacherStudent> students) {
    // SET CURRENT STUDENTS
    _currentStudents = students;
    // SYNC ATTEMPT SUBSCRIPTIONS
    _syncAttemptSubscriptions();

    if (students.isEmpty) {
      _students = [];
      _setLoading(false);
      notifyListeners();
      return;
    }

    // RECOMPUTE PROGRESS
    _recomputeProgress();
  }

  void _syncAttemptSubscriptions() {
    if (_assessments.isEmpty) {
      _disposeAllAttemptSubscriptions();
      return;
    }

    final validAssessmentIds = _assessments
        .map((assessment) => assessment.documentId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    final studentIds = _currentStudents.map((s) => s.id).toSet();
    final existingStudentIds = _attemptSubscriptions.keys.toSet();

    for (final removedStudent in existingStudentIds.difference(studentIds)) {
      _disposeAttemptSubscriptionsForStudent(removedStudent);
      _attemptCache.remove(removedStudent);
    }

    for (final student in _currentStudents) {
      final studentId = student.id;
      final subscriptions =
          _attemptSubscriptions.putIfAbsent(studentId, () => {});

      final staleAssessmentIds = subscriptions.keys
          .where((id) => !validAssessmentIds.contains(id))
          .toList();
      for (final assessmentId in staleAssessmentIds) {
        subscriptions[assessmentId]?.cancel();
        subscriptions.remove(assessmentId);
        _attemptCache[studentId]?.remove(assessmentId);
      }

      for (final assessment in _assessments) {
        final assessmentId = assessment.documentId;
        if (assessmentId == null || assessmentId.isEmpty) continue;
        if (subscriptions.containsKey(assessmentId)) continue;

        final subscription = _repository
            .listenToQuizAttempt(
          assessmentId: assessmentId,
          userId: studentId,
        )
            .listen((attempt) {
          final cache = _attemptCache.putIfAbsent(studentId, () => {});
          cache[assessmentId] = attempt;
          _updateSingleStudent(studentId);
        }, onError: (error) {
          _errorMessage = error.toString();
          notifyListeners();
        });

        subscriptions[assessmentId] = subscription;
      }
    }
  }

  void _recomputeProgress() {
    if (_selectedSection == null) {
      _students = [];
      _setLoading(false);
      notifyListeners();
      return;
    }

    if (_modules.isEmpty || _assessments.isEmpty) {
      _setLoading(false);
      return;
    }

    final progressList = _currentStudents
        .map(_buildStudentProgressFromCache)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    _students = progressList;
    _setLoading(false);
    notifyListeners();
  }

  TeacherStudentProgress _buildStudentProgressFromCache(
    TeacherStudent student,
  ) {
    int totalModules = 0;
    int completedModules = 0;

    for (final module in _modules) {
      if (module.lessons.isEmpty) continue;
      totalModules++;

      final allLessonsCompleted = module.lessons.every((lesson) {
        final lessonStatus = lesson.status[student.id] ?? 'not_started';
        return lessonStatus == 'completed';
      });

      if (allLessonsCompleted) {
        completedModules++;
      }
    }

    final quizScores = _buildQuizScoresFromCache(student.id);
    final assessmentStats = _calculateAssessmentStats(student.id);
    final assessmentCompletionPercentage = assessmentStats.total > 0
        ? ((assessmentStats.passed / assessmentStats.total) * 100).round()
        : 0;

    final certificateAvailable = totalModules > 0 &&
        completedModules >= totalModules &&
        (assessmentStats.total == 0 ||
            assessmentStats.passed == assessmentStats.total);

    return TeacherStudentProgress(
      userId: student.id,
      name: student.user.name,
      email: student.user.email,
      section: student.user.section,
      studentNumber: student.user.studentNumber,
      coursesCompleted: completedModules,
      totalCourses: totalModules,
      quizPercentage: assessmentCompletionPercentage,
      certificateAvailable: certificateAvailable,
      quizScores: quizScores,
    );
  }

  _AssessmentStats _calculateAssessmentStats(String studentId) {
    if (_assessments.isEmpty) {
      return const _AssessmentStats(passed: 0, total: 0);
    }

    final cache = _attemptCache[studentId] ?? {};
    int total = 0;
    int passed = 0;

    for (final assessment in _assessments) {
      if (_modules.every((module) => module.title != assessment.module)) {
        continue;
      }

      final assessmentId = assessment.documentId;
      if (assessmentId == null || assessmentId.isEmpty) continue;

      final totalQuestions = assessment.questions.length;
      if (totalQuestions == 0) continue;

      total++;

      final attempt = cache[assessmentId];
      if (attempt == null || attempt.scores.isEmpty) continue;

      final bestScore = attempt.scores
          .map((entry) => entry.score)
          .fold<int>(0, (prev, score) => math.max(prev, score));

      final passingScore = (totalQuestions * 0.6).ceil();
      if (bestScore >= passingScore) {
        passed++;
      }
    }

    return _AssessmentStats(passed: passed, total: total);
  }

  List<StudentQuizScore> _buildQuizScoresFromCache(String studentId) {
    if (_assessments.isEmpty) return const [];

    final cache = _attemptCache[studentId] ?? {};

    final scores = _assessments.map((assessment) {
      final assessmentId = assessment.documentId;
      final quizName = assessment.module.isNotEmpty
          ? assessment.module
          : assessment.courseSummary;

      if (assessmentId == null || assessmentId.isEmpty) {
        return StudentQuizScore(
          quizName: quizName,
          maxScore: assessment.questions.length,
          score: null,
        );
      }

      final attempt = cache[assessmentId];
      int? bestScore;
      if (attempt != null && attempt.scores.isNotEmpty) {
        bestScore = attempt.scores
            .map((entry) => entry.score)
            .reduce((a, b) => a > b ? a : b);
      }

      return StudentQuizScore(
        quizName: quizName,
        maxScore: assessment.questions.length,
        score: bestScore,
      );
    }).toList();

    scores.sort((a, b) => a.quizName.compareTo(b.quizName));
    return scores;
  }

  void _updateSingleStudent(String studentId) {
    TeacherStudent? student;
    for (final item in _currentStudents) {
      if (item.id == studentId) {
        student = item;
        break;
      }
    }
    if (student == null) return;

    final progress = _buildStudentProgressFromCache(student);
    final index =
        _students.indexWhere((element) => element.userId == studentId);

    if (index == -1) {
      _students.add(progress);
    } else {
      _students[index] = progress;
    }

    _students.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void _disposeAttemptSubscriptionsForStudent(String studentId) {
    final subscriptions = _attemptSubscriptions.remove(studentId);
    if (subscriptions == null) return;

    for (final sub in subscriptions.values) {
      sub.cancel();
    }
  }

  // DISPOSE ALL ATTEMPT SUBSCRIPTIONS
  void _disposeAllAttemptSubscriptions() {
    for (final map in _attemptSubscriptions.values) {
      for (final sub in map.values) {
        sub.cancel();
      }
    }
    _attemptSubscriptions.clear();
    _attemptCache.clear();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  @override
  void dispose() {
    _sectionsSubscription?.cancel();
    _modulesSubscription?.cancel();
    _assessmentsSubscription?.cancel();
    _studentsSubscription?.cancel();
    _disposeAllAttemptSubscriptions();
    super.dispose();
  }
}

class _AssessmentStats {
  final int passed;
  final int total;

  const _AssessmentStats({
    required this.passed,
    required this.total,
  });
}
