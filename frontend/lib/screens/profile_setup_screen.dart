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



  String? _gender;

  String? _fitnessGoal;

  final _ageCtrl = TextEditingController();

  final _heightCtrl = TextEditingController();

  final _weightCtrl = TextEditingController();



  final List<String> _genders = ['Male', 'Female', 'Other'];

  final List<Map<String, String>> _goals = [

    {'icon': '', 'label': 'Build Muscle'},

    {'icon': '', 'label': 'Lose Weight'},

    {'icon': '', 'label': 'Stay Fit'},

    {'icon': '', 'label': 'Improve Stamina'},

    {'icon': '', 'label': 'Athletic Performance'},

  ];



  final List<Map<String, String>> _pageInfo = [

    {

      'emoji': '',

      'title': 'Basic Info',

      'subtitle': 'Help us personalize your experience',

    },

    {

      'emoji': '',

      'title': 'Your Gender',

      'subtitle': 'Select the option that describes you',

    },

    {

      'emoji': '',

      'title': 'Fitness Goal',

      'subtitle': 'What do you want to achieve?',

    },

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



    final prefs = await SharedPreferences.getInstance();

    if (_ageCtrl.text.isNotEmpty) {

      await prefs.setInt(

          'age', int.tryParse(_ageCtrl.text) ?? 0);

    }

    if (_heightCtrl.text.isNotEmpty) {

      await prefs.setDouble(

          'height', double.tryParse(_heightCtrl.text) ?? 0);

    }

    if (_weightCtrl.text.isNotEmpty) {

      await prefs.setDouble(

          'weight', double.tryParse(_weightCtrl.text) ?? 0);

    }

    if (_gender != null) {

      await prefs.setString('gender', _gender!);

    }

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

        duration: const Duration(milliseconds: 400),

        curve: Curves.easeInOut,

      );

    } else {

      _saveAndContinue();

    }

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[50],

      body: Column(

        children: [

      // Hero header with gradient

      Container(

      decoration: const BoxDecoration(

      gradient: LinearGradient(

        begin: Alignment.topLeft,

        end: Alignment.bottomRight,

        colors: [Color(0xFF1D9E75), Color(0xFF0A5C42)],

      ),

    ),

    child: SafeArea(

    bottom: false,

    child: Padding(

    padding: const EdgeInsets.fromLTRB(

    20, 16, 20, 28),

    child: Column(

    children: [

    // Top row

    Row(

    mainAxisAlignment:

    MainAxisAlignment.spaceBetween,

    children: [

    Container(

    padding: const EdgeInsets.symmetric(

    horizontal: 12, vertical: 6),

    decoration: BoxDecoration(

    color: Colors.white.withOpacity(0.2),

    borderRadius:

    BorderRadius.circular(20),

    ),

    child: Text(

    'Step ${_currentPage + 1} of 3',

    style: const TextStyle(

    color: Colors.white,

    fontSize: 12,

    fontWeight: FontWeight.w600),

    ),

    ),

    TextButton(

    onPressed: () =>

    Navigator.pushReplacement(

    context,

    MaterialPageRoute(

    builder: (_) => MainScreen(

    userId: widget.userId)),

    ),

    child: const Text(

    'Skip',

    style: TextStyle(

    color: Colors.white70,

    fontSize: 14),

    ),

    ),

    ],

    ),

    const SizedBox(height: 20),
    // Emoji

    AnimatedSwitcher(

    duration: const Duration(milliseconds: 300),

    child: Text(

    _pageInfo[_currentPage]['emoji']!,

    key: ValueKey(_currentPage),

    style: const TextStyle(fontSize: 52),

    ),

    ),

    const SizedBox(height: 12),



    // Title

    AnimatedSwitcher(

    duration: const Duration(milliseconds: 300),

    child: Text(

    _pageInfo[_currentPage]['title']!,

    key: ValueKey('t$_currentPage'),

    style: const TextStyle(

    fontSize: 22,

    fontWeight: FontWeight.bold,

    color: Colors.white),

    ),

    ),

    const SizedBox(height: 6),



    // Subtitle

    Text(

    _pageInfo[_currentPage]['subtitle']!,

    style: const TextStyle(

    color: Colors.white70, fontSize: 13),

    ),

    const SizedBox(height: 20),



    // Progress bar

    Row(

    children: List.generate(

    3,

    (i) => Expanded(

    child: AnimatedContainer(

    duration:

    const Duration(milliseconds: 300),

    height: 4,

    margin: const EdgeInsets.symmetric(

    horizontal: 3),

    decoration: BoxDecoration(

    color: i <= _currentPage

    ? Colors.white

        : Colors.white

        .withOpacity(0.3),

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

    ),

    ),



    // Page content

    Expanded(

    child: PageView(

    controller: _pageController,

    physics: const NeverScrollableScrollPhysics(),

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

    Container(

    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),

    decoration: BoxDecoration(

    color: Colors.white,

    boxShadow: [

    BoxShadow(

    color: Colors.black.withOpacity(0.06),

    blurRadius: 10,

    offset: const Offset(0, -3),

    )

    ],

    ),

    child: SizedBox(

    width: double.infinity,

    height: 52,

    child: ElevatedButton(

    onPressed: _saving ? null : _nextPage,

    style: ElevatedButton.styleFrom(

    backgroundColor: const Color(0xFF1D9E75),

    foregroundColor: Colors.white,

    elevation: 0,

    shape: RoundedRectangleBorder(

    borderRadius: BorderRadius.circular(14)),

    shadowColor:

    const Color(0xFF1D9E75).withOpacity(0.4),

    ),

    child: _saving

    ? const SizedBox(

    width: 20,

    height: 20,

    child: CircularProgressIndicator(

    color: Colors.white,

    strokeWidth: 2))

        : Row(

    mainAxisAlignment:

    MainAxisAlignment.center,

    children: [

    Text(

    _currentPage < 2

    ? 'Continue'

        : 'Get Started ',

    style: const TextStyle(

    fontSize: 16,

    fontWeight: FontWeight.bold),

    ),

    if (_currentPage < 2) ...[

    const SizedBox(width: 8),

    const Icon(

    Icons.arrow_forward_rounded,

    size: 18),

    ]

    ],

    ),

    ),

    ),

    ),

    ],

    ),

    );

  }



  Widget _page1BasicInfo() {

    return SingleChildScrollView(

      padding: const EdgeInsets.all(20),

      child: Column(

        children: [

          const SizedBox(height: 8),

          _infoCard(

            child: Column(

              children: [

                _fieldRow(

                  label: 'Age',

                  hint: 'e.g. 22',

                  icon: Icons.cake_outlined,

                  controller: _ageCtrl,

                  keyboardType: TextInputType.number,

                ),

                _divider(),

                _fieldRow(

                  label: 'Height (cm)',

                  hint: 'e.g. 165',

                  icon: Icons.height,

                  controller: _heightCtrl,

                  keyboardType: TextInputType.number,

                ),

                _divider(),

                _fieldRow(

                  label: 'Weight (kg)',

                  hint: 'e.g. 60',

                  icon: Icons.monitor_weight_outlined,

                  controller: _weightCtrl,

                  keyboardType: TextInputType.number,

                ),

              ],

            ),

          ),

          const SizedBox(height: 16),

          Container(

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(

              color: const Color(0xFF1D9E75).withOpacity(0.08),

              borderRadius: BorderRadius.circular(12),

              border: Border.all(

                  color:

                  const Color(0xFF1D9E75).withOpacity(0.2)),

            ),

            child: const Row(

              children: [

                Text('', style: TextStyle(fontSize: 16)),

                SizedBox(width: 10),

                Expanded(

                  child: Text(

                    'This info helps us give you better workout recommendations',

                    style: TextStyle(

                        fontSize: 12,

                        color: Color(0xFF0F6E56),

                        height: 1.4),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  Widget _page2Gender() {

    return Padding(

      padding: const EdgeInsets.all(20),

      child: Column(

        children: [

          const SizedBox(height: 8),

          ..._genders.map((g) {

            final isSelected = _gender == g;

            final emoji =

            g == 'Male' ? '' : g == 'Female' ? '' : '';

            return GestureDetector(

              onTap: () => setState(() => _gender = g),

              child: AnimatedContainer(

                duration: const Duration(milliseconds: 200),

                width: double.infinity,

                margin: const EdgeInsets.only(bottom: 12),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(

                  color: isSelected

                      ? const Color(0xFF1D9E75).withOpacity(0.08)

                      : Colors.white,

                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(

                    color: isSelected

                        ? const Color(0xFF1D9E75)

                        : Colors.grey.shade200,

                    width: isSelected ? 2 : 1,

                  ),

                  boxShadow: isSelected

                      ? [

                    BoxShadow(

                      color: const Color(0xFF1D9E75)

                          .withOpacity(0.15),

                      blurRadius: 8,

                      offset: const Offset(0, 3),

                    )

                  ]

                      : [

                    BoxShadow(

                      color: Colors.black.withOpacity(0.04),

                      blurRadius: 6,

                      offset: const Offset(0, 2),

                    )

                  ],

                ),

                child: Row(

                  children: [

                    Container(

                      width: 44,

                      height: 44,

                      decoration: BoxDecoration(

                        color: isSelected

                            ? const Color(0xFF1D9E75)

                            .withOpacity(0.15)

                            : Colors.grey.shade50,

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: Center(

                          child: Text(emoji,

                              style:

                              const TextStyle(fontSize: 22))),

                    ),

                    const SizedBox(width: 16),

                    Text(

                      g,

                      style: TextStyle(

                          fontSize: 16,

                          fontWeight: FontWeight.w700,

                          color: isSelected

                              ? const Color(0xFF1D9E75)

                              : Colors.black87),

                    ),

                    const Spacer(),

                    AnimatedContainer(

                      duration: const Duration(milliseconds: 200),

                      width: 24,

                      height: 24,

                      decoration: BoxDecoration(

                        shape: BoxShape.circle,

                        color: isSelected

                            ? const Color(0xFF1D9E75)

                            : Colors.transparent,

                        border: Border.all(

                          color: isSelected

                              ? const Color(0xFF1D9E75)

                              : Colors.grey.shade300,

                          width: 2,

                        ),

                      ),

                      child: isSelected

                          ? const Icon(Icons.check,

                          color: Colors.white, size: 14)

                          : null,

                    ),

                  ],

                ),

              ),

            );

          }),

        ],

      ),

    );

  }



  Widget _page3Goal() {

    return ListView(

      padding: const EdgeInsets.all(20),

      children: [

        const SizedBox(height: 8),

        ..._goals.map((g) {

          final isSelected = _fitnessGoal == g['label'];

          return GestureDetector(

            onTap: () =>

                setState(() => _fitnessGoal = g['label']),

            child: AnimatedContainer(

              duration: const Duration(milliseconds: 200),

              width: double.infinity,

              margin: const EdgeInsets.only(bottom: 10),

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: isSelected

                    ? const Color(0xFF1D9E75).withOpacity(0.08)

                    : Colors.white,

                borderRadius: BorderRadius.circular(14),

                border: Border.all(

                  color: isSelected

                      ? const Color(0xFF1D9E75)

                      : Colors.grey.shade200,

                  width: isSelected ? 2 : 1,

                ),

                boxShadow: isSelected

                    ? [

                  BoxShadow(

                    color: const Color(0xFF1D9E75)

                        .withOpacity(0.15),

                    blurRadius: 8,

                    offset: const Offset(0, 3),

                  )

                ]

                    : [

                  BoxShadow(

                    color: Colors.black.withOpacity(0.04),

                    blurRadius: 6,

                    offset: const Offset(0, 2),

                  )

                ],

              ),

              child: Row(

                children: [

                  Container(

                    width: 44,

                    height: 44,

                    decoration: BoxDecoration(

                      color: isSelected

                          ? const Color(0xFF1D9E75)

                          .withOpacity(0.15)

                          : Colors.grey.shade50,

                      borderRadius: BorderRadius.circular(12),

                    ),

                    child: Center(

                        child: Text(g['icon']!,

                            style:

                            const TextStyle(fontSize: 22))),

                  ),

                  const SizedBox(width: 14),

                  Text(

                    g['label']!,

                    style: TextStyle(

                        fontSize: 15,

                        fontWeight: FontWeight.w700,

                        color: isSelected

                            ? const Color(0xFF1D9E75)

                            : Colors.black87),

                  ),

                  const Spacer(),

                  AnimatedContainer(

                    duration: const Duration(milliseconds: 200),

                    width: 24,

                    height: 24,

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      color: isSelected

                          ? const Color(0xFF1D9E75)

                          : Colors.transparent,

                      border: Border.all(

                        color: isSelected

                            ? const Color(0xFF1D9E75)

                            : Colors.grey.shade300,

                        width: 2,

                      ),

                    ),

                    child: isSelected

                        ? const Icon(Icons.check,

                        color: Colors.white, size: 14)

                        : null,

                  ),

                ],

              ),

            ),

          );

        }),

      ],

    );

  }



  Widget _infoCard({required Widget child}) {

    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,

            offset: const Offset(0, 3),

          )

        ],

      ),

      child: child,

    );

  }



  Widget _fieldRow({

    required String label,

    required String hint,

    required IconData icon,

    required TextEditingController controller,

    TextInputType keyboardType = TextInputType.text,

  }) {

    return Padding(

      padding: const EdgeInsets.symmetric(

          horizontal: 16, vertical: 14),

      child: Row(

        children: [

          Container(

            width: 36,

            height: 36,

            decoration: BoxDecoration(

              color: const Color(0xFF1D9E75).withOpacity(0.1),

              borderRadius: BorderRadius.circular(9),

            ),

            child: Icon(icon,

                color: const Color(0xFF1D9E75), size: 18),

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(label,

                    style: const TextStyle(

                        fontSize: 11,

                        fontWeight: FontWeight.w700,

                        color: Colors.grey)),

                const SizedBox(height: 4),

                TextField(

                  controller: controller,

                  keyboardType: keyboardType,

                  style: const TextStyle(fontSize: 14),

                  decoration: InputDecoration(

                    hintText: hint,

                    hintStyle: TextStyle(

                        color: Colors.grey[400], fontSize: 13),

                    isDense: true,

                    contentPadding: EdgeInsets.zero,

                    border: InputBorder.none,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  Widget _divider() {

    return Divider(

        height: 1, color: Colors.grey[100], indent: 64);

  }

}