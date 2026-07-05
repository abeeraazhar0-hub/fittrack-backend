// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   bool _loading = true;
//   bool _saving = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentInfo();
//   }
//
//   Future<void> _loadCurrentInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     _nameCtrl.text = prefs.getString('name') ?? '';
//     _emailCtrl.text = prefs.getString('email') ?? '';
//     setState(() => _loading = false);
//   }
//
//   Future<void> _saveChanges() async {
//     if (_nameCtrl.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Name cannot be empty')),
//       );
//       return;
//     }
//
//     setState(() => _saving = true);
//
//     // Currently saves locally only — backend update endpoint
//     // would be needed for full persistence across devices
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('name', _nameCtrl.text.trim());
//
//     setState(() => _saving = false);
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Profile updated successfully'),
//           backgroundColor: Color(0xFF1D9E75),
//         ),
//       );
//       Navigator.pop(context, true); // return true to refresh profile screen
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         backgroundColor: const Color(0xFF1D9E75),
//         foregroundColor: Colors.white,
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             Center(
//               child: CircleAvatar(
//                 radius: 40,
//                 backgroundColor:
//                 const Color(0xFF1D9E75).withOpacity(0.15),
//                 child: Text(
//                   _nameCtrl.text.isNotEmpty
//                       ? _nameCtrl.text[0].toUpperCase()
//                       : 'U',
//                   style: const TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1D9E75)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             const Text('Full Name',
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey)),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _nameCtrl,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.person_outline),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text('Email Address',
//                 style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey)),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _emailCtrl,
//               enabled: false, // email can't be changed for now
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.email_outlined),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'Email cannot be changed for security reasons',
//               style: TextStyle(
//                   fontSize: 11, color: Colors.grey[500]),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: _saving ? null : _saveChanges,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1D9E75),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//                 child: _saving
//                     ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2))
//                     : const Text('Save Changes',
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold)),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  const EditProfileScreen({super.key, required this.userId});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _gender;
  String? _fitnessGoal;
  bool _loading = true;
  bool _saving = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _goals = [
    'Build Muscle',
    'Lose Weight',
    'Stay Fit',
    'Improve Stamina',
    'Athletic Performance',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _nameCtrl.text = prefs.getString('name') ?? '';
    _ageCtrl.text =
    (prefs.getInt('age') ?? '').toString() == '0'
        ? ''
        : (prefs.getInt('age') ?? '').toString();
    _heightCtrl.text =
    (prefs.getDouble('height') ?? 0) == 0
        ? ''
        : (prefs.getDouble('height') ?? 0).toString();
    _weightCtrl.text =
    (prefs.getDouble('weight') ?? 0) == 0
        ? ''
        : (prefs.getDouble('weight') ?? 0).toString();
    _gender = prefs.getString('gender');
    _fitnessGoal = prefs.getString('fitness_goal');
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(
        userId: widget.userId,
        name: _nameCtrl.text.trim(),
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameCtrl.text.trim());
      if (_ageCtrl.text.isNotEmpty) {
        await prefs.setInt(
            'age', int.tryParse(_ageCtrl.text) ?? 0);
      }
      if (_heightCtrl.text.isNotEmpty) {
        await prefs.setDouble('height',
            double.tryParse(_heightCtrl.text) ?? 0);
      }
      if (_weightCtrl.text.isNotEmpty) {
        await prefs.setDouble('weight',
            double.tryParse(_weightCtrl.text) ?? 0);
      }
      if (_gender != null) {
        await prefs.setString('gender', _gender!);
      }
      if (_fitnessGoal != null) {
        await prefs.setString('fitness_goal', _fitnessGoal!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Color(0xFF1D9E75),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1D9E75),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(
                    0xFF1D9E75)
                    .withOpacity(0.15),
                child: Text(
                  _nameCtrl.text.isNotEmpty
                      ? _nameCtrl.text[0]
                      .toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D9E75)),
                ),
              ),
            ),
            const SizedBox(height: 28),

            _sectionTitle('Personal Info'),
            const SizedBox(height: 12),

            _fieldLabel('Full Name'),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration(
                  'Your name', Icons.person_outline),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Age'),
                      TextField(
                        controller: _ageCtrl,
                        keyboardType:
                        TextInputType.number,
                        decoration: _inputDecoration(
                            'e.g. 22',
                            Icons.cake_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Height (cm)'),
                      TextField(
                        controller: _heightCtrl,
                        keyboardType:
                        TextInputType.number,
                        decoration: _inputDecoration(
                            'e.g. 165',
                            Icons.height),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _fieldLabel('Weight (kg)'),
            TextField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('e.g. 60',
                  Icons.monitor_weight_outlined),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Gender'),
            const SizedBox(height: 12),
            Row(
              children: _genders
                  .map((g) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                          () => _gender = g),
                  child: Container(
                    margin: const EdgeInsets
                        .symmetric(
                        horizontal: 4),
                    padding:
                    const EdgeInsets.symmetric(
                        vertical: 12),
                    decoration: BoxDecoration(
                      color: _gender == g
                          ? const Color(
                          0xFF1D9E75)
                          .withOpacity(
                          0.1)
                          : Colors
                          .grey.shade50,
                      borderRadius:
                      BorderRadius.circular(
                          10),
                      border: Border.all(
                        color: _gender == g
                            ? const Color(
                            0xFF1D9E75)
                            : Colors
                            .grey.shade300,
                        width:
                        _gender == g
                            ? 2
                            : 1,
                      ),
                    ),
                    child: Text(
                      g,
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                        color: _gender == g
                            ? const Color(
                            0xFF1D9E75)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            _sectionTitle('Fitness Goal'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goals
                  .map((g) => GestureDetector(
                onTap: () => setState(
                        () => _fitnessGoal = g),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8),
                  decoration: BoxDecoration(
                    color: _fitnessGoal == g
                        ? const Color(
                        0xFF1D9E75)
                        .withOpacity(0.1)
                        : Colors.grey.shade50,
                    borderRadius:
                    BorderRadius.circular(
                        20),
                    border: Border.all(
                      color: _fitnessGoal == g
                          ? const Color(
                          0xFF1D9E75)
                          : Colors
                          .grey.shade300,
                      width:
                      _fitnessGoal == g
                          ? 2
                          : 1,
                    ),
                  ),
                  child: Text(
                    g,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                      color: _fitnessGoal == g
                          ? const Color(
                          0xFF1D9E75)
                          : Colors.grey,
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF1D9E75),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2))
                    : const Text('Save Changes',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D9E75)));
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
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
      fillColor: Colors.white,
    );
  }
}