import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/services/auth_service.dart';
import 'package:flutter_unity_widget_example/services/user_view_model.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/components/my_snackbar.dart';
import 'package:flutter_unity_widget_example/utils/post_frame_callback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch current user data
    final userId = FirebaseService.currentUsersId;
    if (userId != null) {
      final userViewModel = context.read<UserViewModel>();
      userViewModel.listenToUser(userId);
    }
    // Load saved avatar
    _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('selected_avatar');
    if (savedAvatar != null) {
      setState(() {
        _selectedAvatar = savedAvatar;
      });
    }
  }

  Future<void> _saveAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_avatar', avatarPath);
    setState(() {
      _selectedAvatar = avatarPath;
    });
  }

  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: yellowish, width: 4),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: yellowish,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Select Profile Icon',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: royalBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _avatars.length,
                    itemBuilder: (context, index) {
                      final avatarPath = _avatars[index];
                      final isSelected = _selectedAvatar == avatarPath;

                      return GestureDetector(
                        onTap: () async {
                          await _saveAvatar(avatarPath);
                          if (mounted) {
                            Navigator.of(context).pop();
                            MySnackbar.show(
                              context,
                              'Profile icon updated!',
                              icon: Icons.check,
                              backgroundColor: Colors.green,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? royalBlue : Colors.grey[300]!,
                              width: isSelected ? 4 : 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: royalBlue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              avatarPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Return Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'RETURN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
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
  }

  Future<void> logout() async {
    final auth = AuthService();

    // Clear saved preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
    await prefs.remove('rememberMe');

    await auth.signOut();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/get-started',
        (route) => false,
      );
    }
  }

  bool _showChangePassword = false;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedAvatar = 'assets/images/avatars/avatar_default.png';

  // List of available avatars
  final List<String> _avatars = [
    'assets/images/avatars/avatar_default.png',
    'assets/images/avatars/avatar_search.png',
    'assets/images/avatars/avatar_skull.png',
    'assets/images/avatars/avatar_boy.png',
    'assets/images/avatars/avatar_notebook.png',
    'assets/images/avatars/avatar_puzzle.png',
    'assets/images/avatars/avatar_hacker.png',
    'assets/images/avatars/avatar_shield_bug.png',
    'assets/images/avatars/avatar_girl.png',
    'assets/images/avatars/avatar_graduate_girl.png',
    'assets/images/avatars/avatar_graduate_boy.png',
  ];

  // Password requirements state
  bool _hasMinLength = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;

  void _validatePasswordRequirements(String password) {
    setState(() {
      _hasMinLength = password.length >= 12;
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
    });
  }

  bool get _passwordMeetsRequirements {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final requirementsMet = _hasMinLength &&
        _hasNumber &&
        _hasSpecialChar &&
        _hasUpperCase &&
        _hasLowerCase;
    final passwordsMatch =
        newPassword.isNotEmpty && newPassword == confirmPassword;

    return currentPassword.isNotEmpty && requirementsMet && passwordsMatch;
  }

  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  void _toggleChangePassword() {
    setState(() {
      _showChangePassword = !_showChangePassword;
    });
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final userId = FirebaseService.currentUsersId;
    final userEmail = FirebaseService.currentUsersEmail;

    // Check if user is logged in
    if (userId == null) {
      MySnackbar.show(
        context,
        'User not found',
        icon: Icons.error,
      );
      return;
    }

    // Validation
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      MySnackbar.show(
        context,
        'Please fill in all fields',
        icon: Icons.error,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      MySnackbar.show(
        context,
        'Passwords do not match',
        icon: Icons.error,
      );
      return;
    }

    // Validate all password requirements
    if (!_hasMinLength) {
      MySnackbar.show(
        context,
        'Password must be at least 12 characters',
        icon: Icons.error,
      );
      return;
    }

    if (!_hasNumber) {
      MySnackbar.show(
        context,
        'Password must include at least 1 number',
        icon: Icons.error,
      );
      return;
    }

    if (!_hasSpecialChar) {
      MySnackbar.show(
        context,
        'Password must include at least 1 special character',
        icon: Icons.error,
      );
      return;
    }

    if (!_hasUpperCase) {
      MySnackbar.show(
        context,
        'Password must include an uppercase character',
        icon: Icons.error,
      );
      return;
    }

    if (!_hasLowerCase) {
      MySnackbar.show(
        context,
        'Password must include a lowercase character',
        icon: Icons.error,
      );
      return;
    }

    // Re-authenticate before sensitive action
    try {
      if (userEmail == null) {
        MySnackbar.show(
          context,
          'User email not found',
          icon: Icons.error,
        );
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: userEmail,
        password: currentPassword,
      );

      await FirebaseService.auth.currentUser
          ?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      MySnackbar.show(
        context,
        e.message ??
            'Session expired. Please log in again before changing your password.',
        icon: Icons.error,
      );
      return;
    }

    // Update password using UserViewModel (updates both Auth and Firestore)
    final userViewModel = context.read<UserViewModel>();
    await userViewModel.updatePassword(userId, newPassword);

    // Clear fields on success
    if (userViewModel.errorMessage == null) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() {
        _showChangePassword = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.user;

    // Show success messages
    runAfterBuild(() {
      if (userViewModel.successMessage != null) {
        MySnackbar.show(
          context,
          userViewModel.successMessage!,
          duration: const Duration(seconds: 3),
          icon: Icons.check,
          backgroundColor: Colors.green,
        );
        userViewModel.clearMessage();
      }
    });

    // Show error messages
    runAfterBuild(() {
      if (userViewModel.errorMessage != null) {
        MySnackbar.show(
          context,
          userViewModel.errorMessage!,
          duration: const Duration(seconds: 3),
          icon: Icons.error,
        );
        userViewModel.clearMessage();
      }
    });

    return Container(
      color: yellowish,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                children: [
                  // Profile Information Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    color: yellowish,
                    child: Column(
                      children: [
                        // Avatar - Clickable to change
                        GestureDetector(
                          onTap: _showAvatarSelectionDialog,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: royalBlue, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                _selectedAvatar,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: royalBlue,
                                    size: 70,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Tap to change hint

                        const SizedBox(height: 20),
                        // Name from Firebase
                        Text(
                          user?.name ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Email from Firebase
                        Text(
                          user?.email ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        // Student Number (if exists)
                        // if (user?.studentNumber != null &&
                        //     user?.isTeacher != true) ...[
                        //   const SizedBox(height: 8),
                        //   Text(
                        //     'Student #: ${user!.studentNumber}',
                        //     style: const TextStyle(
                        //       fontSize: 14,
                        //       color: Colors.black54,
                        //     ),
                        //   ),
                        // ],
                        // // Section (if exists)
                        // if (user?.section != null &&
                        //     user?.isTeacher != true) ...[
                        //   const SizedBox(height: 4),
                        //   Text(
                        //     'Section: ${user!.section}',
                        //     style: const TextStyle(
                        //       fontSize: 14,
                        //       color: Colors.black54,
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  ),

                  // General Settings Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: royalBlue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'General Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_showChangePassword)
                          TextButton(
                            onPressed: _toggleChangePassword,
                            child: const Text(
                              'Return',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action Buttons Section or Change Password Form
                  if (!_showChangePassword) ...[
                    // Action Buttons Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: yellowish,
                      child: Column(
                        children: [
                          // Change Password Button
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: _toggleChangePassword,
                              icon: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                'Change Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: royalBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Log Out Button
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate back to login screen
                                // Navigator.of(context).pushNamedAndRemoveUntil(
                                //   '/login',
                                //   (route) => false,
                                // );
                                logout();
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 16,
                              ),
                              label: const Text(
                                'Log Out',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Change Password Form
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: yellowish,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Change Password Header
                          const Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Current Password Field
                          TextField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrentPassword,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Enter Current Password',
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureCurrentPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureCurrentPassword =
                                        !_obscureCurrentPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // New Password Field
                          TextField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            onChanged: _validatePasswordRequirements,
                            decoration: InputDecoration(
                              hintText: 'Enter New Password',
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password Field
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Change Password Button
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: userViewModel.isLoading ||
                                      !_passwordMeetsRequirements
                                  ? null
                                  : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _passwordMeetsRequirements
                                    ? royalBlue
                                    : Colors.grey,
                                disabledBackgroundColor: Colors.grey.shade400,
                                disabledForegroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 1,
                              ),
                              child: userViewModel.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'CHANGE PASSWORD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Requirements
                          const Text(
                            'Password Strength',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordRequirement(
                              'Must be atleast 12 characters long',
                              _hasMinLength),
                          _buildPasswordRequirement(
                              'Must include atleast 1 number', _hasNumber),
                          _buildPasswordRequirement(
                              'Must include atleast 1 special character',
                              _hasSpecialChar),
                          _buildPasswordRequirement(
                              'An uppercase character', _hasUpperCase),
                          _buildPasswordRequirement(
                              'A lowercase character', _hasLowerCase),
                        ],
                      ),
                    ),
                  ],

                  // Spacer to push content to fill screen when short
                  SizedBox(
                    height: _showChangePassword
                        ? 40
                        : MediaQuery.of(context).size.height * 0.2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requirement,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? Colors.green : Colors.red,
                fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
