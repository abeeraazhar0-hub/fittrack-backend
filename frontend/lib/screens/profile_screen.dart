import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/session.dart';
import 'login_screen.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  int _totalWorkouts = 0;
  int _totalReps = 0;
  double _avgAccuracy = 0.0;
  bool _loading = true;
  String _fitnessGoal = '';
  String _gender = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _email = prefs.getString('email') ?? '';
      _fitnessGoal = prefs.getString('fitness_goal') ?? '';
      _gender = prefs.getString('gender') ?? '';
    });
    try {
      final history = await ApiService.getHistory(widget.userId);
      int totalReps = 0;
      double totalAccuracy = 0;
      for (final s in history) {
        totalReps += s.totalReps;
        totalAccuracy += s.accuracyPercent;
      }
      setState(() {
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1D9E75),
            foregroundColor: Colors.white,
            title: const Text('Profile'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1D9E75),
                      Color(0xFF0F6E56)
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                      Colors.white.withOpacity(0.25),
                      child: Text(
                        _name.isNotEmpty
                            ? _name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(_name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(_email,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Stats card
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                    Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      _statItem(
                          '$_totalWorkouts', 'Workouts'),
                      _divider(),
                      _statItem('$_totalReps', 'Total Reps'),
                      _divider(),
                      _statItem(
                          '${_avgAccuracy.toStringAsFixed(0)}%',
                          'Avg Accuracy'),
                    ],
                  ),
                ),

                if (_fitnessGoal.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('🎯',
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fitness Goal',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                            Text(_fitnessGoal,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                // Menu items
                _menuSection('Account', [
                  _menuItem(
                    icon: Icons.person_outline,
                    iconBg: const Color(0xFFE1F5EE),
                    iconColor: const Color(0xFF1D9E75),
                    title: 'Edit Profile',
                    subtitle: 'Update your name and email',
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditProfileScreen(userId: widget.userId)),
                      );
                      if (updated == true) {
                        _load(); // refresh profile screen with new name
                      }
                    },
                  ),
                ]),
                _menuSection('Analytics', [
                  _menuItem(
                    icon: Icons.bar_chart_rounded,
                    iconBg: const Color(0xFFE8F4FD),
                    iconColor: const Color(0xFF1877C5),
                    title: 'My Dashboard',
                    subtitle: 'View Power BI analytics',
                    // onTap: () {},
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                DashboardScreen(userId: widget.userId))),
                  ),
                ]),
                _menuSection('App', [
                  _menuItem(
                    icon: Icons.info_outline,
                    iconBg: const Color(0xFFFFF9E6),
                    iconColor: const Color(0xFFE6A800),
                    title: 'About FitTrack BI',
                    subtitle: 'Team, mission and tech stack',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const AboutScreen())),
                  ),
                  _menuItem(
                    icon: Icons.logout_rounded,
                    iconBg: const Color(0xFFFCE4EC),
                    iconColor: const Color(0xFFC2185B),
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: _logout,
                    showArrow: false,
                  ),
                ]),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D9E75))),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 40, color: Colors.grey.shade200);
  }

  Widget _menuSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(children: items),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right,
                  color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}