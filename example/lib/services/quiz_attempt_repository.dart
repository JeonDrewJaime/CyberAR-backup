import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/quiz_attempt_model.dart';

class QuizAttemptRepository {
  //! ASSESSMENTS COLLECTION
  //! GET ASSESSMENT ID BY MODULE TITLE
  Future<String?> getAssessmentIdByModule(String moduleTitle) async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('assessments')
          .where('module', isEqualTo: moduleTitle)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting assessment ID: $e');
      return null;
    }
  }

  //! SUBMISSIONS COLLECTION
  //! GET QUIZ ATTEMPT FROM ASSESSMENTS/{ASSESSMENTID}/SUBMISSIONS/{USERID}
  Future<QuizAttemptModel?> getQuizAttempt(
      String userId, String assessmentId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('assessments')
          .doc(assessmentId)
          .collection('submissions')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return QuizAttemptModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting quiz attempt: $e');
      return null;
    }
  }

  //! LISTEN TO QUIZ ATTEMPT (REAL-TIME UPDATES)
  Stream<QuizAttemptModel?> listenToQuizAttempt(
      String userId, String assessmentId) {
    return FirebaseService.firestore
        .collection('assessments')
        .doc(assessmentId)
        .collection('submissions')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return QuizAttemptModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  //! START QUIZ ATTEMPT (CONSUME AN ATTEMPT WHEN QUIZ STARTS)
  Future<void> startQuizAttempt(String userId, String assessmentId) async {
    try {
      final existing = await getQuizAttempt(userId, assessmentId);
      final submissionRef = FirebaseService.firestore
          .collection('assessments')
          .doc(assessmentId)
          .collection('submissions')
          .doc(userId);

      if (existing == null) {
        final newAttempt = QuizAttemptModel(
          courseId: assessmentId,
          attemptsUsed: 1,
          maxAttempts: 3,
          scores: const [],
          lastAttemptDate: Timestamp.now(),
          cooldownMinutes: 10,
        );

        await submissionRef.set(newAttempt.toMap());
      } else {
        if (existing.remainingAttempts <= 0) {
          throw Exception(
              'No attempts remaining. Please wait for attempts to regenerate.');
        }

        final newAttemptsUsed = existing.currentAttemptsUsed + 1;

        await submissionRef.update({
          'attemptsUsed': newAttemptsUsed,
          'lastAttemptDate': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error starting quiz attempt: $e');
      rethrow;
    }
  }

  //! RECORD A QUIZ ATTEMPT IN ASSESSMENTS/{ASSESSMENTID}/SUBMISSIONS/{USERID}
  Future<void> recordQuizAttempt(
      String userId, String assessmentId, int score, int totalQuestions,
      {bool incrementAttempt = true}) async {
    try {
      final existing = await getQuizAttempt(userId, assessmentId);

      final newScore = QuizScore(
        score: score,
      );

      final submissionRef = FirebaseService.firestore
          .collection('assessments')
          .doc(assessmentId)
          .collection('submissions')
          .doc(userId);

      if (existing == null) {
        //! CREATE NEW ATTEMPT RECORD
        final newAttempt = QuizAttemptModel(
          courseId: assessmentId,
          attemptsUsed: 1,
          maxAttempts: 3,
          scores: [newScore],
          lastAttemptDate: Timestamp.now(),
          cooldownMinutes: 10,
        );

        await submissionRef.set(newAttempt.toMap());
      } else {
        //! UPDATE EXISTING ATTEMPT
        final scores = List<QuizScore>.from(existing.scores);

        //! Check if user has available attempts (considering regeneration)
        if (incrementAttempt && existing.remainingAttempts <= 0) {
          throw Exception(
              'No attempts remaining. Please wait for attempts to regenerate.');
        }

        scores.add(newScore);

        // Increment attemptsUsed from the current regenerated value
        final newAttemptsUsed = incrementAttempt
            ? existing.currentAttemptsUsed + 1
            : existing.attemptsUsed;

        await submissionRef.update({
          'attemptsUsed': newAttemptsUsed,
          'scores': scores.map((s) => s.toMap()).toList(),
          'lastAttemptDate': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error recording quiz attempt: $e');
      rethrow;
    }
  }
}
