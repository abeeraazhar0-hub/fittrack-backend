import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool loading = true;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final result = await ApiService.getAdminSummary();

    setState(() {
      data = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Reports"),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [

              card(
                "Total Users",
                data["total_users"].toString(),
                Icons.people,
              ),

              card(
                "Total Sessions",
                data["total_sessions"].toString(),
                Icons.fitness_center,
              ),

              card(
                "Avg Accuracy",
                "${data["average_accuracy"]}%",
                Icons.track_changes,
              ),

              card(
                "Exercises",
                data["active_exercises"].toString(),
                Icons.sports_gymnastics,
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Weekly Sessions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: 0,

                borderData: FlBorderData(show: false),

                gridData: FlGridData(show: true),

                titlesData: FlTitlesData(

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      getTitlesWidget: (value, meta) {

                        const days = [
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun"
                        ];

                        if (value.toInt() < 0 ||
                            value.toInt() >= days.length) {
                          return const SizedBox();
                        }

                        return Text(days[value.toInt()]);
                      },
                    ),
                  ),
                ),

                lineBarsData: [

                  LineChartBarData(
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,

                    spots: [

                      FlSpot(0,
                          (data["weekly_sessions"]["Mon"] as num).toDouble()),

                      FlSpot(1,
                          (data["weekly_sessions"]["Tue"] as num).toDouble()),

                      FlSpot(2,
                          (data["weekly_sessions"]["Wed"] as num).toDouble()),

                      FlSpot(3,
                          (data["weekly_sessions"]["Thu"] as num).toDouble()),

                      FlSpot(4,
                          (data["weekly_sessions"]["Fri"] as num).toDouble()),

                      FlSpot(5,
                          (data["weekly_sessions"]["Sat"] as num).toDouble()),

                      FlSpot(6,
                          (data["weekly_sessions"]["Sun"] as num).toDouble()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
              const Text(
                "Exercise Distribution",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              buildPieChart(),

              const SizedBox(height: 30),

              const Text(
                "Reps by Exercise",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,

                    borderData: FlBorderData(show: false),

                    gridData: FlGridData(show: true),

                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {

                            final exercises = data["reps_by_exercise"].keys.toList();

                            if (value.toInt() >= exercises.length) {
                              return const SizedBox();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                exercises[value.toInt()],
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    barGroups: List.generate(
                      data["reps_by_exercise"].length,
                          (index) {

                        final values =
                        data["reps_by_exercise"].values.toList();

                        return BarChartGroupData(
                          x: index,
                          barRods: [

                            BarChartRodData(
                              toY: (values[index] as num).toDouble(),
                              color: Colors.green,
                              width: 22,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
    );
  }

  Widget card(
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 40,
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(title),
          ],
        ),
      ),
    );
  }

  Widget buildPieChart() {

    final exerciseData =
    Map<String, dynamic>.from(data["sessions_by_exercise"]);

    final colors = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    int index = 0;

    return Column(
      children: [

        SizedBox(
          height: 230,
          child: PieChart(
            PieChartData(
              sections: exerciseData.entries.map((e) {

                final section = PieChartSectionData(
                  value: (e.value as num).toDouble(),
                  title: e.value.toString(),
                  color: colors[index % colors.length],
                  radius: 70,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );

                index++;

                return section;

              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Wrap(
          spacing: 15,
          runSpacing: 10,
          children: List.generate(
            exerciseData.length,
                (i) {

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Container(
                    width: 14,
                    height: 14,
                    color: colors[i % colors.length],
                  ),

                  const SizedBox(width: 6),

                  Text(
                    exerciseData.keys.elementAt(i),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
