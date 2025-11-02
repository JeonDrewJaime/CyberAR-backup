import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  bool _dontShowAgain = false;
  bool _dontShowWelcomeAgain = false;
  Map<String, bool> _expandedStudents = {};
  String _selectedSection = 'BT101';
  bool _isAscending = true;

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  // Sample student data
  final List<Map<String, dynamic>> _allStudents = [
    {
      'id': '1',
      'name': 'Dela Cruz, Juan',
      'section': 'BT101',
      'coursesCompleted': 3,
      'totalCourses': 7,
      'quizPercentage': 90,
      'certificateAvailable': true,
    },
    {
      'id': '2',
      'name': 'Impang, Shayne',
      'section': 'BT101',
      'coursesCompleted': 5,
      'totalCourses': 7,
      'quizPercentage': 55,
      'certificateAvailable': false,
    },
    {
      'id': '3',
      'name': 'Santos, Maria',
      'section': 'BT102',
      'coursesCompleted': 2,
      'totalCourses': 7,
      'quizPercentage': 75,
      'certificateAvailable': false,
    },
    {
      'id': '4',
      'name': 'Garcia, Pedro',
      'section': 'BT101',
      'coursesCompleted': 4,
      'totalCourses': 7,
      'quizPercentage': 85,
      'certificateAvailable': true,
    },
    {
      'id': '5',
      'name': 'Lopez, Ana',
      'section': 'BT102',
      'coursesCompleted': 6,
      'totalCourses': 7,
      'quizPercentage': 92,
      'certificateAvailable': true,
    },
  ];

  List<String> _sections = ['BT101', 'BT102', 'BT103', 'BT104'];

  List<Map<String, dynamic>> get _filteredStudents {
    List<Map<String, dynamic>> filtered = _allStudents
        .where((student) => student['section'] == _selectedSection)
        .toList();

    // Sort by name
    filtered.sort((a, b) {
      if (_isAscending) {
        return a['name'].compareTo(b['name']);
      } else {
        return b['name'].compareTo(a['name']);
      }
    });

    return filtered;
  }

  void _toggleStudent(String studentId) {
    setState(() {
      _expandedStudents[studentId] = !(_expandedStudents[studentId] ?? false);
    });
  }

  void _selectSection(String section) {
    setState(() {
      _selectedSection = section;
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  void _showSectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Section',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 20),
                ..._sections
                    .map((section) => ListTile(
                          title: Text(
                            section,
                            style: TextStyle(
                              color: _selectedSection == section
                                  ? royalBlue
                                  : Colors.black,
                              fontWeight: _selectedSection == section
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: _selectedSection == section
                              ? Icon(Icons.check, color: royalBlue)
                              : null,
                          onTap: () {
                            _selectSection(section);
                            Navigator.of(context).pop();
                          },
                        ))
                    .toList(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: royalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _viewCertificate(String studentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Certificate',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: yellowish,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: royalBlue, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 60,
                        color: royalBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Certificate of Completion',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        studentName,
                        style: TextStyle(
                          fontSize: 16,
                          color: royalBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: royalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _viewQuizScores(String studentName) {
    // Get quiz scores for the specific student
    List<Map<String, dynamic>> quizScores =
        _getQuizScoresForStudent(studentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: yellowish,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: royalBlue, width: 1),
                  ),
                  child: Column(
                    children: quizScores
                        .map((quiz) => _buildQuizScoreRow(
                            quiz['quizName'], quiz['score'], quiz['maxScore']))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: royalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getQuizScoresForStudent(String studentName) {
    // Sample quiz scores for different students
    Map<String, List<Map<String, dynamic>>> studentQuizScores = {
      'Dela Cruz, Juan': [
        {'quizName': 'Quiz 1', 'score': 10, 'maxScore': 15},
        {'quizName': 'Quiz 2', 'score': 7, 'maxScore': 15},
        {'quizName': 'Quiz 3', 'score': 8, 'maxScore': 15},
        {'quizName': 'Quiz 4', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 5', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 6', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 7', 'score': null, 'maxScore': 15},
      ],
      'Impang, Shayne': [
        {'quizName': 'Quiz 1', 'score': 8, 'maxScore': 15},
        {'quizName': 'Quiz 2', 'score': 6, 'maxScore': 15},
        {'quizName': 'Quiz 3', 'score': 9, 'maxScore': 15},
        {'quizName': 'Quiz 4', 'score': 7, 'maxScore': 15},
        {'quizName': 'Quiz 5', 'score': 5, 'maxScore': 15},
        {'quizName': 'Quiz 6', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 7', 'score': null, 'maxScore': 15},
      ],
      'Santos, Maria': [
        {'quizName': 'Quiz 1', 'score': 12, 'maxScore': 15},
        {'quizName': 'Quiz 2', 'score': 11, 'maxScore': 15},
        {'quizName': 'Quiz 3', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 4', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 5', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 6', 'score': null, 'maxScore': 15},
        {'quizName': 'Quiz 7', 'score': null, 'maxScore': 15},
      ],
    };

    return studentQuizScores[studentName] ?? [];
  }

  Widget _buildQuizScoreRow(String quizName, int? score, int maxScore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              quizName,
              style: const TextStyle(
                fontSize: 14,
                color: royalBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            score != null ? '$score/$maxScore' : '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: score != null
                  ? (score >= (maxScore * 0.8)
                      ? Colors.green
                      : score >= (maxScore * 0.6)
                          ? Colors.orange
                          : Colors.red)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

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
      drawer: const AppDrawer(userType: 'teacher'),
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
          'Teacher Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                const SizedBox(height: 20),
                const Text(
                  'Welcome back Teacher!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select a section to',
                  style: TextStyle(
                    fontSize: 18,
                    color: royalBlue,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  'view student progress.',
                  style: TextStyle(
                    fontSize: 18,
                    color: royalBlue,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),

                // Section Dropdown
                GestureDetector(
                  onTap: () => _showSectionDialog(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: royalBlue, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedSection,
                          style: const TextStyle(
                            fontSize: 16,
                            color: royalBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: royalBlue,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: royalBlue, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: royalBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 16,
                          color: royalBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Student Progress Cards - Scrollable
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.5, // Set a fixed height for scrollable area
                  child: ListView.builder(
                    itemCount: _filteredStudents.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(_filteredStudents[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Sort Icon fixed at bottom
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _toggleSortOrder,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: royalBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sort,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isAscending ? 'A' : 'Z',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isAscending ? 'Z' : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final isExpanded = _expandedStudents[student['id']] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Student Header (Always Visible)
          GestureDetector(
            onTap: () => _toggleStudent(student['id']),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: royalBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    student['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: yellowish,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(color: royalBlue, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Info Row (Courses, Percentage, Certificate)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Course Progress
                      Row(
                        children: [
                          Icon(Icons.book, color: royalBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${student['coursesCompleted']}/${student['totalCourses']}',
                            style: TextStyle(
                              color: royalBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Quiz Percentage
                      Row(
                        children: [
                          Icon(Icons.quiz, color: royalBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${student['quizPercentage']}%',
                            style: TextStyle(
                              color: royalBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Certificate Status
                      Row(
                        children: [
                          Icon(
                            student['certificateAvailable']
                                ? Icons.emoji_events
                                : Icons.emoji_events_outlined,
                            color: student['certificateAvailable']
                                ? Colors.orange
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            student['certificateAvailable']
                                ? 'Available'
                                : 'Not yet available',
                            style: TextStyle(
                              color: student['certificateAvailable']
                                  ? Colors.orange
                                  : Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons (Stacked Vertically)
                  Column(
                    children: [
                      // View Quiz Scores Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _viewQuizScores(student['name']),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8),
                          ),
                          child: Text(
                            'View all quiz scores',
                            style: TextStyle(
                              color: royalBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // View Certificate Button (only if available)
                      if (student['certificateAvailable'])
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => _viewCertificate(student['name']),
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8),
                            ),
                            child: Text(
                              'View certificate',
                              style: TextStyle(
                                color: royalBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
