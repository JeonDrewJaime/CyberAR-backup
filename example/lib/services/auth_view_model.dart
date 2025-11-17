import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel(this._authService);

  // private
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // public get
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // clearMessage
  void clearMessage() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Login Function
  Future<void> login(BuildContext context, String email, String password,
      String userType) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
          context, email, password, userType);
      // Success Message
      _isLoading = false;
      _successMessage = 'You are now signed in';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Forgot Password Function
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetLink(email);
      _isLoading = false;
      _successMessage =
          'Password reset link sent to email. Make sure to check your spam folder if you don\'t see it.';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to send reset link. Please try again.';
      notifyListeners();
    }
  }
}
