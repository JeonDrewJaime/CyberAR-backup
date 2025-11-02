import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class ModuleDetailsScreen extends StatefulWidget {
  final String moduleTitle;
  final String moduleNumber;
  final String content;
  final int? currentIndex;
  final List<Map<String, dynamic>>? modules;

  const ModuleDetailsScreen({
    super.key,
    required this.moduleTitle,
    required this.moduleNumber,
    required this.content,
    this.currentIndex,
    this.modules,
  });

  @override
  State<ModuleDetailsScreen> createState() => _ModuleDetailsScreenState();
}

class _ModuleDetailsScreenState extends State<ModuleDetailsScreen> {
  double _textSize = 16.0;
  late ScrollController _scrollController;
  bool _isScrolling = false;
  bool _dontShowTipsAgain = false;
  bool _dontShowARAgain = false;

  // Dark blue color
  static const Color darkBlue = Color(0xFF1E3A8A);
  // Yellowish background
  static const Color yellowish = Color(0xFFFFF59D);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Show tips dialog when module details page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTipsDialog();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrolling) return;

    final position = _scrollController.position;

    // Navigate to previous when scrolled to the very top
    if (position.pixels <= 0) {
      _isScrolling = true;
      _navigateToPrevious();
    }
    // Navigate to next when scrolled to the very bottom
    else if (position.pixels >= position.maxScrollExtent) {
      _isScrolling = true;
      _navigateToNext();
    }
  }

  void _navigateToPrevious() {
    if (widget.currentIndex == null || widget.modules == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation data not available'),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        _isScrolling = false;
      });
      return;
    }

    final currentIndex = widget.currentIndex!;
    if (currentIndex > 0) {
      final previousModule = widget.modules![currentIndex - 1];
      _navigateToModule(previousModule, currentIndex - 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the first module'),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        _isScrolling = false;
      });
    }
  }

  void _navigateToNext() {
    if (widget.currentIndex == null || widget.modules == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation data not available'),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        _isScrolling = false;
      });
      return;
    }

    final currentIndex = widget.currentIndex!;

    // Check if this is Module 4 (index 3) - the last regular module
    if (widget.moduleNumber == 'Module 4') {
      // Navigate to quiz starter
      Navigator.of(context).pushNamed('/quiz-starter');
      Future.delayed(const Duration(milliseconds: 500), () {
        _isScrolling = false;
      });
    } else if (currentIndex < widget.modules!.length - 1) {
      final nextModule = widget.modules![currentIndex + 1];
      _navigateToModule(nextModule, currentIndex + 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the last module'),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        _isScrolling = false;
      });
    }
  }

  void _navigateToModule(Map<String, dynamic> module, int index) {
    Navigator.of(context).pushReplacementNamed(
      '/module-details',
      arguments: {
        'moduleTitle': module['title'],
        'moduleNumber': module['number'],
        'content': _getModuleContent(module['title']),
        'currentIndex': index,
        'modules': widget.modules,
      },
    );
  }

  void _showTipsDialog() {
    if (_dontShowTipsAgain) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkBlue, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Light bulb icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Message text
                    const Text(
                      'Whenever you see a light bulb next to a title, it means helpful tips are waiting for you. Tap the icon to learn how to stay safe and protect yourself!',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),

                    // Don't show again checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _dontShowTipsAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowTipsAgain = value ?? false;
                            });
                          },
                          activeColor: darkBlue,
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Don\'t show this again.',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Next button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Show AR dialog after tips dialog is dismissed
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _showARDialog();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showARDialog() {
    if (_dontShowARAgain) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: yellowish,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkBlue, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AR Holographic Icon
                    Container(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Base platform (oval)
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 50,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(25),
                                border:
                                    Border.all(color: Colors.purple, width: 2),
                              ),
                            ),
                          ),
                          // Holographic cone/projector
                          Positioned(
                            bottom: 15,
                            child: Container(
                              width: 40,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.cyan.withOpacity(0.8),
                                    Colors.blue.withOpacity(0.6),
                                    Colors.purple.withOpacity(0.4),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  // Holographic lines effect
                                  Positioned(
                                    top: 5,
                                    left: 5,
                                    right: 5,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 5,
                                    right: 5,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 15,
                                    left: 5,
                                    right: 5,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Floating AR object (pink cube)
                          Positioned(
                            top: 5,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Additional floating elements
                          Positioned(
                            top: 15,
                            left: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 10,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.5),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Message text
                    const Text(
                      'Whenever you see this icon\nnext to a topic title, it\nindicates that Augmented\nReality content is available.\nTap the icon to Explore.',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Don't show again checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _dontShowARAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowARAgain = value ?? false;
                            });
                          },
                          activeColor: darkBlue,
                          checkColor: Colors.white,
                        ),
                        const Text(
                          'Don\'t show this again.',
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // OKAY button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'OKAY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUnityScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: darkBlue,
            title: const Text(
              'AR Experience',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: UnityWidget(
            // Unity widget configuration
            useAndroidViewSurface: true,
            onUnityCreated: (controller) {
              // Unity widget created
            },
            onUnityMessage: (message) {
              // Handle Unity messages
            },
            onUnitySceneLoaded: (scene) {
              // Handle scene loaded
            },
            fullscreen: false,
          ),
        ),
      ),
    );
  }

  String _getModuleContent(String moduleTitle) {
    // Return sample content based on module title
    switch (moduleTitle) {
      case 'COURSE OVERVIEW AND GOALS':
        return '''This module provides an introduction to the course objectives, learning outcomes, and the fundamental concepts that will be covered throughout the program. Students will understand the importance of cybersecurity in today's digital landscape and the career opportunities available in this field.

COURSE OBJECTIVES:
The primary objective of this course is to provide students with a comprehensive understanding of cybersecurity principles, practices, and technologies. Students will learn to identify, analyze, and mitigate various types of cyber threats and vulnerabilities.

LEARNING OUTCOMES:
Upon completion of this course, students will be able to:
1. Understand the fundamental concepts of cybersecurity
2. Identify common types of cyber threats and attacks
3. Implement basic security measures and best practices
4. Analyze security incidents and respond appropriately
5. Understand the legal and ethical aspects of cybersecurity

CYBERSECURITY FUNDAMENTALS:
Cybersecurity is the practice of protecting systems, networks, and programs from digital attacks. These cyberattacks are usually aimed at accessing, changing, or destroying sensitive information; extorting money from users; or interrupting normal business processes.

Implementing effective cybersecurity measures is particularly challenging today because there are more devices than people, and attackers are becoming more innovative. A cybersecurity approach has multiple layers of protection spread across the computers, networks, programs, or data that one intends to keep safe.

TYPES OF CYBER THREATS:
1. Malware - Malicious software such as viruses, worms, trojans, and ransomware
2. Phishing - Fraudulent attempts to obtain sensitive information
3. Social Engineering - Manipulating people to divulge confidential information
4. Advanced Persistent Threats (APTs) - Long-term targeted attacks
5. Insider Threats - Security risks from within the organization

SECURITY FRAMEWORKS:
Several frameworks and standards guide cybersecurity implementation:
- NIST Cybersecurity Framework
- ISO 27001/27002
- CIS Controls
- COBIT
- PCI DSS

CAREER OPPORTUNITIES:
The cybersecurity field offers numerous career paths including:
- Security Analyst
- Penetration Tester
- Security Architect
- Incident Responder
- Security Consultant
- Chief Information Security Officer (CISO)

INDUSTRY TRENDS:
Current trends in cybersecurity include:
- Artificial Intelligence in security
- Zero Trust Architecture
- Cloud Security
- IoT Security
- Quantum Cryptography
- DevSecOps

DETAILED CYBERSECURITY CONCEPTS:

CONFIDENTIALITY, INTEGRITY, AND AVAILABILITY (CIA TRIAD):
The CIA triad forms the foundation of cybersecurity:
- Confidentiality: Ensuring that information is accessible only to authorized users
- Integrity: Maintaining the accuracy and completeness of information
- Availability: Ensuring that authorized users have access to information when needed

AUTHENTICATION AND AUTHORIZATION:
Authentication is the process of verifying the identity of a user, system, or entity. Common authentication methods include:
- Password-based authentication
- Multi-factor authentication (MFA)
- Biometric authentication
- Certificate-based authentication
- Single Sign-On (SSO)

Authorization determines what authenticated users can do within a system. It involves:
- Role-based access control (RBAC)
- Attribute-based access control (ABAC)
- Discretionary access control (DAC)
- Mandatory access control (MAC)

THREAT LANDSCAPE ANALYSIS:
The modern threat landscape includes various attack vectors:

MALWARE TYPES:
1. Viruses: Self-replicating programs that attach to legitimate files
2. Worms: Standalone malicious programs that spread across networks
3. Trojans: Malicious programs disguised as legitimate software
4. Ransomware: Malware that encrypts files and demands payment
5. Spyware: Software that secretly monitors user activities
6. Adware: Software that displays unwanted advertisements
7. Rootkits: Tools that provide unauthorized access while hiding their presence

SOCIAL ENGINEERING ATTACKS:
Social engineering exploits human psychology to gain unauthorized access:
- Phishing: Fraudulent emails designed to steal information
- Spear phishing: Targeted phishing attacks against specific individuals
- Whaling: Phishing attacks targeting high-level executives
- Vishing: Voice-based phishing attacks
- Smishing: SMS-based phishing attacks
- Pretexting: Creating false scenarios to obtain information
- Baiting: Using physical media to spread malware
- Tailgating: Following authorized personnel into restricted areas

NETWORK SECURITY FUNDAMENTALS:
Network security involves protecting network infrastructure and data:
- Firewalls: Network security devices that monitor and control traffic
- Intrusion Detection Systems (IDS): Monitor network traffic for suspicious activity
- Intrusion Prevention Systems (IPS): Actively block malicious traffic
- Virtual Private Networks (VPNs): Secure connections over public networks
- Network segmentation: Isolating network segments to limit attack spread
- Wireless security: Protecting Wi-Fi networks from unauthorized access

ENCRYPTION AND CRYPTOGRAPHY:
Encryption is the process of converting plaintext into ciphertext to protect data:
- Symmetric encryption: Uses the same key for encryption and decryption
- Asymmetric encryption: Uses public and private key pairs
- Hash functions: One-way functions that create fixed-size outputs
- Digital signatures: Cryptographic mechanisms for authentication
- Certificate authorities: Trusted entities that issue digital certificates

INCIDENT RESPONSE FRAMEWORK:
Effective incident response follows a structured approach:
1. Preparation: Establishing incident response capabilities
2. Identification: Detecting and analyzing security incidents
3. Containment: Limiting the impact of security incidents
4. Eradication: Removing the cause of security incidents
5. Recovery: Restoring systems and services
6. Lessons Learned: Documenting and learning from incidents

RISK MANAGEMENT:
Risk management is the process of identifying, assessing, and mitigating risks:
- Risk assessment: Evaluating potential threats and vulnerabilities
- Risk mitigation: Implementing controls to reduce risks
- Risk acceptance: Acknowledging risks that cannot be mitigated
- Risk transfer: Using insurance or other means to transfer risk
- Risk avoidance: Eliminating activities that pose unacceptable risks

COMPLIANCE AND REGULATIONS:
Various regulations govern cybersecurity practices:
- General Data Protection Regulation (GDPR)
- Health Insurance Portability and Accountability Act (HIPAA)
- Payment Card Industry Data Security Standard (PCI DSS)
- Sarbanes-Oxley Act (SOX)
- Federal Information Security Management Act (FISMA)
- California Consumer Privacy Act (CCPA)

SECURITY AWARENESS AND TRAINING:
Human factors are often the weakest link in cybersecurity:
- Security awareness programs
- Phishing simulation exercises
- Incident reporting procedures
- Password security training
- Social engineering awareness
- Physical security measures

EMERGING TECHNOLOGIES:
New technologies present both opportunities and challenges:
- Artificial Intelligence and Machine Learning in security
- Internet of Things (IoT) security
- Cloud security considerations
- Mobile device security
- Blockchain and cryptocurrency security
- Quantum computing implications

CAREER DEVELOPMENT:
Building a successful cybersecurity career requires:
- Continuous learning and skill development
- Professional certifications
- Hands-on experience with security tools
- Networking with industry professionals
- Staying current with threat landscape
- Specializing in specific security domains

This comprehensive overview sets the foundation for understanding the critical role of cybersecurity in protecting our digital world and provides students with the knowledge needed to pursue successful careers in this dynamic field.''';

      case 'CYBERSECURITY':
        return '''Sometimes have to work odd hours and must constantly stay updated on the latest developments on both the security end and the attacking end. Many information technology experts feel that the best security architects are former hackers since they are adept at understanding how the hackers operate.

UNDERSTANDING THE CYBERSECURITY LANDSCAPE:
The cybersecurity landscape is constantly evolving, with new threats emerging daily. Security professionals must maintain a deep understanding of both defensive and offensive security techniques to effectively protect organizational assets.

THE HACKER MINDSET:
Understanding how attackers think and operate is crucial for effective defense. Former hackers often make excellent security professionals because they:
- Know the tools and techniques attackers use
- Understand the psychology behind social engineering
- Can think like an attacker to identify vulnerabilities
- Have hands-on experience with various attack vectors

SECURITY ARCHITECTURE PRINCIPLES:
Effective security architecture requires:
1. Defense in Depth - Multiple layers of security controls
2. Principle of Least Privilege - Minimal necessary access rights
3. Zero Trust Model - Never trust, always verify
4. Continuous Monitoring - Real-time threat detection
5. Incident Response Planning - Preparedness for security breaches

THREAT INTELLIGENCE:
Staying ahead of threats requires:
- Continuous monitoring of threat landscapes
- Understanding of attack methodologies
- Knowledge of emerging vulnerabilities
- Awareness of geopolitical factors affecting cybersecurity

SECURITY TOOLS AND TECHNOLOGIES:
Modern cybersecurity relies on various tools:
- SIEM (Security Information and Event Management)
- SOAR (Security Orchestration, Automation and Response)
- EDR (Endpoint Detection and Response)
- XDR (Extended Detection and Response)
- Threat Intelligence Platforms

INCIDENT RESPONSE:
When security incidents occur, professionals must:
1. Detect and analyze the incident
2. Contain the threat
3. Eradicate the cause
4. Recover systems and data
5. Learn from the incident
6. Document lessons learned

CONTINUOUS LEARNING:
The cybersecurity field requires continuous learning due to:
- Rapidly evolving threat landscape
- New technologies and attack vectors
- Changing regulations and compliance requirements
- Emerging security tools and techniques

ADVANCED CYBERSECURITY CONCEPTS:

PENETRATION TESTING METHODOLOGY:
Penetration testing follows a structured approach:
1. Reconnaissance: Gathering information about the target
2. Scanning: Identifying open ports and services
3. Enumeration: Discovering detailed information about services
4. Vulnerability Assessment: Identifying security weaknesses
5. Exploitation: Attempting to exploit vulnerabilities
6. Post-exploitation: Maintaining access and gathering data
7. Reporting: Documenting findings and recommendations

SECURITY OPERATIONS CENTER (SOC):
SOC teams are responsible for:
- 24/7 monitoring of security events
- Incident detection and analysis
- Threat hunting and investigation
- Security tool management
- Incident response coordination
- Threat intelligence integration

VULNERABILITY MANAGEMENT:
Effective vulnerability management includes:
- Asset discovery and inventory
- Vulnerability scanning and assessment
- Risk prioritization and scoring
- Patch management and remediation
- Vulnerability tracking and reporting
- Continuous monitoring and reassessment

SECURITY MONITORING AND LOGGING:
Comprehensive security monitoring requires:
- Centralized log collection and analysis
- Real-time event correlation
- Anomaly detection and behavioral analysis
- Threat hunting and investigation
- Security metrics and reporting
- Compliance monitoring and auditing

IDENTITY AND ACCESS MANAGEMENT (IAM):
IAM systems control user access to resources:
- User provisioning and deprovisioning
- Authentication and authorization
- Single sign-on (SSO) implementation
- Multi-factor authentication (MFA)
- Privileged access management (PAM)
- Identity governance and compliance

CLOUD SECURITY CONSIDERATIONS:
Cloud environments present unique security challenges:
- Shared responsibility model
- Cloud security controls and configurations
- Data encryption and key management
- Network security and segmentation
- Identity and access management
- Compliance and governance

MOBILE SECURITY:
Mobile devices require specialized security measures:
- Mobile device management (MDM)
- Application security and sandboxing
- Network security and VPNs
- Data encryption and protection
- Remote wipe and device control
- Mobile threat defense

SECURITY AUTOMATION:
Automation improves security efficiency:
- Security orchestration and automation
- Automated incident response
- Threat intelligence integration
- Vulnerability scanning automation
- Compliance monitoring automation
- Security workflow optimization

THREAT MODELING:
Threat modeling helps identify potential security risks:
- Asset identification and valuation
- Threat identification and analysis
- Vulnerability assessment
- Risk analysis and prioritization
- Mitigation strategy development
- Security control implementation

SECURITY TESTING METHODOLOGIES:
Various testing approaches ensure security:
- Static Application Security Testing (SAST)
- Dynamic Application Security Testing (DAST)
- Interactive Application Security Testing (IAST)
- Software Composition Analysis (SCA)
- Penetration testing and red team exercises
- Security code reviews and audits

SECURITY AWARENESS AND TRAINING:
Human factors remain critical in cybersecurity:
- Security awareness programs
- Phishing simulation and training
- Incident reporting procedures
- Password security best practices
- Social engineering awareness
- Physical security measures

EMERGING THREATS AND TRENDS:
The threat landscape continues to evolve:
- Artificial intelligence in cyberattacks
- Supply chain attacks and compromises
- Ransomware-as-a-Service (RaaS)
- Cryptocurrency and blockchain security
- Internet of Things (IoT) vulnerabilities
- Quantum computing implications

REGULATORY COMPLIANCE:
Various regulations govern cybersecurity practices:
- General Data Protection Regulation (GDPR)
- Health Insurance Portability and Accountability Act (HIPAA)
- Payment Card Industry Data Security Standard (PCI DSS)
- Sarbanes-Oxley Act (SOX)
- Federal Information Security Management Act (FISMA)
- California Consumer Privacy Act (CCPA)

SECURITY METRICS AND KPIs:
Measuring security effectiveness requires:
- Security incident metrics
- Vulnerability management metrics
- Compliance and audit metrics
- Security awareness metrics
- Threat detection and response metrics
- Risk assessment and mitigation metrics

BUSINESS CONTINUITY AND DISASTER RECOVERY:
Ensuring business resilience requires:
- Business impact analysis
- Recovery time objectives (RTO)
- Recovery point objectives (RPO)
- Backup and recovery procedures
- Crisis management planning
- Communication and coordination

This comprehensive understanding of cybersecurity principles and practices is essential for anyone entering the field and provides the foundation for advanced security roles and responsibilities.''';

      case 'CYBERSECURITY CAREER PATHS':
        return '''S/He works as an advisor and supervisor for all security measures necessary to protect a company or client's assets effectively. S/He uses his/her knowledge and expertise to assess possible security threats and breaches for prevention and create contingency protocols and plans for when violations occur. Also referred to as a white hat hacker s/he is an information security professional who uses hacking techniques to identify and fix security vulnerabilities in computer systems and networks.

SECURITY CONSULTANT ROLE:
Security consultants play a crucial role in helping organizations:
- Assess current security posture
- Identify vulnerabilities and risks
- Develop security strategies and policies
- Implement security controls and measures
- Provide training and awareness programs
- Conduct security audits and assessments

ETHICAL HACKER (PENETRATION TESTER):
Ethical hackers, also known as white hat hackers, use their skills to:
- Identify security vulnerabilities before malicious hackers
- Conduct authorized penetration testing
- Perform vulnerability assessments
- Test security controls and defenses
- Provide recommendations for security improvements
- Help organizations strengthen their security posture

CAREER PROGRESSION PATHS:
1. ENTRY LEVEL:
   - Security Analyst
   - Junior Penetration Tester
   - Security Operations Center (SOC) Analyst
   - Incident Response Analyst

2. MID-LEVEL:
   - Senior Security Analyst
   - Penetration Tester
   - Security Engineer
   - Security Consultant
   - Threat Intelligence Analyst

3. SENIOR LEVEL:
   - Security Architect
   - Senior Security Consultant
   - Security Manager
   - Principal Security Engineer
   - Security Director

4. EXECUTIVE LEVEL:
   - Chief Information Security Officer (CISO)
   - Chief Security Officer (CSO)
   - VP of Security
   - Security Executive

SPECIALIZED ROLES:
- Cloud Security Specialist
- IoT Security Expert
- Mobile Security Analyst
- Application Security Engineer
- Network Security Engineer
- Data Protection Officer
- Compliance Specialist
- Risk Management Professional

CERTIFICATIONS AND SKILLS:
Popular cybersecurity certifications include:
- CISSP (Certified Information Systems Security Professional)
- CEH (Certified Ethical Hacker)
- CISM (Certified Information Security Manager)
- CISA (Certified Information Systems Auditor)
- CompTIA Security+
- GSEC (GIAC Security Essentials)

SALARY EXPECTATIONS:
Cybersecurity professionals typically earn:
- Entry Level: \$50,000 - \$80,000
- Mid-Level: \$80,000 - \$120,000
- Senior Level: \$120,000 - \$180,000
- Executive Level: \$180,000+

INDUSTRY DEMAND:
The cybersecurity field is experiencing:
- High demand for skilled professionals
- Shortage of qualified candidates
- Competitive salaries and benefits
- Remote work opportunities
- Global career prospects

DETAILED CAREER PATH ANALYSIS:

SECURITY ANALYST CAREER PATH:
Security Analysts are the foundation of cybersecurity teams:
- Monitor security systems and networks
- Analyze security events and incidents
- Investigate security breaches and violations
- Generate security reports and documentation
- Collaborate with IT teams on security issues
- Stay current with threat intelligence

Required Skills:
- Network security fundamentals
- Security monitoring tools (SIEM, IDS/IPS)
- Incident response procedures
- Risk assessment methodologies
- Communication and reporting skills
- Analytical and problem-solving abilities

PENETRATION TESTER CAREER PATH:
Penetration Testers simulate cyberattacks to identify vulnerabilities:
- Conduct authorized security assessments
- Perform vulnerability scanning and analysis
- Execute penetration testing methodologies
- Document findings and recommendations
- Provide remediation guidance
- Stay current with attack techniques

Required Skills:
- Programming and scripting languages
- Network protocols and technologies
- Web application security
- Operating system security
- Social engineering techniques
- Report writing and presentation skills

SECURITY ARCHITECT CAREER PATH:
Security Architects design and implement security solutions:
- Design security architectures and frameworks
- Evaluate and select security technologies
- Develop security policies and procedures
- Lead security implementation projects
- Provide technical guidance to teams
- Ensure compliance with security standards

Required Skills:
- Enterprise security architecture
- Risk management and assessment
- Security frameworks and standards
- Project management
- Leadership and communication
- Business acumen and strategic thinking

INCIDENT RESPONSE SPECIALIST:
Incident Response Specialists handle security incidents:
- Detect and analyze security incidents
- Coordinate incident response activities
- Contain and eradicate threats
- Recover systems and data
- Document lessons learned
- Improve incident response processes

Required Skills:
- Digital forensics
- Malware analysis
- Network analysis
- Incident response procedures
- Communication and coordination
- Stress management and decision-making

THREAT INTELLIGENCE ANALYST:
Threat Intelligence Analysts research and analyze cyber threats:
- Collect and analyze threat intelligence
- Monitor threat actor activities
- Assess threat landscape and trends
- Provide threat intelligence reports
- Support security operations
- Collaborate with external organizations

Required Skills:
- Threat intelligence platforms
- Open source intelligence (OSINT)
- Malware analysis
- Data analysis and visualization
- Research and analytical skills
- Communication and presentation

CLOUD SECURITY SPECIALIST:
Cloud Security Specialists focus on cloud security:
- Design cloud security architectures
- Implement cloud security controls
- Monitor cloud security posture
- Ensure cloud compliance
- Manage cloud access and identity
- Optimize cloud security costs

Required Skills:
- Cloud platforms (AWS, Azure, GCP)
- Cloud security services
- Identity and access management
- Data protection and encryption
- Compliance frameworks
- Automation and orchestration

MOBILE SECURITY SPECIALIST:
Mobile Security Specialists secure mobile environments:
- Assess mobile security risks
- Implement mobile security controls
- Manage mobile device policies
- Monitor mobile security events
- Develop mobile security strategies
- Train users on mobile security

Required Skills:
- Mobile operating systems
- Mobile device management (MDM)
- Application security
- Network security
- Encryption and data protection
- User training and awareness

COMPLIANCE AND RISK SPECIALIST:
Compliance and Risk Specialists ensure regulatory compliance:
- Assess compliance requirements
- Implement compliance programs
- Conduct compliance audits
- Manage risk assessments
- Develop compliance policies
- Train staff on compliance requirements

Required Skills:
- Regulatory frameworks (GDPR, HIPAA, SOX)
- Risk management methodologies
- Audit procedures
- Policy development
- Training and education
- Communication and documentation

CAREER DEVELOPMENT STRATEGIES:

BUILDING TECHNICAL SKILLS:
- Hands-on experience with security tools
- Lab environments and practice platforms
- Capture the Flag (CTF) competitions
- Open source projects and contributions
- Continuous learning and certification
- Mentorship and networking

PROFESSIONAL DEVELOPMENT:
- Industry conferences and events
- Professional associations and memberships
- Online courses and training
- Books and technical publications
- Podcasts and webinars
- Professional networking

CERTIFICATION ROADMAP:
Entry Level Certifications:
- CompTIA Security+
- CompTIA Network+
- CompTIA A+
- ISC2 Associate

Mid-Level Certifications:
- Certified Ethical Hacker (CEH)
- Certified Information Security Manager (CISM)
- Certified Information Systems Auditor (CISA)
- GIAC Security Essentials (GSEC)

Advanced Certifications:
- Certified Information Systems Security Professional (CISSP)
- Certified Cloud Security Professional (CCSP)
- Offensive Security Certified Professional (OSCP)
- SANS GIAC certifications

SALARY AND COMPENSATION:
Factors affecting compensation:
- Geographic location
- Industry sector
- Company size and type
- Years of experience
- Education and certifications
- Specialized skills and expertise

Career advancement opportunities:
- Technical leadership roles
- Management positions
- Consulting and advisory roles
- Entrepreneurship and startups
- Academia and research
- Government and public sector

This comprehensive overview of cybersecurity career paths provides students with a clear understanding of the opportunities available in this dynamic and growing field, along with detailed guidance on career development and advancement strategies.''';

      default:
        return '''This module covers essential topics in cybersecurity, providing students with practical knowledge and skills needed to protect digital assets and understand security threats in modern computing environments.

INTRODUCTION TO CYBERSECURITY:
Cybersecurity is the practice of protecting systems, networks, and programs from digital attacks. These cyberattacks are usually aimed at accessing, changing, or destroying sensitive information; extorting money from users; or interrupting normal business processes.

KEY CONCEPTS:
1. Confidentiality - Ensuring information is accessible only to authorized users
2. Integrity - Maintaining the accuracy and completeness of information
3. Availability - Ensuring authorized users have access to information when needed
4. Authentication - Verifying the identity of users
5. Authorization - Determining what authenticated users can do
6. Non-repudiation - Ensuring actions cannot be denied

COMMON THREATS:
- Malware attacks
- Phishing schemes
- Social engineering
- Insider threats
- Advanced persistent threats (APTs)
- Distributed denial of service (DDoS) attacks

SECURITY MEASURES:
- Firewalls and intrusion detection systems
- Antivirus and anti-malware software
- Encryption technologies
- Access controls and authentication
- Security awareness training
- Regular security assessments

BEST PRACTICES:
- Keep software updated
- Use strong passwords
- Enable two-factor authentication
- Regular backups
- Employee training
- Incident response planning

COMPREHENSIVE CYBERSECURITY FOUNDATIONS:

FUNDAMENTAL SECURITY PRINCIPLES:
The foundation of cybersecurity rests on several core principles that guide all security efforts:

1. DEFENSE IN DEPTH:
   - Multiple layers of security controls
   - Redundant security measures
   - Fail-safe mechanisms
   - Comprehensive coverage across all systems

2. LEAST PRIVILEGE:
   - Minimal necessary access rights
   - Principle of need-to-know
   - Regular access reviews
   - Temporary access when possible

3. ZERO TRUST MODEL:
   - Never trust, always verify
   - Continuous authentication
   - Micro-segmentation
   - Dynamic access controls

4. SECURITY BY DESIGN:
   - Built-in security from the start
   - Secure development lifecycle
   - Threat modeling
   - Security testing integration

THREAT LANDSCAPE OVERVIEW:
Understanding the current threat landscape is crucial for effective cybersecurity:

MALWARE CATEGORIES:
1. Viruses: Self-replicating programs that attach to legitimate files
2. Worms: Standalone programs that spread across networks
3. Trojans: Malicious programs disguised as legitimate software
4. Ransomware: Malware that encrypts files and demands payment
5. Spyware: Software that secretly monitors activities
6. Adware: Software that displays unwanted advertisements
7. Rootkits: Tools that provide unauthorized access while hiding

SOCIAL ENGINEERING TECHNIQUES:
- Phishing: Fraudulent emails designed to steal information
- Spear Phishing: Targeted attacks against specific individuals
- Whaling: Attacks targeting high-level executives
- Vishing: Voice-based phishing attacks
- Smishing: SMS-based phishing attacks
- Pretexting: Creating false scenarios to obtain information
- Baiting: Using physical media to spread malware
- Tailgating: Following authorized personnel into restricted areas

NETWORK SECURITY FUNDAMENTALS:
Network security involves protecting network infrastructure and data:

FIREWALL TECHNOLOGIES:
- Packet filtering firewalls
- Stateful inspection firewalls
- Application-layer firewalls
- Next-generation firewalls
- Web application firewalls
- Cloud firewalls

INTRUSION DETECTION AND PREVENTION:
- Network-based IDS/IPS
- Host-based IDS/IPS
- Signature-based detection
- Anomaly-based detection
- Behavioral analysis
- Machine learning approaches

VIRTUAL PRIVATE NETWORKS (VPNs):
- Site-to-site VPNs
- Remote access VPNs
- SSL/TLS VPNs
- IPsec VPNs
- Mobile VPNs
- Cloud VPNs

ENCRYPTION AND CRYPTOGRAPHY:
Encryption is essential for protecting data at rest and in transit:

SYMMETRIC ENCRYPTION:
- Advanced Encryption Standard (AES)
- Data Encryption Standard (DES)
- Triple DES (3DES)
- Blowfish
- Twofish
- RC4

ASYMMETRIC ENCRYPTION:
- RSA (Rivest-Shamir-Adleman)
- Elliptic Curve Cryptography (ECC)
- Diffie-Hellman key exchange
- Digital Signature Algorithm (DSA)
- ElGamal encryption
- Paillier cryptosystem

HASH FUNCTIONS:
- Secure Hash Algorithm (SHA)
- Message Digest (MD5)
- RIPEMD
- BLAKE2
- Whirlpool
- Tiger

DIGITAL CERTIFICATES:
- X.509 certificate standard
- Certificate authorities (CAs)
- Public key infrastructure (PKI)
- Certificate revocation lists (CRLs)
- Online Certificate Status Protocol (OCSP)
- Certificate transparency

IDENTITY AND ACCESS MANAGEMENT:
IAM systems control user access to organizational resources:

AUTHENTICATION METHODS:
- Password-based authentication
- Multi-factor authentication (MFA)
- Biometric authentication
- Certificate-based authentication
- Single sign-on (SSO)
- Federated identity management

ACCESS CONTROL MODELS:
- Role-based access control (RBAC)
- Attribute-based access control (ABAC)
- Discretionary access control (DAC)
- Mandatory access control (MAC)
- Rule-based access control
- Risk-based access control

PRIVILEGED ACCESS MANAGEMENT:
- Privileged account discovery
- Password vaulting
- Session recording
- Just-in-time access
- Privilege escalation controls
- Audit and compliance

SECURITY MONITORING AND LOGGING:
Comprehensive security monitoring requires multiple components:

SECURITY INFORMATION AND EVENT MANAGEMENT (SIEM):
- Log collection and aggregation
- Event correlation and analysis
- Real-time monitoring
- Alert generation and management
- Incident response integration
- Compliance reporting

SECURITY ORCHESTRATION, AUTOMATION AND RESPONSE (SOAR):
- Playbook automation
- Incident response workflows
- Threat intelligence integration
- Security tool integration
- Case management
- Performance metrics

ENDPOINT DETECTION AND RESPONSE (EDR):
- Endpoint monitoring
- Behavioral analysis
- Threat detection
- Incident investigation
- Response automation
- Forensic capabilities

VULNERABILITY MANAGEMENT:
Effective vulnerability management is essential for maintaining security:

VULNERABILITY ASSESSMENT:
- Asset discovery and inventory
- Vulnerability scanning
- Configuration assessment
- Patch management
- Risk prioritization
- Remediation tracking

VULNERABILITY SCANNING TOOLS:
- Network vulnerability scanners
- Web application scanners
- Database scanners
- Container scanners
- Cloud security scanners
- Mobile application scanners

PATCH MANAGEMENT:
- Vulnerability tracking
- Patch testing
- Deployment automation
- Rollback procedures
- Compliance monitoring
- Change management

INCIDENT RESPONSE:
When security incidents occur, organizations must respond effectively:

INCIDENT RESPONSE LIFECYCLE:
1. Preparation: Establishing incident response capabilities
2. Identification: Detecting and analyzing security incidents
3. Containment: Limiting the impact of security incidents
4. Eradication: Removing the cause of security incidents
5. Recovery: Restoring systems and services
6. Lessons Learned: Documenting and learning from incidents

INCIDENT RESPONSE TEAM:
- Incident response manager
- Security analysts
- Forensic investigators
- Communications coordinator
- Legal counsel
- External experts

DIGITAL FORENSICS:
- Evidence collection and preservation
- Chain of custody procedures
- Forensic analysis tools
- Timeline reconstruction
- Evidence documentation
- Expert testimony

RISK MANAGEMENT:
Risk management is the process of identifying, assessing, and mitigating risks:

RISK ASSESSMENT METHODOLOGIES:
- Qualitative risk assessment
- Quantitative risk assessment
- Asset-based risk assessment
- Threat-based risk assessment
- Vulnerability-based risk assessment
- Scenario-based risk assessment

RISK TREATMENT OPTIONS:
- Risk avoidance: Eliminating activities that pose unacceptable risks
- Risk mitigation: Implementing controls to reduce risks
- Risk transfer: Using insurance or other means to transfer risk
- Risk acceptance: Acknowledging risks that cannot be mitigated
- Risk sharing: Distributing risks among multiple parties

COMPLIANCE AND REGULATIONS:
Various regulations govern cybersecurity practices:

MAJOR REGULATIONS:
- General Data Protection Regulation (GDPR)
- Health Insurance Portability and Accountability Act (HIPAA)
- Payment Card Industry Data Security Standard (PCI DSS)
- Sarbanes-Oxley Act (SOX)
- Federal Information Security Management Act (FISMA)
- California Consumer Privacy Act (CCPA)

COMPLIANCE FRAMEWORKS:
- NIST Cybersecurity Framework
- ISO 27001/27002
- CIS Controls
- COBIT
- ITIL
- COSO

SECURITY AWARENESS AND TRAINING:
Human factors are often the weakest link in cybersecurity:

TRAINING PROGRAMS:
- Security awareness training
- Phishing simulation exercises
- Incident reporting procedures
- Password security training
- Social engineering awareness
- Physical security measures

MEASURING EFFECTIVENESS:
- Training completion rates
- Phishing click rates
- Incident reporting metrics
- Security awareness surveys
- Behavioral change indicators
- Risk reduction measurements

EMERGING TECHNOLOGIES:
New technologies present both opportunities and challenges:

ARTIFICIAL INTELLIGENCE IN SECURITY:
- Machine learning for threat detection
- Automated incident response
- Behavioral analytics
- Predictive security
- Natural language processing
- Computer vision applications

INTERNET OF THINGS (IoT) SECURITY:
- Device authentication
- Secure communication protocols
- Firmware security
- Network segmentation
- Device management
- Privacy protection

CLOUD SECURITY:
- Shared responsibility model
- Cloud security controls
- Data encryption and key management
- Identity and access management
- Compliance and governance
- Security monitoring

QUANTUM COMPUTING:
- Quantum cryptography
- Post-quantum cryptography
- Quantum key distribution
- Quantum random number generation
- Quantum-resistant algorithms
- Quantum security protocols

BLOCKCHAIN SECURITY:
- Cryptocurrency security
- Smart contract security
- Consensus mechanism security
- Wallet security
- Exchange security
- Regulatory compliance

CAREER DEVELOPMENT:
Building a successful cybersecurity career requires continuous learning:

TECHNICAL SKILLS:
- Programming and scripting
- Network protocols and technologies
- Operating system security
- Database security
- Web application security
- Mobile security

SOFT SKILLS:
- Communication and presentation
- Problem-solving and analytical thinking
- Leadership and teamwork
- Project management
- Business acumen
- Continuous learning

PROFESSIONAL DEVELOPMENT:
- Industry certifications
- Hands-on experience
- Mentorship and networking
- Conferences and training
- Professional associations
- Continuous education

This module provides the foundation for understanding cybersecurity principles and their practical application in protecting digital assets, along with comprehensive coverage of advanced topics and career development strategies.''';
    }
  }

  void _showDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: yellowish,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(color: darkBlue, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text Size Adjustment
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: darkBlue, width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Adjust Text Size <${_textSize.toInt()}>',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _textSize,
                          min: 12.0,
                          max: 24.0,
                          divisions: 12,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                          onChanged: (value) {
                            setState(() {
                              _textSize = value;
                            });
                            // Also update the main widget's state
                            this.setState(() {
                              _textSize = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Back to Module List Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: darkBlue, width: 1),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close drawer
                        Navigator.of(context).pop(); // Go back to module list
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Back to Module List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowish,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'COURSES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Main Content Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Module Title with Icons
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.moduleTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Light bulb icon for tips
                      GestureDetector(
                        onTap: () {
                          _showTipsDialog();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // AR icon for augmented reality
                      GestureDetector(
                        onTap: () {
                          _showUnityScreen();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Base platform
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 20,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.purple, width: 1),
                                  ),
                                ),
                              ),
                              // Holographic cone
                              Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 16,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.cyan.withOpacity(0.8),
                                        Colors.blue.withOpacity(0.6),
                                        Colors.purple.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              // Floating AR object
                              Positioned(
                                top: 2,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.circular(1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pink.withOpacity(0.5),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Module Content with Scroll Indicators
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              widget.content,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _textSize,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        // Scroll to Previous Indicator (Top)
                        if (widget.currentIndex != null &&
                            widget.currentIndex! > 0)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    darkBlue.withOpacity(0.8),
                                    darkBlue.withOpacity(0.0),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        // Scroll to Next Indicator (Bottom)
                        if (widget.currentIndex != null &&
                            widget.modules != null &&
                            widget.currentIndex! < widget.modules!.length - 1)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    darkBlue.withOpacity(0.8),
                                    darkBlue.withOpacity(0.0),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Hamburger Menu
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: _showDrawer,
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
