/// Cyber Tip model for Courses feature
/// This is a sample project for learning Firebase and Dart
class CyberTipModel {
  final String imagePath;
  final int order;

  const CyberTipModel({
    required this.imagePath,
    required this.order,
  });

  /// Create from Map (for Firestore or JSON)
  factory CyberTipModel.fromMap(Map<String, dynamic> map) {
    return CyberTipModel(
      imagePath: map['imagePath'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'order': order,
    };
  }
}
