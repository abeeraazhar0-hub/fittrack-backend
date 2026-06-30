import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'workout_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;
  final int userId;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.userId,
  });

  Map<String, dynamic> get _exerciseInfo {
    switch (exercise.name.toLowerCase().trim()) {
      case 'squat':
        return {
          'emoji': '🏋️',
          'difficulty': 'Beginner',
          'sets': '3 sets • 15 reps',
          'muscles': ['Quadriceps', 'Glutes', 'Hamstrings', 'Core'],
          'steps': [
            'Stand with feet shoulder-width apart, toes slightly outward.',
            'Keep your chest up and back straight throughout the movement.',
            'Lower your body by bending knees — aim for 90 degree angle.',
            'Push through your heels to return to the starting position.',
            'Keep knees aligned with toes, do not let them cave inward.',
          ],
          'tip': 'Keep your weight on your heels, not your toes.',
        };
      case 'push-up':
        return {
          'emoji': '💪',
          'difficulty': 'Intermediate',
          'sets': '3 sets • 12 reps',
          'muscles': ['Chest', 'Triceps', 'Shoulders', 'Core'],
          'steps': [
            'Start in a high plank position, hands slightly wider than shoulders.',
            'Keep your body in a straight line from head to heels.',
            'Lower your chest toward the floor by bending your elbows.',
            'Push through your palms to return to starting position.',
            'Do not let your hips sag or rise during the movement.',
          ],
          'tip': 'Engage your core throughout to protect your lower back.',
        };
      case 'bicep-curl':
        return {
          'emoji': '💪',
          'difficulty': 'Beginner',
          'sets': '3 sets • 12 reps each arm',
          'muscles': ['Biceps', 'Forearms', 'Shoulders'],
          'steps': [
            'Stand straight, hold weights at your sides with palms facing forward.',
            'Keep your elbows close to your torso throughout the movement.',
            'Curl the weight upward by contracting your biceps.',
            'Squeeze at the top — hold for one second.',
            'Slowly lower back to the starting position with control.',
          ],
          'tip': 'Do not swing your body — the movement should come only from your elbow.',
        };
      default:
        return {
          'emoji': '🏃',
          'difficulty': 'Beginner',
          'sets': '3 sets',
          'muscles': ['Full Body'],
          'steps': ['Follow the AI guidance on screen during the workout.'],
          'tip': 'Keep good form throughout.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _exerciseInfo;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1D9E75),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(info['emoji'], style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.category}  •  ${info['difficulty']}  •  ${info['sets']}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Muscles
                  const Text(
                    'Muscles Worked',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (info['muscles'] as List<String>)
                        .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF1D9E75).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1D9E75)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        m,
                        style: const TextStyle(
                          color: Color(0xFF0F6E56),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Steps
                  const Text(
                    'How to Perform',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(info['steps'] as List<String>)
                      .asMap()
                      .entries
                      .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1D9E75),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF444444),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

                  // Tip
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('💡',
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            info['tip'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A5800),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutScreen(
                            exercise: exercise,
                            userId: userId,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9E75),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 24),
                          SizedBox(width: 8),
                          Text('Start Workout',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}