import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';

class AuthGate extends StatefulWidget {
  final String? userType;
  const AuthGate({super.key, this.userType});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateBasedOnRole(User user, String userType) async {
    try {
      // Get user data from Firestore
      final doc = await FirebaseService.firestore
          .collection("users")
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        // print('User document not found in Firestore');
        // Navigator.of(context).pushReplacementNamed('/student-dashboard');
        return;
      }

      final data = doc.data()!;
      final isTeacher = data['isTeacher'] as bool? ?? false;

      // Navigate immediately based on actual Firestore role
      if (isTeacher && userType == 'teacher') {
        Navigator.of(context).pushReplacementNamed('/teacher-dashboard');
      } else if (!isTeacher && userType == 'student') {
        Navigator.of(context).pushReplacementNamed('/student-dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/student-dashboard');
      }
    } catch (e) {
      print('Error navigating based on role: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/student-dashboard');
      }
    }
  }

  void _navigateToLogin(String userType) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/login',
          arguments: {'userType': userType},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Not logged in → Go to Login Screen with userType
          if (!snapshot.hasData || snapshot.data == null) {
            if (widget.userType != null) {
              _navigateToLogin(widget.userType!);
            } else {
              // If no userType provided, go to get started screen
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/get-started');
                }
              });
            }
            return const Center(child: CircularProgressIndicator());
          }

          // Logged in → Navigate directly to dashboard based on Firestore role
          print('User logged in, fetching role and navigating to dashboard');
          _navigateBasedOnRole(snapshot.data!, widget.userType!);
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
