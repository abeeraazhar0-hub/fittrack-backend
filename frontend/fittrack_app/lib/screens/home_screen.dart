import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/exercise.dart';
import 'exercise_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final Function(int)? onTabChange;
  const HomeScreen({super.key, required this.userId, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Exercise> _exercises = [];
  String _name = '';
  int _totalWorkouts = 0;
  int _totalReps = 0;
  double _avgAccuracy = 0.0;
  bool _loading = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _load();
  // }
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    //setState(() => _name = prefs.getString('name') ?? '');
    final name = prefs.getString('name') ?? '';
    setState(() {
      _name = name.isNotEmpty
      ? '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}'
      : '';
      });
    try {
      final exercises = await ApiService.getExercises();
      final history = await ApiService.getHistory(widget.userId);
      int totalReps = 0;
      double totalAccuracy = 0;
      for (final s in history) {
        totalReps += s.totalReps;
        totalAccuracy += s.accuracyPercent;
      }
      setState(() {
        _exercises = exercises;
        _totalWorkouts = history.length;
        _totalReps = totalReps;
        _avgAccuracy = history.isNotEmpty
            ? totalAccuracy / history.length
            : 0.0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 16,
                  20,
                  24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()} 👋',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _name.isNotEmpty
                                ? _name[0] : 'U',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats row
                  Row(
                    children: [
                      _statPill('$_totalWorkouts', 'Workouts'),
                      const SizedBox(width: 10),
                      _statPill(
                          '${_avgAccuracy.isNaN ? 0 : _avgAccuracy.toStringAsFixed(0)}%',
                          'Accuracy'),
                      const SizedBox(width: 10),
                      _statPill('$_totalReps', 'Total Reps'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Dashboard section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Progress',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _dashCard(
                        icon: Icons.fitness_center,
                        label: 'Workouts',
                        value: '$_totalWorkouts',
                        color: const Color(0xFF1D9E75),
                      ),
                      const SizedBox(width: 12),
                      _dashCard(
                        icon: Icons.repeat_rounded,
                        label: 'Total Reps',
                        value: '$_totalReps',
                        color: const Color(0xFF1877C5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _dashCard(
                        icon: Icons.track_changes_rounded,
                        label: 'Avg Accuracy',
                        value:
                        '${_avgAccuracy.isNaN ? 0 : _avgAccuracy.toStringAsFixed(0)}%',
                        color: const Color(0xFFE6A800),
                      ),
                      const SizedBox(width: 12),
                      _dashCard(
                        icon: Icons.emoji_events_rounded,
                        label: 'Best Exercise',
                        value: _exercises.isNotEmpty
                            ? _exercises[0].name
                            : 'N/A',
                        color: const Color(0xFFC2185B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Exercise list
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: const Text('Choose Exercise',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final ex = _exercises[index];
                final emojis = ['🏋️', '💪🏽', '🤸'];
                final emoji = index < emojis.length
                    ? emojis[index]
                    : '🏃';
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseDetailScreen(
                        exercise: ex,
                        userId: widget.userId,
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(
                        16, 0, 16, 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D9E75)
                                .withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Center(
                              child: Text(emoji,
                                  style: const TextStyle(
                                      fontSize: 22))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(ex.name,
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 3),
                              Text(ex.category,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        if (index == 0)
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D9E75)
                                  .withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: const Text('Popular',
                                style: TextStyle(
                                    color: Color(0xFF0F6E56),
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.bold)),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                );
              },
              childCount: _exercises.length,
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _statPill(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _dashCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}