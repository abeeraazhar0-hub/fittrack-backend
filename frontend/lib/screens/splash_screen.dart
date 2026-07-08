import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding =
        prefs.getBool('seen_onboarding') ?? false;
    final userId = prefs.getInt('user_id');

    // Security: check token expiry
    final isAuth = await ApiService.isAuthenticated();

    if (!mounted) return;

    if (!seenOnboarding) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const OnboardingScreen()));
    } else if (isAuth && userId != null) {
      final token = prefs.getString('token')!;
      ApiService.setToken(token);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => MainScreen(userId: userId)));
    } else {
      // Token expired or not found — go to login
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D9E75),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child:
                Text('💪', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FitTrack BI',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your AI Fitness Coach',
              style:
              TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}