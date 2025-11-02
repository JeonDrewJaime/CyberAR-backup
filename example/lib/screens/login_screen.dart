import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  String? _userNotFoundError;
  String? _userType;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // More yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  void initState() {
    super.initState();
    // Get user type from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _userType = args?['userType'];
    });
  }

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

  Future<void> _login() async {
    _validateEmail();
    _validatePassword();

    if (_emailError == null && _passwordError == null) {
      setState(() {
        _isLoading = true;
        _userNotFoundError = null; // Clear previous error
      });

      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navigate based on user type from button click
      if (_userType == 'teacher') {
        // Navigate to teacher dashboard
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/teacher-dashboard');
        }
      } else {
        // Navigate to student dashboard
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/student-dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowish,
      drawer: const AppDrawer(),
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
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 60),

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
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
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
                      // TODO: Implement forgot password functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Forgot password functionality not implemented yet'),
                        ),
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
      ),
    );
  }
}
