import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttemptModel {
  final String courseId;
  final int attemptsUsed;
  final int maxAttempts;
  final List<QuizScore> scores;
  final Timestamp? lastAttemptDate;
  final int cooldownMinutes;

  QuizAttemptModel({
    required this.courseId,
    required this.attemptsUsed,
    this.maxAttempts = 3,
    required this.scores,
    this.lastAttemptDate,
    this.cooldownMinutes = 10, //! 10 MINUTES PER RETRY
  });

  // Calculate current attempts used after regeneration
  int get currentAttemptsUsed {
    if (lastAttemptDate == null || attemptsUsed == 0) return attemptsUsed;

    final now = DateTime.now();
    final lastAttempt = lastAttemptDate!.toDate();
    final minutesElapsed = now.difference(lastAttempt).inMinutes;

    // Every 10 minutes restores 1 attempt (decreases attemptsUsed by 1)
    final attemptsRestored = minutesElapsed ~/ cooldownMinutes;
    final newAttemptsUsed = attemptsUsed - attemptsRestored;

    // Can't go below 0
    return newAttemptsUsed < 0 ? 0 : newAttemptsUsed;
  }

  // Get remaining attempts (considering regeneration)
  int get remainingAttempts => maxAttempts - currentAttemptsUsed;

  // Get best score
  int get bestScore {
    if (scores.isEmpty) return 0;
    return scores.map((s) => s.score).reduce((a, b) => a > b ? a : b);
  }

  // Get latest score
  QuizScore? get latestScore {
    if (scores.isEmpty) return null;
    return scores.last;
  }

  // Check if user has perfect score
  bool hasPerfectScore(int totalQuestions) {
    return bestScore == totalQuestions;
  }

  // Get time until next attempt regenerates (in seconds)
  int get secondsUntilNextAttempt {
    if (currentAttemptsUsed == 0 || lastAttemptDate == null) return 0;

    final now = DateTime.now();
    final lastAttempt = lastAttemptDate!.toDate();
    final secondsElapsed = now.difference(lastAttempt).inSeconds;
    final totalCooldownSeconds = cooldownMinutes * 60;

    // Calculate seconds until the next cooldown period completes
    final secondsInCurrentCycle = secondsElapsed % totalCooldownSeconds;
    final secondsUntilNextRestore =
        totalCooldownSeconds - secondsInCurrentCycle;

    return secondsUntilNextRestore;
  }

  // Check if cooldown is active (has any attempts being regenerated)
  bool get isCooldownActive {
    return currentAttemptsUsed > 0 && remainingAttempts == 0;
  }

  // Get remaining cooldown time in seconds (for next retry)
  int get remainingCooldownSeconds {
    return secondsUntilNextAttempt;
  }

  //! Format remaining time as MM:SS
  String get formattedCooldownTime {
    if (remainingCooldownSeconds <= 0) return '00:00';

    final minutes = remainingCooldownSeconds ~/ 60;
    final seconds = remainingCooldownSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  //! Check if user can attempt quiz
  bool canAttempt(int totalQuestions) {
    //! Can't attempt if perfect score
    if (hasPerfectScore(totalQuestions)) return false;

    //! Can attempt if has remaining tries (after regeneration)
    return remainingAttempts > 0;
  }

  factory QuizAttemptModel.fromMap(Map<String, dynamic> data) {
    return QuizAttemptModel(
      courseId: data['courseId'] ?? '',
      attemptsUsed: data['attemptsUsed'] ?? 0,
      maxAttempts: data['maxAttempts'] ?? 3,
      scores: (data['scores'] as List<dynamic>?)
              ?.map((score) => QuizScore.fromMap(score as Map<String, dynamic>))
              .toList() ??
          [],
      lastAttemptDate: data['lastAttemptDate'] as Timestamp?,
      cooldownMinutes: data['cooldownMinutes'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'attemptsUsed': attemptsUsed,
      'maxAttempts': maxAttempts,
      'scores': scores.map((s) => s.toMap()).toList(),
      'lastAttemptDate': lastAttemptDate,
      'cooldownMinutes': cooldownMinutes,
    };
  }
}

class QuizScore {
  final int score;

  QuizScore({
    required this.score,
  });

  factory QuizScore.fromMap(Map<String, dynamic> data) {
    return QuizScore(
      score: data['score'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
    };
  }
}
