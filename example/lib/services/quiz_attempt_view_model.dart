import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/model/quiz_attempt_model.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_repository.dart';

class QuizAttemptViewModel extends ChangeNotifier {
  final QuizAttemptRepository _repository;
  QuizAttemptViewModel(this._repository);

  // private
  String? _errorMessage;
  QuizAttemptModel? _currentQuizAttempt; //! CURRENT QUIZ ATTEMPT
  StreamSubscription<QuizAttemptModel?>?
      _quizAttemptSubscription; //! QUIZ ATTEMPT SUBSCRIPTION
  String? _currentAssessmentId;

  // public getters
  String? get errorMessage => _errorMessage;
  QuizAttemptModel? get currentQuizAttempt => _currentQuizAttempt;
  String? get currentAssessmentId => _currentAssessmentId;
  QuizAttemptRepository get repository =>
      _repository; // Expose repository for direct access

  // Clear error message
  void clearMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  //! LISTEN TO QUIZ ATTEMPT BY MODULE TITLE (GETS ASSESSMENT ID FIRST)
  Future<void> listenToQuizAttemptByModule(
      String userId, String moduleTitle) async {
    try {
      //! GET ASSESSMENT ID
      final assessmentId =
          await _repository.getAssessmentIdByModule(moduleTitle);

      if (assessmentId != null) {
        _currentAssessmentId = assessmentId;
        listenToQuizAttempt(userId, assessmentId);
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  //! LISTEN TO QUIZ ATTEMPT FOR A USER AND ASSESSMENT
  void listenToQuizAttempt(String userId, String assessmentId) {
    _quizAttemptSubscription?.cancel();
    _quizAttemptSubscription =
        _repository.listenToQuizAttempt(userId, assessmentId).listen(
      (attempt) {
        _currentQuizAttempt = attempt;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  //! RECORD A QUIZ ATTEMPT
  Future<void> recordQuizAttempt(
      String userId, String assessmentId, int score, int totalQuestions,
      {bool incrementAttempt = true}) async {
    try {
      await _repository.recordQuizAttempt(
        userId,
        assessmentId,
        score,
        totalQuestions,
        incrementAttempt: incrementAttempt,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  //! START A QUIZ ATTEMPT (CONSUME ATTEMPT AT QUIZ START)
  Future<void> startQuizAttempt(String userId, String assessmentId) async {
    try {
      await _repository.startQuizAttempt(userId, assessmentId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  //! CLEAR CURRENT QUIZ ATTEMPT
  void clearCurrentQuizAttempt() {
    _currentQuizAttempt = null;
    _quizAttemptSubscription?.cancel();
    _currentAssessmentId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _quizAttemptSubscription?.cancel();
    super.dispose();
  }
}
