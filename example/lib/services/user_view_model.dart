import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/model/user_model.dart';
import 'package:flutter_unity_widget_example/services/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  UserViewModel(this._userRepository);

  // private
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // public get
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // User data
  UserModel? _user;
  StreamSubscription<UserModel?>? _userSubscription;

  // public getter for user
  UserModel? get user => _user;

  // clearMessage
  void clearMessage() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // listenToUser - real-time updates using repository's listenToUser method
  void listenToUser(String userId) {
    _userSubscription?.cancel();
    _userSubscription = _userRepository.listenToUser(userId).listen(
      (user) {
        _user = user;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // updatePassword - updates both Firebase Auth and Firestore user document
  Future<void> updatePassword(String userId, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Update Firebase Auth password
      await _userRepository.updatePassword(newPassword);

      // Also update password in Firestore user document
      await _userRepository.updateUser(userId, {'password': newPassword});

      _isLoading = false;
      _successMessage = 'Password updated successfully';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
