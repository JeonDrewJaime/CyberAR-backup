import 'package:cloud_firestore/cloud_firestore.dart';

// MODULE MODEL
class ModuleModel {
  final String id;
  final Timestamp createdDate;
  final String description;
  final List<Lesson> lessons;
  final String moduleNumber;
  final String title;

  ModuleModel({
    required this.id,
    required this.createdDate,
    required this.description,
    required this.lessons,
    required this.moduleNumber,
    required this.title,
  });

  factory ModuleModel.empty(String id) {
    return ModuleModel(
      id: id,
      createdDate: Timestamp.now(),
      description: '',
      lessons: const [],
      moduleNumber: '',
      title: '',
    );
  }

  // READ
  factory ModuleModel.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModuleModel(
      id: doc.id,
      createdDate: data['createdDate'] is Timestamp
          ? data['createdDate'] as Timestamp
          : data['createdDate'] is String
              ? Timestamp.fromDate(DateTime.parse(data['createdDate']))
              : Timestamp.now(),
      description: data['description'] ?? '',
      lessons: (data['lessons'] as List<dynamic>?)
              ?.map((lesson) => Lesson.fromMap(lesson as Map<String, dynamic>))
              .toList() ??
          [],
      moduleNumber: data['moduleNumber'] ?? '',
      title: data['title'] ?? '',
    );
  }

  // Write
  Map<String, dynamic> toMap() {
    return {
      'createdDate': createdDate,
      'description': description,
      'lessons': lessons.map((lesson) => lesson.toMap()).toList(),
      'moduleNumber': moduleNumber,
      'title': title,
    };
  }

  //! CALCULATE COURSE STATUS BASED ON LESSONS
  String getStatusForUser(String userId) {
    if (lessons.isEmpty) return 'not_started';

    //! COMPLETED COUNT
    int completedCount = 0;
    //! TOTAL LESSONS
    int totalLessons = lessons.length;

    for (var lesson in lessons) {
      final lessonStatus = lesson.status[userId] ?? 'not_started';
      if (lessonStatus == 'completed') {
        completedCount++;
      }
    }

    if (completedCount == totalLessons) {
      return 'completed';
    } else if (completedCount > 0) {
      return 'in_progress';
    } else {
      return 'not_started';
    }
  }
}

// LESSON MODEL
class Lesson {
  final String content;
  final int id;
  final Map<String, String> status;
  final String title;

  Lesson({
    required this.content,
    required this.id,
    required this.status,
    required this.title,
  });

  factory Lesson.fromMap(Map<String, dynamic> data) {
    return Lesson(
      content: data['content'] ?? '',
      id: data['id'] ?? 0,
      status: (data['status'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          {},
      title: data['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'id': id,
      'status': status.map((key, value) => MapEntry(key, value)),
      'title': title,
    };
  }
}
