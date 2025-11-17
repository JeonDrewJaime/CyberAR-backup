import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget_example/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InactivityService {
  static const Duration inactivityTimeout =
      Duration(minutes: 2); // Duration (2 minutes)
  Timer? _inactivityTimer; // Timer (1 second)
  DateTime _lastActivityTime = DateTime.now(); // DateTime today (current time)

  // SINGLETON PATTERN
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  // START TRACKING
  void startTracking(BuildContext context) {
    // SET THE LAST ACTIVITY TO CURRENT TIME
    _lastActivityTime = DateTime.now();
    // START THE TIMER
    _startTimer(context);
  }

  // STOP TRACKING
  void stopTracking() {
    // CANCEL THE TIMER
    _inactivityTimer?.cancel();
    // SET THE TIMER TO NULL
    _inactivityTimer = null;
  }

  // RESET TIMER
  void resetTimer(BuildContext context) {
    // SET THE LAST ACTIVITY TO CURRENT TIME
    _lastActivityTime = DateTime.now();
    // CANCEL THE TIMER FIRST
    _inactivityTimer?.cancel();

    // START THE TIMER AGAIN
    _startTimer(context);
  }

  // START TIMER (1 SECOND)
  void _startTimer(BuildContext context) {
    // START THE TIMER (1 SECOND)
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // GET THE CURRENT TIME
      final now = DateTime.now();
      // GET THE DIFFERENCE BETWEEN THE CURRENT TIME AND THE LAST ACTIVITY TIME
      final difference = now.difference(_lastActivityTime);
      // IF THE DIFFERENCE IS GREATER THAN THE INACTIVITY TIMEOUT, HANDLE THE INACTIVITY TIMEOUT
      if (difference >= inactivityTimeout) {
        // CANCEL THE TIMER
        timer.cancel();
        // HANDLE THE INACTIVITY TIMEOUT
        _handleInactivityTimeout(context);
      }
    });
  }

  // HANDLE INACTIVITY TIMEOUT
  Future<void> _handleInactivityTimeout(BuildContext context) async {
    // CLEAR PREFERENCES
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
    await prefs.remove('rememberMe');

    // SIGN OUT FROM FIREBASE
    await FirebaseService.auth.signOut();

    // NAVIGATE TO GET STARTED SCREEN
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/get-started',
        (route) => false,
      );
    }
  }

  // DISPOSE
  void dispose() {
    _inactivityTimer?.cancel();
  }
}
