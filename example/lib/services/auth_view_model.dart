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

  //! CLEAR MESSAGE
  void clearMessage() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  //! LOGIN FUNCTION
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

  //! SEND VERIFICATION CODE
  Future<void> sendVerificationCode(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetCode(email);
      _isLoading = false;
      _successMessage = 'Verification code sent to your email';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  //! VERIFY CODE
  Future<bool> verifyCode(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final isValid = await _authService.verifyResetCode(email, code);
      _isLoading = false;
      if (isValid) {
        _successMessage = 'Code verified successfully';
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid or expired code';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to verify code';
      notifyListeners();
      return false;
    }
  }

  //! RESET PASSWORD
  Future<void> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email, newPassword);
      _isLoading = false;
      _successMessage = 'Password changed successfully!. ';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
}
