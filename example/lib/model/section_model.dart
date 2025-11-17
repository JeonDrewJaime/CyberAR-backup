import 'package:cloud_firestore/cloud_firestore.dart';

class SectionModel {
  final String name;
  final String department;
  final Timestamp createdDate;
  final String year;

  SectionModel({
    required this.name,
    required this.department,
    required this.createdDate,
    required this.year,
  });

  // Read
  factory SectionModel.fromMap(Map<String, dynamic> data) {
    return SectionModel(
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      createdDate: data['createdDate'] is Timestamp
          ? data['createdDate'] as Timestamp
          : data['createdDate'] is String
              ? Timestamp.fromDate(DateTime.parse(data['createdDate']))
              : Timestamp.now(),
      year: data['year'] ?? '',
    );
  }

  // Write
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'createdDate': createdDate,
      'year': year,
    };
  }
}
