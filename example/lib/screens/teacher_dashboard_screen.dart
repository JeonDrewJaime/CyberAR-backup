import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_unity_widget_example/model/teacher_dashboard_model.dart';
import 'package:flutter_unity_widget_example/services/teacher_dashboard_view_model.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  // DON'T SHOW AGAIN FLAG FOR DISCLAIMER AND WELCOME DIALOG
  bool _dontShowAgain = false;
  bool _dontShowWelcomeAgain = false;

  // EXPANDED STUDENTS MAP
  final Map<String, bool> _expandedStudents = {};

  // ORDER BY ASCENDING OR DESCENDING
  bool _isAscending = true;

  // SEARCH QUERY
  String _searchQuery = '';

  // SEARCH CONTROLLER
  late final TextEditingController _searchController;

  // ROYAL BLUE COLOR
  static const Color royalBlue = Color(0xFF1E3A8A);

  // YELLOWISH BACKGROUND
  static const Color yellowish = Color(0xFFFFF59D);

  // TOGGLE EXPANDED STUDENTS
  void _toggleStudent(String studentId) {
    setState(() {
      _expandedStudents[studentId] = !(_expandedStudents[studentId] ?? false);
    });
  }

  // FILTER STUDENTS
  List<TeacherStudentProgress> _filterStudents(
      List<TeacherStudentProgress> students) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = students.where((student) {
      if (query.isEmpty) return true;

      final nameMatch = student.name.toLowerCase().contains(query);

      final numberMatch =
          (student.studentNumber ?? '').toLowerCase().contains(query);

      final emailMatch = student.email.toLowerCase().contains(query);

      return nameMatch || numberMatch || emailMatch;
    }).toList();

    filtered.sort((a, b) {
      if (_isAscending) {
        return a.name.compareTo(b.name);
      } else {
        return b.name.compareTo(a.name);
      }
    });

    return filtered;
  }

  // TOGGLE SORT
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
    });
  }

  void _showSectionDialog(TeacherDashboardViewModel viewModel) {
    final sections = viewModel.sections;
    final selectedSection = viewModel.selectedSection;

    if (sections.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
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
                    'No sections available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: royalBlue,
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
      return;
    }

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
                ...sections
                    .map((section) => ListTile(
                          title: Text(
                            section,
                            style: TextStyle(
                              color: selectedSection == section
                                  ? royalBlue
                                  : Colors.black,
                              fontWeight: selectedSection == section
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: selectedSection == section
                              ? Icon(Icons.check, color: royalBlue)
                              : null,
                          onTap: () {
                            viewModel.selectSection(section, force: true);
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
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: _wrapDialogContent(
            context,
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: _buildCertificatePreview(studentName),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
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
  }

  void _viewQuizScores(TeacherStudentProgress student) {
    final quizScores = student.quizScores;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: _wrapDialogContent(
            context,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    student.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: royalBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (quizScores.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: yellowish,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: royalBlue, width: 1),
                      ),
                      child: const Text(
                        'No quiz submissions yet.',
                        style: TextStyle(
                          color: royalBlue,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (quizScores.isNotEmpty)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: yellowish,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: royalBlue, width: 1),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: quizScores
                                .map((quiz) => _buildQuizScoreRow(quiz))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
          ),
        );
      },
    );
  }

  Widget _buildQuizScoreRow(StudentQuizScore quiz) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              quiz.quizName,
              style: const TextStyle(
                fontSize: 14,
                color: royalBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 20),
          Text(
            quiz.score != null && quiz.maxScore > 0
                ? '${quiz.score}/${quiz.maxScore}'
                : '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: quiz.score != null && quiz.maxScore > 0
                  ? (quiz.score! >= (quiz.maxScore * 0.8)
                      ? Colors.green
                      : quiz.score! >= (quiz.maxScore * 0.6)
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
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
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
                          const Expanded(
                            child: Text(
                              'Don\'t show this again',
                              style: TextStyle(
                                color: royalBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
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
                              final prefs =
                                  await SharedPreferences.getInstance();
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
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Center(
                          child: Image.asset(
                            'assets/images/welcome_robot.png', // <-- your image path
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
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
                          const Expanded(
                            child: Text(
                              'Don\'t show this again',
                              style: TextStyle(
                                color: royalBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
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
                              final prefs =
                                  await SharedPreferences.getInstance();
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TeacherDashboardViewModel>().initialize();
      if (!mounted) return;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherDashboardViewModel>(
      builder: (context, viewModel, child) {
        final sections = viewModel.sections;
        final selectedSection = viewModel.selectedSection;
        final students = _filterStudents(viewModel.students);
        final hasInitialLoader = viewModel.isLoading && !viewModel.hasStudents;
        final errorMessage = viewModel.errorMessage;

        final validIds = viewModel.students.map((s) => s.userId).toSet();
        _expandedStudents.removeWhere((key, value) => !validIds.contains(key));

        final sectionLabel = selectedSection ??
            (sections.isEmpty ? 'No sections yet' : 'Select section');

        return Scaffold(
          backgroundColor: yellowish,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    GestureDetector(
                      onTap: () => _showSectionDialog(viewModel),
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
                              sectionLabel,
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText:
                                    'Search by name, student number, or email',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: royalBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: royalBlue),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (errorMessage != null && errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: hasInitialLoader
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: royalBlue,
                              ),
                            )
                          : students.isEmpty
                              ? Center(
                                  child: Text(
                                    selectedSection == null
                                        ? 'Select a section to view students.'
                                        : 'No students found for $sectionLabel.',
                                    style: const TextStyle(
                                      color: royalBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: students.length,
                                  itemBuilder: (context, index) {
                                    return _buildStudentCard(students[index]);
                                  },
                                ),
                    ),
                  ],
                ),
              ),
              if (students.length > 1)
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
                          const Icon(
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
      },
    );
  }

  Widget _buildStudentCard(TeacherStudentProgress student) {
    final isExpanded = _expandedStudents[student.userId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Student Header (Always Visible)
          GestureDetector(
            onTap: () => _toggleStudent(student.userId),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: royalBlue,
                borderRadius: !isExpanded
                    ? BorderRadius.circular(8)
                    : BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      student.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.book, color: royalBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${student.coursesCompleted}/${student.totalCourses}',
                            style: TextStyle(
                              color: royalBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz, color: royalBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${student.quizPercentage}%',
                            style: TextStyle(
                              color: royalBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            student.certificateAvailable
                                ? Icons.emoji_events
                                : Icons.emoji_events_outlined,
                            color: student.certificateAvailable
                                ? Colors.orange
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            student.certificateAvailable
                                ? 'Available'
                                : 'Not yet available',
                            style: TextStyle(
                              color: student.certificateAvailable
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
                          onPressed: () => _viewQuizScores(student),
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
                      if (student.certificateAvailable)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => _viewCertificate(student.name),
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

  Widget _wrapDialogContent(BuildContext context, Widget child) {
    final size = MediaQuery.of(context).size;
    final maxWidth = math.min(size.width * 0.9, 480.0);
    final minWidth = math.min(size.width * 0.7, maxWidth);
    final maxHeight = size.height * 0.85;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: child,
      ),
    );
  }

  Widget _buildCertificatePreview(String studentName) {
    const aspectRatio = 2000 / 1414;
    final displayName =
        studentName.trim().isEmpty ? 'CyberAR Student' : studentName.trim();

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/orig_certificate.png',
            fit: BoxFit.cover,
          ),
          Align(
            alignment: const Alignment(0, -0.08),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const originalWidthPx = 2000.0;
                const nameLineWidthPx = 1300.0;
                final nameBoxWidth =
                    constraints.maxWidth * (nameLineWidthPx / originalWidthPx);

                final baseFontSize =
                    (constraints.maxWidth / originalWidthPx) * 160;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(
                    width: nameBoxWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        displayName.toUpperCase(),
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: baseFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 0.8,
                          fontFamily: 'Times New Roman',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
