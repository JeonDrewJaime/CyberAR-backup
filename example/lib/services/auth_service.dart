import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/utils/validators.dart';

class AuthService {
  // Get current user
  User? getCurrentUser() {
    return FirebaseService.auth.currentUser;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      BuildContext context, String email, password, userType) async {
    try {
      if (email.isEmpty) {
        throw Exception('Email is required');
      }

      if (password.isEmpty) {
        throw Exception('Password is required');
      }

      if (!Validators.isValidEmail(email)) {
        throw Exception('Invalid email');
      }

      UserCredential userCredential =
          await FirebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user?.uid;

      if (uid == null) {
        throw Exception("No authenticated user found.");
      }

      final doc =
          await FirebaseService.firestore.collection("users").doc(uid).get();

      if (!doc.exists) {
        throw Exception("User record not found in Firestore.");
      }

      final data = doc.data()!;
      final isTeacherRole = data['isTeacher'] as bool?;

      if (userType == 'teacher' && isTeacherRole != true) {
        await FirebaseService.auth.signOut();
        throw Exception(
            "This account is not registered as a teacher. Please use Student Login.");
      } else if (userType == 'student' && isTeacherRole != null) {
        await FirebaseService.auth
            .signOut(); // Sign out since role doesn't match
        throw Exception(
            "This account is not registered as a student. Please use Teacher Login.");
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Password reset
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    return await FirebaseService.auth.signOut();
  }
}
