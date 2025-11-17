import 'package:cloud_firestore/cloud_firestore.dart';

// ACHIEVEMENTS MODEL
class AchievementsModel {
  final Timestamp createdDate;
  final String description;
  final String title;

  AchievementsModel({
    required this.createdDate,
    required this.description,
    required this.title,
  });

  factory AchievementsModel.fromMap(Map<String, dynamic> data) {
    return AchievementsModel(
      createdDate: data['createdDate'] is Timestamp
          ? data['createdDate'] as Timestamp
          : data['createdDate'] is String
              ? Timestamp.fromDate(DateTime.parse(data['createdDate']))
              : Timestamp.now(),
      description: data['description'] ?? '',
      title: data['title'] ?? '',
    );
  }
}
