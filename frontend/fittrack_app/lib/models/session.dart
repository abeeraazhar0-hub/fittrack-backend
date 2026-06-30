// class SessionSummary {
//   final int totalReps;
//   final int correctReps;
//   final double accuracyPercent;
//   final int durationSeconds;
//
//   SessionSummary({
//     required this.totalReps,
//     required this.correctReps,
//     required this.accuracyPercent,
//     required this.durationSeconds,
//   });
//
//   factory SessionSummary.fromJson(Map<String, dynamic> json) {
//     return SessionSummary(
//       totalReps: json['total_reps'],
//       correctReps: json['correct_reps'],
//       accuracyPercent: (json['accuracy_percent'] as num).toDouble(),
//       durationSeconds: json['duration_seconds'],
//     );
//   }
// }
//
// class HistoryItem {
//   final int sessionId;
//   final String exerciseName;
//   final int totalReps;
//   final double accuracyPercent;
//   final int durationSeconds;
//   final String startTime;
//   final int correctReps;
//
//   HistoryItem({
//     required this.sessionId,
//     required this.exerciseName,
//     required this.totalReps,
//     required this.accuracyPercent,
//     required this.durationSeconds,
//     required this.startTime,
//     required this.correctReps,
//   });
//
//   factory HistoryItem.fromJson(Map<String, dynamic> json) {
//     return HistoryItem(
//       sessionId: json['session_id'],
//       exerciseName: json['exercise_name'],
//       totalReps: json['total_reps'],
//       accuracyPercent: (json['accuracy_percent'] as num).toDouble(),
//       durationSeconds: json['duration_seconds'],
//       startTime: json['start_time'],
//       correctReps: json['correct_reps'],
//     );
//   }
// }
class SessionSummary {
  final int totalReps;
  final int correctReps;
  final double accuracyPercent;
  final int durationSeconds;

  SessionSummary({
    required this.totalReps,
    required this.correctReps,
    required this.accuracyPercent,
    required this.durationSeconds,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      totalReps: json['total_reps'] ?? 0,
      correctReps: json['correct_reps'] ?? 0,
      accuracyPercent:
      (json['accuracy_percent'] ?? 0.0).toDouble(),
      durationSeconds: json['duration_seconds'] ?? 0,
    );
  }
}

class HistoryItem {
  final int sessionId;
  final String exerciseName;
  final int totalReps;
  final int correctReps;
  final double accuracyPercent;
  final int durationSeconds;
  final String startTime;

  HistoryItem({
    required this.sessionId,
    required this.exerciseName,
    required this.totalReps,
    required this.correctReps,
    required this.accuracyPercent,
    required this.durationSeconds,
    required this.startTime,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      sessionId: json['session_id'] ?? 0,
      exerciseName: json['exercise_name'] ?? '',
      totalReps: json['total_reps'] ?? 0,
      correctReps: json['correct_reps'] ?? 0,
      accuracyPercent:
      (json['accuracy_percent'] ?? 0.0).toDouble(),
      durationSeconds: json['duration_seconds'] ?? 0,
      startTime: json['start_time'] ?? '',
    );
  }
}