import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_repository.dart';

class AssessmentViewModel extends ChangeNotifier {
  final AssessmentRepository _assessmentRepository;
  AssessmentViewModel(this._assessmentRepository);

  // private
  String? _errorMessage;

  //! LIST OF CURRENT ASSESSMENTS (PRIVATE)
  List<AssessmentModel> _currentAssessments = [];

  //! SUBSCRIPTION TO LISTEN TO ASSESSMENTS BY MODULE
  StreamSubscription<List<AssessmentModel>>? _assessmentSubscription;

  // public getters

  String? get errorMessage => _errorMessage;

  //! LIST OF CURRENT ASSESSMENTS
  List<AssessmentModel> get currentAssessments => _currentAssessments;

  //! CURRENT ASSESSMENT - RETURN FIRST ASSESSMENT IF EXISTS
  AssessmentModel? get currentAssessment =>
      _currentAssessments.isNotEmpty ? _currentAssessments.first : null;

  // clearMessage
  void clearMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  //! LISTEN TO ASSESSMENTS BY MODULE - REAL-TIME UPDATES FOR ALL ASSESSMENTS
  void listenToAssessmentByModule(String moduleTitle) {
    //! CANCEL EXISTING SUBSCRIPTION
    _assessmentSubscription?.cancel();

    //! CREATE NEW SUBSCRIPTION
    _assessmentSubscription =
        _assessmentRepository.listenToAssessmentsByModule(moduleTitle).listen(
      (assessments) {
        _currentAssessments = assessments; //! PASS THE DATA TO THE LIST
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Clear current assessments
  void clearCurrentAssessment() {
    _currentAssessments = [];
    _assessmentSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _currentAssessments = [];
    _assessmentSubscription?.cancel();
    super.dispose();
  }
}
