import 'package:flutter/material.dart';
// import 'package:flutter_unity_widget_example/screens/no_interaction_screen.dart';
// import 'package:flutter_unity_widget_example/screens/orientation_screen.dart';

import 'menu_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/course_modules_screen.dart';
import 'screens/module_details_screen.dart';
import 'screens/cybernews_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/app_guide_screen.dart';
import 'screens/quiz_starter_screen.dart';
import 'screens/quiz_countdown_screen.dart';
import 'screens/quiz_questions_screen.dart';
import 'screens/quiz_result_failed_screen.dart';
import 'screens/quiz_result_success_screen.dart';
// import 'screens/api_screen.dart';
// import 'screens/loader_screen.dart';
// import 'screens/simple_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/student-dashboard': (context) => const StudentDashboardScreen(),
        '/teacher-dashboard': (context) => const TeacherDashboardScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/course-modules': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return CourseModulesScreen(
            courseTitle: args['courseTitle'],
            moduleCount: args['moduleCount'],
          );
        },
        '/module-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ModuleDetailsScreen(
            moduleTitle: args['moduleTitle'],
            moduleNumber: args['moduleNumber'],
            content: args['content'],
            currentIndex: args['currentIndex'],
            modules: args['modules'],
          );
        },
        '/menu': (context) => const MenuScreen(),
        '/cybernews': (context) => const CyberNewsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/app-guide': (context) => const AppGuideScreen(),
        '/quiz-starter': (context) => const QuizStarterScreen(),
        '/quiz-countdown': (context) => const QuizCountdownScreen(),
        '/quiz-questions': (context) => const QuizQuestionsScreen(),
        '/quiz-result-failed': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return QuizResultFailedScreen(
            score: args['score'],
            totalQuestions: args['totalQuestions'],
            hasNextModule: args['hasNextModule'] ?? true,
          );
        },
        '/quiz-result-success': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return QuizResultSuccessScreen(
            score: args['score'],
            totalQuestions: args['totalQuestions'],
          );
        },
        // '/simple': (context) => const SimpleScreen(),
        // '/loader': (context) => const LoaderScreen(),
        // '/orientation': (context) => const OrientationScreen(),
        // '/api': (context) => const ApiScreen(),
        // '/none': (context) => const NoInteractionScreen(),
      },
    );
  }
}
