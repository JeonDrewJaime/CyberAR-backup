import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? userType;

  const AppDrawer({super.key, this.userType});

  // Royal blue colors
  static const Color royalBlue = Color(0xFF1E3A8A); // Dark royal blue
  static const Color lightBlue = Color(0xFF3B82F6); // Medium blue

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: royalBlue,
      child: Column(
        children: [
          // Header with user profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: lightBlue,
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: lightBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // User name
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shayne',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Impang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

  List<Widget> _buildMenuItems(BuildContext context) {
    if (userType == 'teacher') {
      // Teacher menu - only Dashboard and Profile
      return [
        _buildMenuItem(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          route: '/teacher-dashboard',
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.person,
          title: 'Profile',
          route: '/profile',
        ),
      ];
    } else {
      // Student menu - full menu
      return [
        _buildMenuItem(
          context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          route: '/student-dashboard',
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.school,
          title: 'Courses',
          route: '/courses',
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.newspaper,
          title: 'Cyber News',
          route: '/cybernews',
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.person,
          title: 'Profile',
          route: '/profile',
        ),
        const SizedBox(height: 20),
        _buildMenuItem(
          context,
          icon: Icons.help_outline,
          title: 'App Guide',
          route: '/app-guide',
        ),
      ];
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
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
        Navigator.pop(context); // Close drawer
        Navigator.pushNamed(context, route);
      },
    );
  }
}
