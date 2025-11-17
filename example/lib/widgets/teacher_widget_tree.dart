import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/screens/teacher_dashboard_screen.dart';
import 'package:flutter_unity_widget_example/screens/courses_screen.dart';
import 'package:flutter_unity_widget_example/screens/cybernews_screen.dart';
import 'package:flutter_unity_widget_example/screens/profile_screen.dart';
import 'package:flutter_unity_widget_example/screens/app_guide_screen.dart';
import 'package:flutter_unity_widget_example/widgets/inactivity_wrapper.dart';
import 'package:flutter_unity_widget_example/widgets/app_drawer.dart';

// ValueNotifier for page selection - accessible throughout teacher tree
final ValueNotifier<int> teacherPageNotifier = ValueNotifier<int>(0);

class TeacherWidgetTree extends StatefulWidget {
  const TeacherWidgetTree({super.key});

  @override
  State<TeacherWidgetTree> createState() => _TeacherWidgetTreeState();
}

class _TeacherWidgetTreeState extends State<TeacherWidgetTree> {
  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    // Reset to dashboard when tree is created
    teacherPageNotifier.value = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Get page title based on index
  String _getPageTitle(int selectedPage) {
    switch (selectedPage) {
      case 0:
        return 'Teacher Dashboard';
      case 1:
        return 'Courses';
      case 2:
        return 'Cyber News';
      case 3:
        return 'App Guide';
      case 4:
        return 'Profile';
      default:
        return 'Teacher Dashboard';
    }
  }

  // Get the current page based on selectedPage index
  Widget _getPage(int selectedPage) {
    switch (selectedPage) {
      case 0:
        return const TeacherDashboardScreen();
      case 1:
        return const CoursesScreen();
      case 2:
        return const CyberNewsScreen();
      case 3:
        return const AppGuideScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const TeacherDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InactivityWrapper(
      child: ValueListenableBuilder<int>(
        valueListenable: teacherPageNotifier,
        builder: (context, selectedPage, child) {
          return Scaffold(
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
              title: Text(
                _getPageTitle(selectedPage),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: _getPage(selectedPage),
          );
        },
      ),
    );
  }
}
