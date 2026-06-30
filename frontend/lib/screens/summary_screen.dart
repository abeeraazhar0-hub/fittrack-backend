import 'package:flutter/material.dart';
import '../models/session.dart';
import 'home_screen.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryScreen extends StatelessWidget {
  final SessionSummary summary;
  final String exerciseName;
  const SummaryScreen(
      {super.key, required this.summary, required this.exerciseName});

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  // Safe formatter — never crashes on NaN or Infinity
  String _safeAccuracy(double val) {
    if (val.isNaN || val.isInfinite) return '100%';
    return '${val.clamp(0.0, 100.0).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.emoji_events,
                  size: 64, color: Color(0xFF1D9E75)),
              const SizedBox(height: 12),
              const Text('Workout Complete!',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              Text(exerciseName,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              Row(
                children: [
                  _statCard('Total Reps',
                      '${summary.totalReps}', Icons.repeat),
                  const SizedBox(width: 12),
                  _statCard('Correct Reps',
                      '${summary.correctReps}',
                      Icons.check_circle_outline),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statCard('Accuracy',
                      _safeAccuracy(summary.accuracyPercent),
                      Icons.track_changes),
                  const SizedBox(width: 12),
                  _statCard('Duration',
                      _formatDuration(summary.durationSeconds),
                      Icons.timer_outlined),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs =
                        await SharedPreferences.getInstance();
                    final userId = prefs.getInt('user_id') ?? 0;
                    if (context.mounted) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  // HomeScreen(userId: userId)));
                              MainScreen(userId: userId)));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D9E75),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1D9E75), size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}