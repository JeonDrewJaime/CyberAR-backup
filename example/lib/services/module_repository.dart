import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/module_model.dart';

class ModuleRepository {
  // LISTEN TO ALL MODULES THAT HAS THE SAME 'TITLE'/moduleNumber
  Stream<List<ModuleModel>> listenToModules() {
    return FirebaseService.firestore
        .collection("modules")
        .orderBy('moduleNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ModuleModel.fromMap(doc); // PASS THE ENTIRE DOCUMENT SNAPSHOT
      }).toList();
    });
  }

  // LISTEN TO SPECIFIC MODULE
  Stream<ModuleModel?> listenToModule(String moduleId) {
    return FirebaseService.firestore
        .collection("modules")
        .doc(moduleId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ModuleModel.fromMap(doc); // PASS THE ENTIRE DOCUMENT SNAPSHOT
      } else {
        return null;
      }
    });
  }

  // UPDATE LESSON STATUS FOR A SPECIFIC USER
  Future<void> updateLessonStatus({
    required String moduleId,
    required int lessonId,
    required String userId,
    required String status,
  }) async {
    try {
      // GET THE MODULE DOCUMENT
      final moduleDoc = await FirebaseService.firestore
          .collection("modules")
          .doc(moduleId)
          .get();

      // IF MODULE DOCUMENT EXISTS
      if (moduleDoc.exists) {
        // GET THE DATA FROM THE MODULE DOCUMENT
        final data = moduleDoc.data();

        // IF DATA IS NOT NULL AND LESSONS IS A LIST
        if (data != null && data['lessons'] is List) {
          // GET THE LESSONS FROM THE DATA
          List lessons = data['lessons'];

          // FIND AND UPDATE THE LESSON STATUS
          for (var i = 0; i < lessons.length; i++) {
            if (lessons[i]['id'] == lessonId) {
              //! IF STATUS IS NULL, SET IT TO AN EMPTY MAP
              if (lessons[i]['status'] == null) {
                lessons[i]['status'] = {};
              }
              //! SET THE STATUS FOR THE USER
              lessons[i]['status'][userId] = status;
              break;
            }
          }
          // UPDATE THE DOCUMENT
          await FirebaseService.firestore
              .collection("modules")
              .doc(moduleId)
              .update({'lessons': lessons});
        }
      }
    } catch (e) {
      print('Error updating lesson status: $e');
      rethrow;
    }
  }
}
