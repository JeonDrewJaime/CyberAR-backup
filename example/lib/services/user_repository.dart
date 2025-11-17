import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/model/user_model.dart';

class UserRepository {
  Stream<UserModel?> listenToUser(String userId) {
    return FirebaseService.firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      } else {
        return null;
      }
    });
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await FirebaseService.firestore
          .collection("users")
          .doc(userId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await FirebaseService.auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }
}
