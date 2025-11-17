import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// A CLASS FOR FIREBASE SERVICES SHORTCUTS/INSTANCES
class FirebaseService {
  static final storage = FirebaseStorage.instance;
  static final auth = FirebaseAuth.instance;
  static final firestore = FirebaseFirestore.instance;

  static User? get currentUser => auth.currentUser;
  static String? get currentUsersId => auth.currentUser?.uid;
  static String? get currentUsersEmail => auth.currentUser?.email;
}
