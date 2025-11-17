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
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  String? _emailError;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // More yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = emailController.text;
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email';
      });
    } else if (!email.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  Future<void> _sendResetLink(AuthViewModel authViewModel) async {
    _validateEmail();

    if (_emailError == null) {
      final email = emailController.text.trim();
      await authViewModel.forgotPassword(email);

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    // Success
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
      }
    });

    // Error
    runAfterBuild(() {
      if (mounted) {
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
            child: Form(
              key: forgotPasswordFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title Text
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
                  const SizedBox(height: 60),

                  // Email Field
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
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (value) {
                        if (_emailError != null) {
                          _validateEmail();
                        }
                      },
                    ),
                  ),
                  // Email Error
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _emailError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Send Reset Link Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () => _sendResetLink(authViewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
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
                              'Send Reset Link',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Arial',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Back to Login Link
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
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
      ),
    );
  }
}
