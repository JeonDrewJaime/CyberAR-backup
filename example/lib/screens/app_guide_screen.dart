import 'package:flutter/material.dart';

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color yellowish = Color(0xFFFFF59D);

  // GET ALL STARTED
  List<String> _getGetStartedImages() {
    return List.generate(
        13, (index) => 'assets/images/appguide/get_started${index + 1}.png');
  }

  // GET ALL USING MODULES
  List<String> _getUsingModulesImages() {
    return List.generate(
        10, (index) => 'assets/images/appguide/using_modules${index + 1}.png');
  }

  // GET ALL ACCOUNT SETTINGS
  List<String> _getAccountSettingsImages() {
    return List.generate(9,
        (index) => 'assets/images/appguide/account_settings${index + 1}.png');
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: royalBlue,
          fontFamily: 'Arial',
        ),
      ),
    );
  }

  Widget _buildImageItem(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowish,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //! GET STARTED SECTION
            _buildSectionTitle('Get Started'),
            ..._getGetStartedImages()
                .map((imagePath) => _buildImageItem(imagePath)),

            const SizedBox(height: 24),

            //! USING MODULES SECTION
            _buildSectionTitle('Using Modules'),
            ..._getUsingModulesImages()
                .map((imagePath) => _buildImageItem(imagePath)),

            const SizedBox(height: 24),

            //! ACCOUNT SETTINGS SECTION
            _buildSectionTitle('Account Settings'),
            ..._getAccountSettingsImages()
                .map((imagePath) => _buildImageItem(imagePath)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
