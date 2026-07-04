import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final int userId;
  const ProfileSetupScreen({super.key, required this.userId});

  @override
  State<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _saving = false;

  // Selected values
  String? _gender;
  String? _fitnessGoal;
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<Map<String, String>> _goals = [
    {'icon': '💪', 'label': 'Build Muscle'},
    {'icon': '🏃', 'label': 'Lose Weight'},
    {'icon': '🧘', 'label': 'Stay Fit'},
    {'icon': '⚡', 'label': 'Improve Stamina'},
    {'icon': '🏆', 'label': 'Athletic Performance'},
  ];

  Future<void> _saveAndContinue() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(
        userId: widget.userId,
        age: _ageCtrl.text.isNotEmpty
            ? int.tryParse(_ageCtrl.text)
            : null,
        height: _heightCtrl.text.isNotEmpty
            ? double.tryParse(_heightCtrl.text)
            : null,
        weight: _weightCtrl.text.isNotEmpty
            ? double.tryParse(_weightCtrl.text)
            : null,
        gender: _gender,
        fitnessGoal: _fitnessGoal,
      );
    } catch (e) {
      debugPrint('Profile setup error: $e');
    } finally {
      setState(() => _saving = false);
    }

    // Save locally too
    final prefs = await SharedPreferences.getInstance();
    if (_ageCtrl.text.isNotEmpty) {
      await prefs.setInt('age', int.tryParse(_ageCtrl.text) ?? 0);
    }
    if (_heightCtrl.text.isNotEmpty) {
      await prefs.setDouble(
          'height', double.tryParse(_heightCtrl.text) ?? 0);
    }
    if (_weightCtrl.text.isNotEmpty) {
      await prefs.setDouble(
          'weight', double.tryParse(_weightCtrl.text) ?? 0);
    }
    if (_gender != null) await prefs.setString('gender', _gender!);
    if (_fitnessGoal != null) {
      await prefs.setString('fitness_goal', _fitnessGoal!);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => MainScreen(userId: widget.userId)),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveAndContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Setup Profile',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => MainScreen(
                                      userId: widget.userId)),
                            ),
                        child: const Text('Skip',
                            style: TextStyle(
                                color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress dots
                  Row(
                    children: List.generate(
                      3,
                          (i) => Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 3),
                          decoration: BoxDecoration(
                            color: i <= _currentPage
                                ? const Color(0xFF1D9E75)
                                : Colors.grey.shade200,
                            borderRadius:
                            BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                const NeverScrollableScrollPhysics(),
                onPageChanged: (i) =>
                    setState(() => _currentPage = i),
                children: [
                  _page1BasicInfo(),
                  _page2Gender(),
                  _page3Goal(),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF1D9E75),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2))
                      : Text(
                      _currentPage < 2
                          ? 'Continue'
                          : 'Get Started',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📏', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('Basic Information',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const Text(
              'This helps us personalize your experience',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),

          // Age
          _fieldLabel('Age'),
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('e.g. 22', Icons.cake_outlined),
          ),
          const SizedBox(height: 16),

          // Height
          _fieldLabel('Height (cm)'),
          TextField(
            controller: _heightCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('e.g. 165', Icons.height),
          ),
          const SizedBox(height: 16),

          // Weight
          _fieldLabel('Weight (kg)'),
          TextField(
            controller: _weightCtrl,
            keyboardType: TextInputType.number,
            decoration:
            _inputDecoration('e.g. 60', Icons.monitor_weight_outlined),
          ),
        ],
      ),
    );
  }

  Widget _page2Gender() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👤', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('Your Gender',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Select the option that best describes you',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ..._genders.map((g) => GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _gender == g
                    ? const Color(0xFF1D9E75)
                    .withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _gender == g
                      ? const Color(0xFF1D9E75)
                      : Colors.grey.shade300,
                  width: _gender == g ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    g == 'Male'
                        ? '👨'
                        : g == 'Female'
                        ? '👩'
                        : '🧑',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(g,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _gender == g
                              ? const Color(0xFF1D9E75)
                              : Colors.black)),
                  const Spacer(),
                  if (_gender == g)
                    const Icon(Icons.check_circle,
                        color: Color(0xFF1D9E75)),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _page3Goal() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text('Your Fitness Goal',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('What do you want to achieve?',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: _goals
                  .map((g) => GestureDetector(
                onTap: () => setState(
                        () => _fitnessGoal = g['label']),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                      bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _fitnessGoal == g['label']
                        ? const Color(0xFF1D9E75)
                        .withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius:
                    BorderRadius.circular(12),
                    border: Border.all(
                      color:
                      _fitnessGoal == g['label']
                          ? const Color(
                          0xFF1D9E75)
                          : Colors.grey.shade300,
                      width:
                      _fitnessGoal == g['label']
                          ? 2
                          : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(g['icon']!,
                          style: const TextStyle(
                              fontSize: 24)),
                      const SizedBox(width: 16),
                      Text(g['label']!,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w600,
                              color: _fitnessGoal ==
                                  g['label']
                                  ? const Color(
                                  0xFF1D9E75)
                                  : Colors.black)),
                      const Spacer(),
                      if (_fitnessGoal == g['label'])
                        const Icon(
                            Icons.check_circle,
                            color:
                            Color(0xFF1D9E75)),
                    ],
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey)),
    );
  }

  InputDecoration _inputDecoration(
      String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFF1D9E75), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}