import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/services/password_reset_service.dart';
import 'package:flutter_unity_widget_example/utils/validators.dart';

class AuthService {
  // Get current user
  User? getCurrentUser() {
    return FirebaseService.auth.currentUser;
  }

  //! SIGN IN WITH EMAIL AND PASSWORD
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
            "Invalid password or email"); // This account is not registered as a teacher. Please use Student Login.
      } else if (userType == 'student' && isTeacherRole != null) {
        await FirebaseService.auth
            .signOut(); // Sign out since role doesn't match
        throw Exception(
            "Invalid password or email"); // This account is not registered as a student. Please use Teacher Login.
      }

      //! SYNC FIRESTORE PASSWORD WITH FIREBASE AUTH IF THEY DON'T MATCH
      final firestorePassword = data['password'] as String?;
      if (firestorePassword != null && firestorePassword != password) {
        try {
          //! UPDATE FIREBASE AUTH PASSWORD TO MATCH FIRESTORE
          await userCredential.user?.updatePassword(firestorePassword);
        } catch (e) {
          //! IF UPDATE FAILS, CONTINUE ANYWAY
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'too-many-requests') {
        throw Exception(
            'Too many requests. Please wait a few minutes before trying again.');
      } else if (e.code == 'network-request-failed') {
        throw Exception(
            'Network error. Please check your internet connection.');
      } else if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        throw Exception('Invalid email or password');
      } else if (e.code == 'user-not-found') {
        throw Exception('No account found with this email');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      }
      throw Exception(e.message ?? 'Authentication failed. Please try again.');
    }
  }

  //! SEND VERIFICATION CODE FOR PASSWORD RESET
  Future<void> sendPasswordResetCode(String email) async {
    try {
      await PasswordResetService.sendVerificationCode(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //! VERIFY RESET CODE
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      return await PasswordResetService.verifyCode(email, code);
    } catch (e) {
      return false;
    }
  }

  //! RESET PASSWORD WITH NEW PASSWORD
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      await PasswordResetService.resetPassword(email, newPassword);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //! SIGN OUT
  Future<void> signOut() async {
    return await FirebaseService.auth.signOut();
  }
}
