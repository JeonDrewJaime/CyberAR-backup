import 'package:flutter/material.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowish,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'Let\'s Get',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: royalBlue,
                  ),
                ),
                const Text(
                  'Started!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 60),

                // Teacher Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen with teacher parameter
                      Navigator.of(context).pushReplacementNamed('/login',
                          arguments: {'userType': 'teacher'});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: royalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'TEACHER LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Student Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen with student parameter
                      Navigator.of(context).pushReplacementNamed('/login',
                          arguments: {'userType': 'student'});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: royalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'STUDENT LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
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
