import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/components/my_snackbar.dart';
import 'package:flutter_unity_widget_example/services/auth_view_model.dart';
import 'package:flutter_unity_widget_example/utils/post_frame_callback.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';

class LoginScreen extends StatefulWidget {
  final String? userType;
  const LoginScreen({super.key, required this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  String? _userNotFoundError;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // More yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
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

  void _validatePassword() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password';
      });
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  Future<void> _login(
      AuthViewModel authViewModel, String email, password) async {
    _validateEmail();
    _validatePassword();

    if (_emailError == null && _passwordError == null) {
      await authViewModel.login(
          context, email, password, widget.userType ?? 'student');

      // Check if login was successful (no error means success)
      final loginSuccessful = authViewModel.errorMessage == null;

      if (loginSuccessful && mounted) {
        // Save remember me preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', _rememberMe);

        // Navigate directly to the correct dashboard based on userType
        if (widget.userType == 'teacher') {
          Navigator.of(context).pushReplacementNamed('/teacher-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/student-dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    // Only show error messages, not success (we navigate away immediately)
    runAfterBuild(() {
      if (authViewModel.errorMessage != null) {
        MySnackbar.show(
          context,
          authViewModel.errorMessage!,
          duration: const Duration(seconds: 3),
          icon: Icons.error,
        );
        authViewModel.clearMessage();
      }
    });

    return Scaffold(
      backgroundColor: yellowish,
      drawer: const AppDrawer(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome Text
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome',
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
                    'Back!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: royalBlue,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // User Not Found Error Message
                if (_userNotFoundError != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Text(
                      _userNotFoundError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: royalBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _emailController,
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
                      if (_userNotFoundError != null) {
                        setState(() {
                          _userNotFoundError = null;
                        });
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
                const SizedBox(height: 16),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: royalBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      if (_passwordError != null) {
                        _validatePassword();
                      }
                      if (_userNotFoundError != null) {
                        setState(() {
                          _userNotFoundError = null;
                        });
                      }
                    },
                  ),
                ),
                // Password Error
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _passwordError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Remember Me Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: royalBlue,
                      checkColor: Colors.white,
                      side: const BorderSide(color: royalBlue, width: 2),
                    ),
                    const Text(
                      'Remember me',
                      style: TextStyle(
                        color: royalBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authViewModel.isLoading
                        ? null
                        : () async {
                            _login(
                              authViewModel,
                              _emailController.text,
                              _passwordController.text,
                            );
                          },
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
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Arial',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Forgot Password Link
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/forgot-password',
                      arguments: {'email': _emailController.text},
                    );
                  },
                  child: const Text(
                    'Forgot Password',
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
