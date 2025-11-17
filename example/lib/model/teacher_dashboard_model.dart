import 'package:flutter_unity_widget_example/model/user_model.dart';

// TEACHER STUDENT MODEL, THE STUDENT INFORMATION AND ITS ID
class TeacherStudent {
  final String id;
  final UserModel user;

  TeacherStudent({
    required this.id,
    required this.user,
  });
}

// STUDENT QUIZ SCORE MODEL
class StudentQuizScore {
  final String quizName;
  final int maxScore;
  final int? score;

  const StudentQuizScore({
    required this.quizName,
    required this.maxScore,
    required this.score,
  });

  double? get percentage {
    if (score == null || maxScore == 0) return null;
    return (score! / maxScore) * 100;
  }
}

// TEACHER STUDENT PROGRESS MODEL
class TeacherStudentProgress {
  final String userId;
  final String name;
  final String email;
  final String? section;
  final String? studentNumber;
  final int coursesCompleted;
  final int totalCourses;
  final int quizPercentage;
  final bool certificateAvailable;
  final List<StudentQuizScore> quizScores;

  const TeacherStudentProgress({
    required this.userId,
    required this.name,
    required this.email,
    required this.section,
    required this.studentNumber,
    required this.coursesCompleted,
    required this.totalCourses,
    required this.quizPercentage,
    required this.certificateAvailable,
    required this.quizScores,
  });
}
