import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/services/email_service.dart';

class PasswordResetService {
  //! GENERATE 6-DIGIT VERIFICATION CODE
  static String _generateCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  //! SEND VERIFICATION CODE TO EMAIL
  static Future<void> sendVerificationCode(String email) async {
    try {
      //! PREVENT SPAM
      final existingCodeDoc = await FirebaseService.firestore
          .collection('password_reset_codes')
          .doc(email)
          .get();

      if (existingCodeDoc.exists) {
        final data = existingCodeDoc.data()!;
        final createdAt = DateTime.parse(data['createdAt'] as String);
        final timeSinceCreation = DateTime.now().difference(createdAt);

        //! ONLY ALLOW ONE CODE PER MINUTE
        if (timeSinceCreation.inSeconds < 60) {
          final remainingSeconds = 60 - timeSinceCreation.inSeconds;
          throw Exception(
              'Please wait $remainingSeconds seconds before requesting another code');
        }
      }

      //! CHECK USER EXISTENCE
      final usersQuery = await FirebaseService.firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersQuery.docs.isEmpty) {
        throw Exception('No account found with this email');
      }

      //! GENERATE CODE
      final code = _generateCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      //! STORE CODE IN FIRESTORE
      await FirebaseService.firestore
          .collection('password_reset_codes')
          .doc(email)
          .set({
        'code': code,
        'email': email,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      //! SEND EMAIL
      await EmailService.sendVerificationCode(email, code);
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }

  //! VERIFY CODE
  static Future<bool> verifyCode(String email, String code) async {
    try {
      final doc = await FirebaseService.firestore
          .collection('password_reset_codes')
          .doc(email)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);

      if (DateTime.now().isAfter(expiresAt)) {
        // DELETE EXPIRED CODE
        await doc.reference.delete();
        return false;
      }

      return storedCode == code;
    } catch (e) {
      return false;
    }
  }

  //! RESET PASSWORD
  static Future<void> resetPassword(String email, String newPassword) async {
    try {
      //! GET USER FROM FIRESTORE
      final usersQuery = await FirebaseService.firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (usersQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userDoc = usersQuery.docs.first;
      final userData = userDoc.data();

      //! USE UID FROM DOCUMENT IF AVAILABLE, OTHERWISE USE DOCUMENT ID
      final userId = userData['uid'] as String? ?? userDoc.id;

      //! GET OLD PASSWORD BEFORE UPDATING FIRESTORE
      final oldPassword = userData['password'] as String?;

      //! UPDATE PASSWORD IN FIRESTORE FIRST
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .update({'password': newPassword});

      //! TRY TO UPDATE FIREBASE AUTH PASSWORD (REQUIRES SIGN IN)
      bool firebaseAuthUpdated = false;

      //! IF OLD PASSWORD IS NOT NULL AND NOT EMPTY, TRY TO UPDATE FIREBASE AUTH PASSWORD
      if (oldPassword != null && oldPassword.isNotEmpty) {
        try {
          //! SIGN IN WITH OLD PASSWORD TO UPDATE FIREBASE AUTH
          final credential =
              await FirebaseService.auth.signInWithEmailAndPassword(
            email: email,
            password: oldPassword,
          );

          //! UPDATE FIREBASE AUTH PASSWORD
          await credential.user?.updatePassword(newPassword);
          firebaseAuthUpdated = true;

          //! SIGN OUT
          await FirebaseService.auth.signOut();
        } on FirebaseAuthException {
          //! IF SIGN IN FAILS, WE NEED TO USE FIREBASE RESET EMAIL
          firebaseAuthUpdated = false;
        } catch (_) {
          firebaseAuthUpdated = false;
        }
      }

      //! IF FIREBASE AUTH UPDATE FAILED, SEND RESET EMAIL AS FALLBACK

      if (!firebaseAuthUpdated) {
        try {
          await FirebaseService.auth.sendPasswordResetEmail(email: email);
        } catch (e) {
          throw Exception('Failed to send reset email: $e');
        }
      }

      await FirebaseService.firestore
          .collection('password_reset_codes')
          .doc(email)
          .delete();
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}
