import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/services/user_view_model.dart';
import 'package:flutter_unity_widget_example/widgets/student_widget_tree.dart';
import 'package:flutter_unity_widget_example/widgets/teacher_widget_tree.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  final String? userType;

  const AppDrawer({super.key, this.userType});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _profileImagePath;

  // APP COLORS
  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color lightBlue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    // LOAD IMAGE
    _loadProfileImage();
    // LISTEN TO THIS USER AND FETCH ALL DATA RELATED TO THIS USER
    final userId = FirebaseService.currentUsersId;
    final userViewModel = context.read<UserViewModel>();
    userViewModel.listenToUser(userId!);
  }

  // LOAD PROFILE IMAGE FROM SHARED PREFERENCES
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('selected_avatar');
    // IF IN USE THEN SET THE STATE
    if (mounted) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }

  // BUILD THE DRAWER
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: royalBlue,
      child: Column(
        children: [
          // HEADER (PROFILE IMAGE AND USER NAME)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: lightBlue,
            ),
            child: Row(
              children: [
                // AVATAR (PROFILE IMAGE)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  // IMAGE
                  child: ClipOval(
                    child: _profileImagePath != null
                        ? Image.asset(
                            _profileImagePath!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if image fails to load
                              return const Icon(
                                Icons.person,
                                color: lightBlue,
                                size: 35,
                              );
                            },
                          )
                        // IF NOT IN USE THEN SHOW DEFAULT ICON
                        : const Icon(
                            Icons.person,
                            color: lightBlue,
                            size: 35,
                          ),
                  ),
                ),

                const SizedBox(width: 16),
                // USER NAME FROM FIRESTORE
                Expanded(
                  child: Consumer<UserViewModel>(
                    builder: (context, userViewModel, child) {
                      final userName = userViewModel.user?.name ?? 'Student';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: _buildMenuItems(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MENU ITEMS AT THE BOTTOM OF THE PROFILE IMAGE AND USER NAME
  List<Widget> _buildMenuItems(BuildContext context) {
    if (widget.userType == 'teacher') {
      // TEACHER MENU: DASHBOARD, PROFILE
      return [
        _buildMenuItem(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          pageIndex: 0,
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.person,
          title: 'Profile',
          pageIndex: 4,
        ),
      ];
    } else {
      // STUDENT MENU: DASHBOARD, COURSES, NEWS, APP GUIDE, PROFILE
      return [
        _buildMenuItem(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          pageIndex: 0,
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.school,
          title: 'Courses',
          pageIndex: 1,
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.newspaper,
          title: 'Cyber News',
          pageIndex: 2,
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.help_outline,
          title: 'App Guide',
          pageIndex: 3,
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.person,
          title: 'Profile',
          pageIndex: 4,
        ),
      ];
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int pageIndex,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        // NAVIGATOR
        final navigator = Navigator.of(context);

        // CLOSE DRAWER FIRST
        Navigator.pop(context);

        // DETERMINE ROUTE NAME BASED ON USER TYPE
        final targetRouteName = widget.userType == 'teacher'
            ? '/teacher-dashboard'
            : '/student-dashboard';

        // POP ANY STACKED UNTIL WE REACH THE MAIN DASHBOARD ROUTE
        navigator.popUntil((route) {
          final name = route.settings.name;
          if (name == targetRouteName) {
            return true;
          }
          // RETURN TRUE IF THE VIEW IS NOW IN DASHBOARD
          return route.isFirst;
        });

        // CHECK THE USER TYPE AND SET THE PAGE INDEX ACCORDINGLY
        if (widget.userType == 'teacher') {
          teacherPageNotifier.value = pageIndex;
        } else {
          studentPageNotifier.value = pageIndex;
        }
      },
    );
  }
}
