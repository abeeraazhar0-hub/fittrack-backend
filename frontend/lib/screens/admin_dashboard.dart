import 'package:flutter/material.dart';
import 'manage_users_screen.dart';
import 'manage_exercises_screen.dart';
import 'reports_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.admin_panel_settings,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              "Welcome Admin 👋",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Manage your FitTrack BI application",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // ================= Manage Users =================
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.people,
                  color: Colors.green,
                ),
                title: const Text("Manage Users"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageUsersScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ================= Manage Exercises =================
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.fitness_center,
                  color: Colors.green,
                ),
                title: const Text("Manage Exercises"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageExercisesScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ================= View Reports =================
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(
                  Icons.bar_chart,
                  color: Colors.green,
                ),
                title: const Text("View Reports"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportsScreen(),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();

                  await prefs.remove('token');
                  await prefs.remove('user_id');
                  await prefs.remove('name');
                  await prefs.remove('email');
                  await prefs.remove('role');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}