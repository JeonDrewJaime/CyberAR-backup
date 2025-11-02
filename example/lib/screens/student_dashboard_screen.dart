import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _dontShowAgain = false;
  bool _dontShowWelcomeAgain = false;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Text(
                      'Disclaimer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: royalBlue,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Content Text
                    const Text(
                      'All cybersecurity modules and materials presented in this application are based on the official curriculum and content provided by STI College Caloocan. All credits and acknowledgments belong to STI College Caloocan. This app is intended for educational purposes only.',
                      style: TextStyle(
                        fontSize: 16,
                        color: royalBlue,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowAgain = value ?? false;
                            });
                          },
                          activeColor: royalBlue,
                          checkColor: Colors.white,
                          side: const BorderSide(color: royalBlue, width: 2),
                        ),
                        const Text(
                          'Don\'t show this again',
                          style: TextStyle(
                            color: royalBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          if (_dontShowAgain) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('dont_show_disclaimer', true);
                          }
                          // Show welcome dialog after disclaimer
                          _showWelcomeDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: royalBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Robot Character
                    Container(
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Robot body
                          Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                // Robot head
                                Container(
                                  width: 60,
                                  height: 40,
                                  margin: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: royalBlue, width: 2),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '^_^',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: royalBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Robot body details
                                Container(
                                  width: 50,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: royalBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Speech bubble
                          Positioned(
                            top: 10,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: royalBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'WELCOME',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Welcome to the CyberAR App',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: royalBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Content Text
                    const Text(
                      'Need help navigating the app? You can view the App Guide from the menu to learn how to navigate and use the features of this app.',
                      style: TextStyle(
                        fontSize: 16,
                        color: royalBlue,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _dontShowWelcomeAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowWelcomeAgain = value ?? false;
                            });
                          },
                          activeColor: royalBlue,
                          checkColor: Colors.white,
                          side: const BorderSide(color: royalBlue, width: 2),
                        ),
                        const Text(
                          'Don\'t show this again',
                          style: TextStyle(
                            color: royalBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Go to App Guide Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          if (_dontShowWelcomeAgain) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('dont_show_welcome', true);
                          }
                          // TODO: Navigate to App Guide
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'App Guide functionality not implemented yet'),
                            ),
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
                        child: const Text(
                          'Go to App Guide',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Show disclaimer dialog after a short delay to ensure the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final dontShowDisclaimer = prefs.getBool('dont_show_disclaimer') ?? false;

      if (!dontShowDisclaimer) {
        _showDisclaimerDialog();
      } else {
        // Check if welcome dialog should be shown
        final dontShowWelcome = prefs.getBool('dont_show_welcome') ?? false;
        if (!dontShowWelcome) {
          _showWelcomeDialog();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowish,
      drawer: const AppDrawer(userType: 'student'),
      appBar: AppBar(
        backgroundColor: royalBlue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: royalBlue,
              ),
            ),
            const Text(
              'Student!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: royalBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start exploring and enhance your cybersecurity knowledge today!',
              style: TextStyle(
                fontSize: 16,
                color: royalBlue,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            // Courses in Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Courses in Progress',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: royalBlue,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/courses');
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 16,
                      color: royalBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: royalBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text
                  const Expanded(
                    child: Text(
                      'Looks like you haven\'t started a course yet. Browse the Course section in the menu and pick a topic to begin!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Cyber News Section
            const Text(
              'Cyber News',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: royalBlue,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: royalBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Image area
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.security,
                        size: 60,
                        color: royalBlue,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Understanding modes-of-threat in DeepSeek and other AI technologies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/cybernews');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: royalBlue,
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Colors.white, width: 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Read More',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
