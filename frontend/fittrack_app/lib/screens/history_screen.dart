import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/session.dart';

class HistoryScreen extends StatefulWidget {
  final int userId;
  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<HistoryItem> _history = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => false; // don't cache — always reload

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  // Called every time this widget is shown
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      // final history = await ApiService.getHistory(widget.userId);
      // if (!mounted) return;
      // setState(() {
      //   _history = history.reversed.toList();
      //   _loading = false;
      // });
      final history = await ApiService.getHistory(widget.userId);
      if (!mounted) return;

// Sort by actual date — newest first, regardless of backend order
      final sorted = List<HistoryItem>.from(history);
      sorted.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.startTime);
          final dateB = DateTime.parse(b.startTime);
          return dateB.compareTo(dateA); // descending = newest first
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        _history = sorted;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('MMM d, yyyy • h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  Color _accuracyColor(double accuracy) {
    if (accuracy >= 80) return const Color(0xFF1D9E75);
    if (accuracy >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Workout History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(
              color: Color(0xFF1D9E75)))
          : _history.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏋️',
                style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('No workouts yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Complete a workout to see it here',
                style: TextStyle(
                    color: Colors.grey[500])),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFF1D9E75),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final item = _history[index];
            final accuracy = (item.accuracyPercent
                .isNaN ||
                item.accuracyPercent.isInfinite)
                ? 0.0
                : item.accuracyPercent
                .clamp(0.0, 100.0);

            return Container(
              margin: const EdgeInsets.only(
                  bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF1D9E75)
                                .withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(
                                10),
                          ),
                          child: Center(
                            child: Text(
                              item.exerciseName ==
                                  'Squat'
                                  ? '🏋️'
                                  : item.exerciseName ==
                                  'Bicep Curl'
                                  ? '💪'
                                  : '🤸',
                              style: const TextStyle(
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                item.exerciseName,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight
                                        .bold),
                              ),
                              Text(
                                _formatDate(
                                    item.startTime),
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets
                              .symmetric(
                              horizontal: 10,
                              vertical: 4),
                          decoration: BoxDecoration(
                            color: _accuracyColor(
                                accuracy)
                                .withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(
                                20),
                          ),
                          child: Text(
                            '${accuracy.toStringAsFixed(0)}%',
                            style: TextStyle(
                                color: _accuracyColor(
                                    accuracy),
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statChip(
                            Icons.repeat_rounded,
                            '${item.totalReps} reps'),
                        const SizedBox(width: 16),
                        _statChip(
                            Icons.check_circle_outline,
                            '${item.correctReps} correct'),
                        const SizedBox(width: 16),
                        _statChip(
                            Icons.timer_outlined,
                            _formatDuration(
                                item.durationSeconds)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}