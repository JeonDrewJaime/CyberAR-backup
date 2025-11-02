import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // Royal blue color
  static const Color royalBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  Map<String, bool> _expandedCourses = {};

  final List<Map<String, dynamic>> courses = [
    {
      'title': 'INFORMATION SYSTEMS SECURITY',
      'number': 'Course: 1',
      'isUnlocked': true,
      'modules': [
        'Module 1: Introduction to Information Security',
        'Module 2: Security Fundamentals',
        'Module 3: Risk Assessment',
        'Module 4: Security Policies',
        'Module 5: Access Control',
      ],
    },
    {
      'title': 'SECURITY CONCEPTS AND GOALS',
      'number': 'Course: 2',
      'isUnlocked': false,
      'modules': [
        'Module 1: Security Concepts Overview',
        'Module 2: CIA Triad',
        'Module 3: Security Goals',
        'Module 4: Threat Analysis',
      ],
    },
    {
      'title': 'TYPICAL DOMAINS OF IT INFRASTRUCTURE',
      'number': 'Course: 3',
      'isUnlocked': false,
      'modules': [
        'Module 1: Network Infrastructure',
        'Module 2: Server Infrastructure',
        'Module 3: Database Systems',
        'Module 4: Application Security',
      ],
    },
    {
      'title': 'SECURITY SYSTEMS ENGINEERING (PART 1)',
      'number': 'Course: 4',
      'isUnlocked': false,
      'modules': [
        'Module 1: Systems Engineering Basics',
        'Module 2: Security Architecture',
        'Module 3: Design Principles',
        'Module 4: Implementation Planning',
      ],
    },
    {
      'title': 'SECURITY SYSTEMS ENGINEERING (PART 2)',
      'number': 'Course: 5',
      'isUnlocked': false,
      'modules': [
        'Module 1: Advanced Architecture',
        'Module 2: Security Controls',
        'Module 3: Monitoring Systems',
        'Module 4: Maintenance and Updates',
      ],
    },
    {
      'title': 'THREAT LANDSCAPE',
      'number': 'Course: 6',
      'isUnlocked': false,
      'modules': [
        'Module 1: Threat Types',
        'Module 2: Attack Vectors',
        'Module 3: Threat Intelligence',
        'Module 4: Mitigation Strategies',
      ],
    },
    {
      'title': 'ONTOLOGY OF MALWARE',
      'number': 'Course: 7',
      'isUnlocked': false,
      'modules': [
        'Module 1: Malware Classification',
        'Module 2: Virus Analysis',
        'Module 3: Trojan Detection',
        'Module 4: Prevention Methods',
      ],
    },
  ];

  void _toggleCourse(String courseTitle) {
    setState(() {
      _expandedCourses[courseTitle] = !(_expandedCourses[courseTitle] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowish,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: royalBlue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Courses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Available Courses',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: royalBlue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final isExpanded = _expandedCourses[course['title']] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        // Course Card Header
                        GestureDetector(
                          onTap: () => _toggleCourse(course['title']),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: royalBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Security Shield Icon
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.security,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Course Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        course['number'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Expand/Collapse Icon
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expanded Modules Section
                        if (isExpanded)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              border: Border.all(color: royalBlue, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Modules:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: royalBlue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...course['modules']
                                    .map<Widget>((module) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.play_circle_outline,
                                                color: royalBlue,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  module,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: royalBlue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                const SizedBox(height: 16),

                                // Action Button
                                if (course['isUnlocked'])
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          '/course-modules',
                                          arguments: {
                                            'courseTitle': course['title'],
                                            'moduleCount':
                                                course['modules'].length,
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: royalBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Start Course'),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Course Locked',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
