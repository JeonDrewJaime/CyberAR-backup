import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/screens/forgot_password_screen.dart';
import 'package:flutter_unity_widget_example/screens/overall_result_screen.dart';
import 'package:flutter_unity_widget_example/services/user_repository.dart';
import 'package:flutter_unity_widget_example/services/user_view_model.dart';
import 'package:flutter_unity_widget_example/services/module_repository.dart';
import 'package:flutter_unity_widget_example/services/module_view_model.dart';
import 'package:flutter_unity_widget_example/services/assessment_repository.dart';
import 'package:flutter_unity_widget_example/services/assessment_view_model.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_repository.dart';
import 'package:flutter_unity_widget_example/services/quiz_attempt_view_model.dart';
import 'package:flutter_unity_widget_example/services/teacher_dashboard_repository.dart';
import 'package:flutter_unity_widget_example/services/teacher_dashboard_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_unity_widget_example/firebase_options.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:flutter_unity_widget_example/services/auth_gate.dart';
import 'package:flutter_unity_widget_example/services/auth_service.dart';
import 'package:flutter_unity_widget_example/services/auth_view_model.dart';
import 'package:flutter_unity_widget_example/widgets/student_widget_tree.dart';
import 'package:flutter_unity_widget_example/widgets/teacher_widget_tree.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
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

/* THE MAIN FUNCTION THAT RUNS THE APP 
FEATURES:
- MULTIPROVIDER
- INITIAL SCREEN: CHECKS FOR AUTHENTICATION AND NAVIGATES ACCORDINGLY
- FIREBASE AUTHENTICATION: CHECKS AUTHENTICATION AND SIGN OUT
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        //! AUTH
        ChangeNotifierProvider(create: (_) => AuthViewModel(AuthService())),
        //! USERS
        ChangeNotifierProvider(create: (_) => UserViewModel(UserRepository())),
        //! MODULES
        ChangeNotifierProvider(
            create: (_) => ModuleViewModel(ModuleRepository())),
        //! ASSESSMENTS
        ChangeNotifierProvider(
            create: (_) => AssessmentViewModel(AssessmentRepository())),
        //! QUIZ SUBMISSIONS
        ChangeNotifierProvider(
            create: (_) => QuizAttemptViewModel(QuizAttemptRepository())),
        //! TEACHER DASHBOARD
        ChangeNotifierProvider(
            create: (_) =>
                TeacherDashboardViewModel(TeacherDashboardRepository())),
      ],
      //! MY APP
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ROOT
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberAR',
      // REMOVE FLAG BANNER
      debugShowCheckedModeBanner: false,
      // THEME OF THE APP
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // CALL THE INITIAL SCREEN
      home: const InitialScreen(),
      // ROUTING
      routes: {
        //! GET STARTED
        '/get-started': (context) => const GetStartedScreen(),

        //! AUTH
        '/auth': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return AuthGate(userType: args?['userType'] as String?);
        },

        //! LOGIN
        '/login': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return LoginScreen(userType: args?['userType'] as String?);
        },

        //! FORGOT PASSWORD
        '/forgot-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return ForgotPasswordScreen(
            email: args?['email'] as String? ?? '',
          );
        },

        //! DASHBOARD
        '/dashboard': (context) => const DashboardScreen(),

        //! STUDENT DASHBOARD
        '/student-dashboard': (context) => const StudentWidgetTree(),

        //! TEACHER DASHBOARD
        '/teacher-dashboard': (context) => const TeacherWidgetTree(),

        //! COURSES
        '/courses': (context) => const CoursesScreen(),

        //! COURSE MODULES
        '/course-modules': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return CourseModulesScreen(
            courseId: args['courseId'],
            initialLessonIndex: args['initialLessonIndex'] as int?,
          );
        },

        //! MODULE DETAILS
        '/module-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ModuleDetailsScreen(
            courseId: args['courseId'],
            currentIndex: args['currentIndex'],
          );
        },

        //! MENU
        '/menu': (context) => const MenuScreen(),

        //! CYBER NEWS
        '/cybernews': (context) => const CyberNewsScreen(),

        //! PROFILE
        '/profile': (context) => const ProfileScreen(),

        //! APP GUIDE
        '/app-guide': (context) => const AppGuideScreen(),

        //! QUIZ STARTER
        '/quiz-starter': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return QuizStarterScreen(
            assessment: args?['assessment'],
            courseId: args?['courseId'],
            assessmentId: args?['assessmentId'],
            moduleTitle: args?['moduleTitle'],
            forceFetchAssessment:
                args?['forceFetchAssessment'] as bool? ?? false,
          );
        },

        //! QUIZ COUNTDOWN
        '/quiz-countdown': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return QuizCountdownScreen(
            assessment: args?['assessment'],
            courseId: args?['courseId'],
            assessmentId: args?['assessmentId'],
          );
        },

        //! QUIZ QUESTIONS
        '/quiz-questions': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return QuizQuestionsScreen(
            assessment: args?['assessment'],
            courseId: args?['courseId'],
            assessmentId: args?['assessmentId'],
          );
        },

        //! QUIZ RESULT FAILED
        '/quiz-result-failed': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return QuizResultFailedScreen(
            score: args['score'],
            totalQuestions: args['totalQuestions'],
            hasNextModule: args['hasNextModule'] ?? true,
            courseId: args['courseId'],
            assessmentId: args['assessmentId'] as String?,
            moduleTitle: args['moduleTitle'] as String?,
            assessment: args['assessment'],
          );
        },

        //! QUIZ RESULT SUCCESS
        '/quiz-result-success': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return QuizResultSuccessScreen(
            score: args['score'],
            totalQuestions: args['totalQuestions'],
            courseId: args['courseId'],
            assessmentId: args['assessmentId'] as String?,
            moduleTitle: args['moduleTitle'] as String?,
            assessment: args['assessment'],
          );
        },

        //! OVERALL RESULT
        '/overall-result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return OverallResultScreen(
            allCourseDone: args['allCourseDone'],
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

// INITIAL SCREEN THAT CHECKS AUTHENTICATION AND ROUTES ACCORDINGLY
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  // FUNCTION TO CHECK AUTHENTICATION AND NAVIGATE ACCORDINGLY
  Future<void> _checkAuthAndNavigate() async {
    // GET CURRENT USER
    final user = FirebaseService.currentUser;

    // CREATE INSTANCE OF SHARED PREFERENCES
    final prefs = await SharedPreferences.getInstance();

    // GET USER TYPE
    final savedUserType = prefs.getString('userType');

    // GET REMEMBER ME
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    // CHECK IF CONTEXT IS MOUNTED
    if (!mounted) return;

    // AUTO-LOGIN IF USER IS NOT NULL, USER TYPE IS NOT NULL, AND REMEMBER ME IS TRUE
    if (user != null && savedUserType != null && rememberMe) {
      // NAVIGATE TO AUTH GATE WITH USER TYPE
      Navigator.of(context).pushReplacementNamed(
        '/auth',
        arguments: {'userType': savedUserType},
      );
    } else {
      // SIGN OUT IF USER IS NOT NULL AND REMEMBER ME IS FALSE
      if (user != null && !rememberMe) {
        await FirebaseService.auth.signOut();
      }
      // NAVIGATE TO GET STARTED SCREEN
      Navigator.of(context).pushReplacementNamed('/get-started');
    }
  }

  // LOAD PROGRESS INDICATOR WHILE CHECKING AUTHENTICATION
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
