import 'package:cloud_firestore/cloud_firestore.dart';

// MAIN ASSESSMENT MODEL
class AssessmentModel {
  final String? documentId; // FIRESTORE DOCUMENT ID
  final String courseSummary;
  final Timestamp createdDate;
  final String learningOutcome;
  final String module;
  final List<Question> questions;

  AssessmentModel({
    this.documentId,
    required this.courseSummary,
    required this.createdDate,
    required this.learningOutcome,
    required this.module,
    required this.questions,
  });

  factory AssessmentModel.fromMap(Map<String, dynamic> data,
      {String? documentId}) {
    return AssessmentModel(
      documentId: documentId,
      courseSummary: data['courseSummary'] ?? '',
      createdDate: data['createdDate'] is Timestamp
          ? data['createdDate'] as Timestamp
          : data['createdDate'] is String
              ? Timestamp.fromDate(DateTime.parse(data['createdDate']))
              : Timestamp.now(),
      learningOutcome: data['learningOutcome'] ?? '',
      module: data['module'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((question) =>
                  Question.fromMap(question as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// CHOICES MODEL FOR EACH ANSWER OPTION
class ChoicesModel {
  final num id;
  final bool isCorrect;
  final String statement;

  ChoicesModel({
    required this.id,
    required this.isCorrect,
    required this.statement,
  });

  factory ChoicesModel.fromMap(Map<String, dynamic> data) {
    return ChoicesModel(
      id: data['id'] ?? 0,
      isCorrect: data['isCorrect'] ?? false,
      statement: data['statement'] ?? '',
    );
  }
}

// QUESTION MODEL FOR EACH QUESTION
class Question {
  final List<ChoicesModel> choices;
  final String description;
  final num id;
  final String statement;

  Question({
    required this.choices,
    required this.description,
    required this.id,
    required this.statement,
  });

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      choices: (data['choices'] as List<dynamic>?)
              ?.map((choice) =>
                  ChoicesModel.fromMap(choice as Map<String, dynamic>))
              .toList() ??
          [],
      description: data['description'] ?? '',
      id: data['id'] ?? 0,
      statement: data['statement'] ?? '',
    );
  }
}
