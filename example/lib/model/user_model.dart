import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final Timestamp createdDate;
  final String email;
  final String name;
  final bool? isTeacher;
  final String password;
  final String? section;
  final String? studentNumber;
  final Timestamp? updatedDate;

  UserModel({
    required this.createdDate,
    required this.email,
    required this.name,
    this.isTeacher,
    required this.password,
    this.section,
    this.studentNumber,
    this.updatedDate,
  });

  // Read
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      createdDate: data['createdDate'] is Timestamp
          ? data['createdDate'] as Timestamp
          : data['createdDate'] is String
              ? Timestamp.fromDate(DateTime.parse(data['createdDate']))
              : Timestamp.now(),
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      isTeacher: data['isTeacher'] as bool?,
      password: data['password'] ?? '',
      section: data['section'] ?? '',
      studentNumber: data['studentNumber'] ?? '',
      updatedDate: data['updatedDate'] != null
          ? (data['updatedDate'] is Timestamp
              ? data['updatedDate'] as Timestamp
              : data['updatedDate'] is String
                  ? Timestamp.fromDate(DateTime.parse(data['updatedDate']))
                  : Timestamp.now())
          : null,
    );
  }

  // Write
  Map<String, dynamic> toMap() {
    return {
      'createdDate': createdDate,
      'email': email,
      'name': name,
      'isTeacher': isTeacher,
      'password': password,
      'section': section,
      'studentNumber': studentNumber,
      'updatedDate': updatedDate,
    };
  }
}
