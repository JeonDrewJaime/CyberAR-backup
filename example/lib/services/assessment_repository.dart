import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/assessment_model.dart';

class AssessmentRepository {
  //! LISTEN TO ALL ASSESSMENTS FOR A SPECIFIC MODULE AS A STREAM
  Stream<List<AssessmentModel>> listenToAssessmentsByModule(
      String moduleTitle) {
    return FirebaseService.firestore
        .collection("assessments")
        .where('module', isEqualTo: moduleTitle)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AssessmentModel.fromMap(data, documentId: doc.id);
      }).toList();
    });
  }

  //! FETCH FIRST ASSESSMENT ONCE FOR A MODULE
  Future<AssessmentModel?> fetchFirstAssessmentByModule(
      String moduleTitle) async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection('assessments')
          .where('module', isEqualTo: moduleTitle)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return AssessmentModel.fromMap(doc.data(), documentId: doc.id);
    } catch (e) {
      return null;
    }
  }

  //! FETCH ASSESSMENT BY DOCUMENT ID
  Future<AssessmentModel?> fetchAssessmentById(String assessmentId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('assessments')
          .doc(assessmentId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return AssessmentModel.fromMap(doc.data()!, documentId: doc.id);
    } catch (e) {
      return null;
    }
  }
}
