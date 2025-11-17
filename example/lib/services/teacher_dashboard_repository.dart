import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';
import 'package:flutter_unity_widget_example/model/quiz_attempt_model.dart';
import 'package:flutter_unity_widget_example/model/teacher_dashboard_model.dart';
import 'package:flutter_unity_widget_example/model/user_model.dart';

class TeacherDashboardRepository {
  const TeacherDashboardRepository();

  FirebaseFirestore get _firestore => FirebaseService.firestore;

  // GET ALL SECTIONS: EX. ICT-201, ICT-202
  Stream<List<String>> listenToSections() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      final sections = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final section = data['section'];
        final isTeacher = data['isTeacher'] as bool? ?? false;

        if (!isTeacher && section is String && section.trim().isNotEmpty) {
          sections.add(section.trim());
        }
      }
      final sorted = sections.toList()..sort();
      return sorted;
    });
  }

  // GET ALL STUDENTS INFOS PER SECTION:
  Stream<List<TeacherStudent>> listenToStudentsBySection(String section) {
    return _firestore
        .collection('users')
        .where('section', isEqualTo: section)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final isTeacher = data['isTeacher'] as bool? ?? false;
        return !isTeacher;
      }).map((doc) {
        final data = doc.data();
        final user = UserModel.fromMap(data);
        return TeacherStudent(id: doc.id, user: user);
      }).toList();
    });
  }

  // GET ALL MODULES THAT HAS THE SAME 'TITLE'/moduleNumber
  Stream<List<ModuleModel>> listenToModules() {
    return FirebaseService.firestore
        .collection("modules")
        .orderBy('moduleNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ModuleModel.fromMap(doc);
      }).toList();
    });
  }

  // GET ALL ASSESSMENTS
  Stream<List<AssessmentModel>> listenToAssessments() {
    return _firestore.collection('assessments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AssessmentModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  // GET QUIZ ATTEMPT FOR A SPECIFIC ASSESSMENT AND USER
  Stream<QuizAttemptModel?> listenToQuizAttempt({
    required String assessmentId,
    required String userId,
  }) {
    return _firestore
        .collection('assessments')
        .doc(assessmentId)
        .collection('submissions')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return QuizAttemptModel.fromMap(snapshot.data()!);
    });
  }
}
