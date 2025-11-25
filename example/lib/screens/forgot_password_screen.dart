import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/components/my_snackbar.dart';
import 'package:flutter_unity_widget_example/services/auth_view_model.dart';
import 'package:flutter_unity_widget_example/utils/post_frame_callback.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordScreen({super.key, required this.email});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int _currentStep = 0; // 0: email, 1: code, 2: new password
  String? _emailError;
  String? _codeError;
  String? _passwordError;
  String _userEmail = '';
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
    } else if (!email.contains('@')) {
      setState(() => _emailError = 'Please enter a valid email');
    } else {
      setState(() => _emailError = null);
    }
  }

  Future<void> _sendCode(AuthViewModel authViewModel) async {
    _validateEmail();
    if (_emailError == null) {
      _userEmail = emailController.text.trim();
      await authViewModel.sendVerificationCode(_userEmail);
      if (mounted && authViewModel.successMessage != null) {
        setState(() => _currentStep = 1);
      }
    }
  }

  Future<void> _verifyCode(AuthViewModel authViewModel) async {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _codeError = 'Please enter the code');
      return;
    }
    if (code.length != 6) {
      setState(() => _codeError = 'Code must be 6 digits');
      return;
    }
    setState(() => _codeError = null);

    final isValid = await authViewModel.verifyCode(_userEmail, code);
    if (isValid && mounted) {
      setState(() => _currentStep = 2);
    }
  }

  void _validatePassword() {
    final password = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter a new password');
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
    } else if (password != confirmPassword) {
      setState(() => _passwordError = 'Passwords do not match');
    } else {
      setState(() => _passwordError = null);
    }
  }

  Future<void> _resetPassword(AuthViewModel authViewModel) async {
    _validatePassword();
    if (_passwordError == null) {
      await authViewModel.resetPassword(
        _userEmail,
        newPasswordController.text.trim(),
      );
      if (mounted && authViewModel.successMessage != null) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    runAfterBuild(() {
      if (mounted) {
        if (authViewModel.successMessage != null) {
          MySnackbar.show(
            context,
            authViewModel.successMessage!,
            backgroundColor: Colors.green,
            icon: Icons.check_circle,
          );
          authViewModel.clearMessage();
        }
        if (authViewModel.errorMessage != null) {
          MySnackbar.show(
            context,
            authViewModel.errorMessage!,
            backgroundColor: Colors.red,
            icon: Icons.error,
          );
          authViewModel.clearMessage();
        }
      }
    });

    return Scaffold(
      backgroundColor: yellowish,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Forgot',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: royalBlue,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password?',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: royalBlue,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Step 1: Email
                if (_currentStep == 0) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: royalBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter Email',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (_) {
                        if (_emailError != null) _validateEmail();
                      },
                    ),
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _emailError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () => _sendCode(authViewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authViewModel.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Send Code',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],

                // Step 2: Code
                if (_currentStep == 1) ...[
                  Text(
                    'Enter the 6-digit code sent to\n$_userEmail',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: royalBlue, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: royalBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 24, letterSpacing: 8),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '000000',
                        hintStyle:
                            TextStyle(color: Colors.white70, letterSpacing: 8),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (_) {
                        if (_codeError != null)
                          setState(() => _codeError = null);
                      },
                    ),
                  ),
                  if (_codeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _codeError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () => _verifyCode(authViewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authViewModel.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Verify Code',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _sendCode(authViewModel),
                    child: Text(
                      'Resend Code',
                      style: TextStyle(
                          color: royalBlue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],

                // Step 3: New Password
                if (_currentStep == 2) ...[
                  Text(
                    'Enter your new password',
                    style: TextStyle(color: royalBlue, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: royalBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'New Password',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: royalBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      onChanged: (_) {
                        if (_passwordError != null) _validatePassword();
                      },
                    ),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () => _resetPassword(authViewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authViewModel.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Reset Password',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: royalBlue,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
