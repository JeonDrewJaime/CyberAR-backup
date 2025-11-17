import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/model/cyber_tip_model.dart';

import '../components/custom_button.dart';

/// Reusable Dialog for displaying flashcards/cyber tips
class DialogFlashcards extends StatefulWidget {
  /// List of cyber tips to display
  final List<CyberTipModel> cyberTips;

  /// Dialog title displayed in the header
  final String title;

  /// Main title displayed in the content area
  final String? mainTitle;

  /// Background color of the dialog
  final Color backgroundColor;

  /// Header background color
  final Color headerColor;

  /// Card background color
  final Color cardBackgroundColor;

  /// Card border color
  final Color cardBorderColor;

  /// Whether the dialog can be dismissed by tapping outside
  final bool barrierDismissible;

  /// Callback when dialog is closed
  final VoidCallback? onClose;

  DialogFlashcards({
    super.key,
    required this.cyberTips,
    this.title = 'Courses',
    this.mainTitle,
    this.backgroundColor = const Color(0xFFFFEB3B),
    this.headerColor = const Color(0xFF1565C0),
    this.cardBackgroundColor = const Color(0xFFC8E6C9),
    this.cardBorderColor = const Color(0xFF81C784),
    this.barrierDismissible = false,
    this.onClose,
  }) : assert(cyberTips.isNotEmpty, 'Cyber tips list cannot be empty');

  /// Show as dialog
  static Future<void> show(
    BuildContext context, {
    required List<CyberTipModel> cyberTips,
    String title = 'Courses',
    String? mainTitle,
    Color backgroundColor = const Color(0xFFFFEB3B),
    Color headerColor = const Color(0xFF1565C0),
    Color cardBackgroundColor = const Color(0xFFC8E6C9),
    Color cardBorderColor = const Color(0xFF81C784),
    bool barrierDismissible = false,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => DialogFlashcards(
        cyberTips: cyberTips,
        title: title,
        mainTitle: mainTitle,
        backgroundColor: backgroundColor,
        headerColor: headerColor,
        cardBackgroundColor: cardBackgroundColor,
        cardBorderColor: cardBorderColor,
        barrierDismissible: barrierDismissible,
        onClose: onClose,
      ),
    );
  }

  @override
  State<DialogFlashcards> createState() => _DialogFlashcardsState();
}

class _DialogFlashcardsState extends State<DialogFlashcards> {
  int _currentIndex = 0;

  void _goToPrevious() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        // Loop to last tip
        _currentIndex = widget.cyberTips.length - 1;
      }
    });
  }

  void _goToNext() {
    setState(() {
      if (_currentIndex < widget.cyberTips.length - 1) {
        _currentIndex++;
      } else {
        // Loop back to first tip
        _currentIndex = 0;
      }
    });
  }

  void _closeScreen() {
    widget.onClose?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentTip = widget.cyberTips[_currentIndex];
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.75,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Close button in top right
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _closeScreen,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 20, bottom: 20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Title
                  if (widget.mainTitle != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        widget.mainTitle!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.headerColor,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Main content card
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image only
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                currentTip.imagePath,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Page indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.cyberTips.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentIndex
                                    ? widget.headerColor
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Navigation buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Previous',
                          onPressed: _goToPrevious,
                          backgroundColor: widget.headerColor,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Next',
                          onPressed: _goToNext,
                          backgroundColor: widget.headerColor,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
