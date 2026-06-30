import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../models/session.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  int _totalWorkouts = 0;
  double _avgAccuracy = 0.0;
  Map<String, dynamic> _repsByExercise = {};
  Map<String, dynamic> _sessionsByExercise = {};
  List<HistoryItem> _history = [];
  String _selectedRange = '7D';
  List<HistoryItem> _filteredHistory = [];

  static const Color primary = Color(0xFF1D9E75);
  static const Color primaryDark = Color(0xFF0F6E56);

  final List<Color> _palette = const [
    Color(0xFF1D9E75),
    Color(0xFF1877C5),
    Color(0xFFE6A800),
    Color(0xFFC2185B),
    Color(0xFF7B61FF),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Future<void> _load() async {
  //   try {
  //     final data = await ApiService.getSummary(widget.userId);
  //     final history = await ApiService.getHistory(widget.userId);
  //     setState(() {
  //       _totalWorkouts = data['total_workouts'] ?? 0;
  //       _avgAccuracy = (data['average_accuracy'] ?? 0.0).toDouble();
  //       _repsByExercise = data['reps_by_exercise'] ?? {};
  //       _sessionsByExercise = data['sessions_by_exercise'] ?? {};
  //       _history = history.reversed.toList();
  //       _loading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = 'Could not load dashboard';
  //       _loading = false;
  //     });
  //   }
  // }
  Future<void> _load() async {
    try {
      final data = await ApiService.getSummary(widget.userId);
      final history = await ApiService.getHistory(widget.userId);
      setState(() {
        _totalWorkouts = data['total_workouts'] ?? 0;
        _avgAccuracy = (data['average_accuracy'] ?? 0.0).toDouble();
        _repsByExercise = data['reps_by_exercise'] ?? {};
        _sessionsByExercise = data['sessions_by_exercise'] ?? {};
        _history = history.reversed.toList();
        _applyRangeFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load dashboard';
        _loading = false;
      });
    }
  }

  void _applyRangeFilter() {
    if (_selectedRange == 'All') {
      _filteredHistory = _history;
      return;
    }
    final days = _selectedRange == '7D' ? 7 : 30;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    _filteredHistory = _history.where((h) {
      try {
        return DateTime.parse(h.startTime).isAfter(cutoff);
      } catch (_) {
        return true;
      }
    }).toList();
    if (_filteredHistory.isEmpty) _filteredHistory = _history.length > 10 ? _history.sublist(_history.length - 10) : _history;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : _error != null
          ? _errorState()
          : RefreshIndicator(
        color: primary,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'My Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, primaryDark],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.fitness_center_rounded,
                            iconColor: primary,
                            iconBg: const Color(0xFFE1F5EE),
                            value: '$_totalWorkouts',
                            label: 'Total Workouts',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            icon: Icons.gps_fixed_rounded,
                            iconColor: const Color(0xFF1877C5),
                            iconBg: const Color(0xFFE8F4FD),
                            value: '${_avgAccuracy.toStringAsFixed(0)}%',
                            label: 'Avg Accuracy',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    _sectionTitle('Reps by Exercise', Icons.bar_chart_rounded),
                    const SizedBox(height: 12),
                    _card(child: _buildBarChart(_repsByExercise)),

                    const SizedBox(height: 28),
                    _sectionTitle('Sessions Distribution', Icons.pie_chart_rounded),
                    const SizedBox(height: 12),
                    _card(child: _buildPieChart(_sessionsByExercise)),

                    // const SizedBox(height: 28),
                    // _sectionTitle('Accuracy Trend', Icons.show_chart_rounded),
                    // const SizedBox(height: 12),
                    // _card(child: _buildLineChart(_history)),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionTitle('Accuracy Trend', Icons.show_chart_rounded),
                        _rangeSelector(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _card(child: _buildLineChart(_filteredHistory)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() => _loading = true);
            _load();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  // ---------- BAR CHART ----------
  Widget _buildBarChart(Map<String, dynamic> data) {
    if (data.isEmpty) return _emptyState();

    final entries = data.entries.toList();
    final maxVal = entries.map((e) => (e.value as num).toDouble()).fold<double>(0, (a, b) => a > b ? a : b);
    final niceMaxY = _niceMaxY(maxVal);

    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          maxY: niceMaxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                rod.toY.toInt().toString(),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: niceMaxY / 4,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      entries[i].key,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: niceMaxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
          ),
          barGroups: List.generate(entries.length, (i) {
            final value = (entries[i].value as num).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: value,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [_palette[i % _palette.length], _palette[i % _palette.length].withOpacity(0.6)],
                  ),
                  width: 24,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: niceMaxY,
                    color: Colors.grey.shade100,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  double _niceMaxY(double maxVal) {
    if (maxVal <= 0) return 10;
    final rounded = ((maxVal / 5).ceil() * 5).toDouble();
    return rounded < maxVal * 1.1 ? rounded + 5 : rounded;
  }
  Widget _rangeSelector() {
    final options = ['7D', '30D', 'All'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isSelected = _selectedRange == opt;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRange = opt;
                _applyRangeFilter();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)]
                    : null,
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primary : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------- PIE CHART ----------
  Widget _buildPieChart(Map<String, dynamic> data) {
    if (data.isEmpty) return _emptyState();

    final entries = data.entries.toList();
    final total = entries.fold<double>(0, (a, e) => a + (e.value as num).toDouble());

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 48,
              sections: List.generate(entries.length, (i) {
                final value = (entries[i].value as num).toDouble();
                final pct = total > 0 ? (value / total * 100) : 0;
                return PieChartSectionData(
                  value: value,
                  title: '${pct.toStringAsFixed(0)}%',
                  color: _palette[i % _palette.length],
                  radius: 55,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  titlePositionPercentageOffset: 0.6,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(entries.length, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: _palette[i % _palette.length], shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(entries[i].key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            );
          }),
        ),
      ],
    );
  }

  // ---------- LINE CHART ----------
  // Widget _buildLineChart(List<HistoryItem> history) {
  //   if (history.isEmpty) return _emptyState();
  //
  //   final spots = List.generate(history.length, (i) => FlSpot(i.toDouble(), history[i].accuracyPercent));
  //
  //   return SizedBox(
  //     height: 220,
  //     child: LineChart(
  //       LineChartData(
  //         minY: 0,
  //         maxY: 100,
  //         gridData: FlGridData(
  //           show: true,
  //           drawVerticalLine: false,
  //           horizontalInterval: 20,
  //           getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
  //         ),
  //         borderData: FlBorderData(show: false),
  //         lineTouchData: LineTouchData(
  //           touchTooltipData: LineTouchTooltipData(
  //             getTooltipColor: (touchedSpot) => Colors.black87,
  //             tooltipRoundedRadius: 8,
  //             getTooltipItems: (spots) => spots.map((s) {
  //               return LineTooltipItem(
  //                 '${s.y.toStringAsFixed(0)}%',
  //                 const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //         titlesData: FlTitlesData(
  //           leftTitles: AxisTitles(
  //             sideTitles: SideTitles(
  //               showTitles: true,
  //               reservedSize: 34,
  //               interval: 20,
  //               getTitlesWidget: (value, meta) => Text(
  //                 '${value.toInt()}%',
  //                 style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
  //               ),
  //             ),
  //           ),
  //           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //           bottomTitles: AxisTitles(
  //             sideTitles: SideTitles(
  //               showTitles: true,
  //               interval: history.length > 5 ? (history.length / 5).ceilToDouble() : 1,
  //               getTitlesWidget: (value, meta) {
  //                 final i = value.toInt();
  //                 if (i < 0 || i >= history.length) return const SizedBox.shrink();
  //                 return Padding(
  //                   padding: const EdgeInsets.only(top: 8),
  //                   child: Text('${i + 1}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //         lineBarsData: [
  //           LineChartBarData(
  //             spots: spots,
  //             isCurved: true,
  //             curveSmoothness: 0.3,
  //             gradient: const LinearGradient(colors: [primary, primaryDark]),
  //             barWidth: 3.5,
  //             dotData: FlDotData(
  //               show: true,
  //               getDotPainter: (spot, percent, bar, index) =>
  //                   FlDotCirclePainter(radius: 4, color: primary, strokeWidth: 2, strokeColor: Colors.white),
  //             ),
  //             belowBarData: BarAreaData(
  //               show: true,
  //               gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [primary.withOpacity(0.18), primary.withOpacity(0.0)],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // ---------- LINE CHART ----------
  Widget _buildLineChart(List<HistoryItem> history) {
    if (history.isEmpty) return _emptyState();

    final spots = List.generate(history.length, (i) => FlSpot(i.toDouble(), history[i].accuracyPercent));
    final avg = history.map((h) => h.accuracyPercent).reduce((a, b) => a + b) / history.length;

    // show at most ~6 x-axis labels regardless of point count
    final labelInterval = (history.length / 6).ceil().clamp(1, history.length).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average: ${avg.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.black87,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (spots) => spots.map((s) {
                    return LineTooltipItem(
                      '${s.y.toStringAsFixed(0)}%',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  }).toList(),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: 25,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}%',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: labelInterval,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= history.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${i + 1}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      );
                    },
                  ),
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: avg,
                    color: Colors.grey.shade400,
                    strokeWidth: 1,
                    dashArray: [6, 4],
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.25,
                  preventCurveOverShooting: true,
                  gradient: const LinearGradient(colors: [primary, primaryDark]),
                  barWidth: 3,
                  dotData: FlDotData(
                    show: history.length <= 15,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(radius: 3.5, color: primary, strokeWidth: 2, strokeColor: Colors.white),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primary.withOpacity(0.16), primary.withOpacity(0.0)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.insert_chart_outlined_rounded, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text('No data yet', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    ),
  );
}