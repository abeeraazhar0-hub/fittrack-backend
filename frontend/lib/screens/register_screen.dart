// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';
// import 'main_screen.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//   final _confirmPassCtrl = TextEditingController();
//   bool _loading = false;
//   bool _showPass = false;
//   bool _showConfirmPass = false;
//   String? _error;
//
//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     _confirmPassCtrl.dispose();
//     super.dispose();
//   }
//
//   // Email format validator
//   bool _isValidEmail(String email) {
//     return RegExp(
//         r'^[a-zA-Z0-9._%+-]+@[a-zA-Z][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
//     ).hasMatch(email);
//   }
//   // Password strength validator
//   bool _isStrongPassword(String password) {
//     return password.length >= 8 &&
//         RegExp(r'[A-Z]').hasMatch(password) &&
//         RegExp(r'[0-9]').hasMatch(password);
//   }
//
//   Future<void> _register() async {
//     // Validate form first
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//
//     try {
//       final user = await ApiService.register(
//         _nameCtrl.text.trim(),
//         _emailCtrl.text.trim().toLowerCase(),
//         _passCtrl.text.trim(),
//       );
//       ApiService.setToken(user.token);
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', user.token);
//       await prefs.setInt('user_id', user.userId);
//       await prefs.setString('name', user.name);
//       await prefs.setString('email', _emailCtrl.text.trim().toLowerCase());
//       if (mounted) {
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => MainScreen(userId: user.userId)));
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString().replaceAll('Exception: ', '');
//       });
//     } finally {
//       setState(() => _loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(28),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//                 const Icon(Icons.fitness_center,
//                     size: 48, color: Color(0xFF1D9E75)),
//                 const SizedBox(height: 16),
//                 const Text('Create Account',
//                     style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold)),
//                 const Text(
//                     'Start your AI fitness journey today',
//                     style: TextStyle(color: Colors.grey)),
//                 const SizedBox(height: 32),
//
//                 // Name field
//                 TextFormField(
//                   controller: _nameCtrl,
//                   decoration: _inputDecoration(
//                       'Full Name', Icons.person_outline),
//                   textCapitalization:
//                   TextCapitalization.words,
//                   validator: (val) {
//                     if (val == null || val.trim().isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     if (val.trim().length < 2) {
//                       return 'Name must be at least 2 characters';
//                     }
//                     if (!RegExp(r'^[a-zA-Z\s]+$')
//                         .hasMatch(val.trim())) {
//                       return 'Name can only contain letters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Email field
//                 TextFormField(
//                   controller: _emailCtrl,
//                   decoration: _inputDecoration(
//                       'Email Address', Icons.email_outlined),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (val) {
//                     if (val == null || val.trim().isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!_isValidEmail(val.trim())) {
//                       return 'Please enter a valid email address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Password field
//                 TextFormField(
//                   controller: _passCtrl,
//                   obscureText: !_showPass,
//                   decoration: _inputDecoration(
//                       'Password', Icons.lock_outline)
//                       .copyWith(
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _showPass
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: Colors.grey,
//                         size: 20,
//                       ),
//                       onPressed: () =>
//                           setState(() => _showPass = !_showPass),
//                     ),
//                   ),
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please enter a password';
//                     }
//                     if (val.length < 8) {
//                       return 'Password must be at least 8 characters';
//                     }
//                     if (!RegExp(r'[A-Z]').hasMatch(val)) {
//                       return 'Password must contain at least one uppercase letter';
//                     }
//                     if (!RegExp(r'[0-9]').hasMatch(val)) {
//                       return 'Password must contain at least one number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 8),
//
//                 // Password strength indicator
//                 ValueListenableBuilder(
//                   valueListenable: _passCtrl,
//                   builder: (context, value, _) {
//                     final pass = _passCtrl.text;
//                     if (pass.isEmpty) return const SizedBox();
//                     return Column(
//                       crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             _strengthDot(pass.length >= 8),
//                             const SizedBox(width: 4),
//                             _strengthDot(RegExp(r'[A-Z]')
//                                 .hasMatch(pass)),
//                             const SizedBox(width: 4),
//                             _strengthDot(RegExp(r'[0-9]')
//                                 .hasMatch(pass)),
//                             const SizedBox(width: 8),
//                             Text(
//                               _strengthLabel(pass),
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: _strengthColor(pass),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '8+ characters • 1 uppercase • 1 number',
//                           style: TextStyle(
//                               fontSize: 10,
//                               color: Colors.grey[400]),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Confirm password field
//                 TextFormField(
//                   controller: _confirmPassCtrl,
//                   obscureText: !_showConfirmPass,
//                   decoration: _inputDecoration(
//                       'Confirm Password',
//                       Icons.lock_outline)
//                       .copyWith(
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _showConfirmPass
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: Colors.grey,
//                         size: 20,
//                       ),
//                       onPressed: () => setState(() =>
//                       _showConfirmPass = !_showConfirmPass),
//                     ),
//                   ),
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please confirm your password';
//                     }
//                     if (val != _passCtrl.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//
//                 // API error message
//                 if (_error != null) ...[
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                           color: Colors.red.shade200),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.error_outline,
//                             color: Colors.red.shade400,
//                             size: 18),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _error!.contains('already exists')
//                                 ? 'This email is already registered. Please login instead.'
//                                 : _error!,
//                             style: TextStyle(
//                                 color: Colors.red.shade700,
//                                 fontSize: 13),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: _loading ? null : _register,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                       const Color(0xFF1D9E75),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                           borderRadius:
//                           BorderRadius.circular(12)),
//                     ),
//                     child: _loading
//                         ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2),
//                     )
//                         : const Text('Create Account',
//                         style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       'Already have an account? Login',
//                       style: TextStyle(
//                           color: Color(0xFF1D9E75)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Password strength helpers
//   int _strengthScore(String pass) {
//     int score = 0;
//     if (pass.length >= 8) score++;
//     if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
//     if (RegExp(r'[0-9]').hasMatch(pass)) score++;
//     return score;
//   }
//
//   String _strengthLabel(String pass) {
//     final score = _strengthScore(pass);
//     if (score == 1) return 'Weak';
//     if (score == 2) return 'Medium';
//     return 'Strong';
//   }
//
//   Color _strengthColor(String pass) {
//     final score = _strengthScore(pass);
//     if (score == 1) return Colors.red;
//     if (score == 2) return Colors.orange;
//     return Colors.green;
//   }
//
//   Widget _strengthDot(bool met) {
//     return Container(
//       width: 28,
//       height: 4,
//       decoration: BoxDecoration(
//         color: met ? Colors.green : Colors.grey.shade300,
//         borderRadius: BorderRadius.circular(2),
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration(
//       String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon, size: 20),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12)),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//             color: Color(0xFF1D9E75), width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.red.shade400),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.red.shade400),
//       ),
//       filled: true,
//       fillColor: Colors.grey[50],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'profile_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  bool _showConfirmPass = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ApiService.register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim().toLowerCase(),
        _passCtrl.text.trim(),
      );
      ApiService.setToken(user.token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setInt('user_id', user.userId);
      await prefs.setString('name', user.name);
      await prefs.setString(
          'email', _emailCtrl.text.trim().toLowerCase());
      await prefs.setBool('seen_onboarding', true);
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    ProfileSetupScreen(userId: user.userId)));
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.fitness_center,
                    size: 48, color: Color(0xFF1D9E75)),
                const SizedBox(height: 16),
                const Text('Create Account',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const Text(
                    'Start your AI fitness journey today',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),

                // Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration(
                      'Full Name', Icons.person_outline),
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (val.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z\s]+$')
                        .hasMatch(val.trim())) {
                      return 'Name can only contain letters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  decoration: _inputDecoration(
                      'Email Address', Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!_isValidEmail(val.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  decoration:
                  _inputDecoration('Password', Icons.lock_outline)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPass
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showPass = !_showPass),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (val.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(val)) {
                      return 'Must contain at least one uppercase letter';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(val)) {
                      return 'Must contain at least one number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Password strength
                ValueListenableBuilder(
                  valueListenable: _passCtrl,
                  builder: (context, value, _) {
                    final pass = _passCtrl.text;
                    if (pass.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _strengthDot(pass.length >= 8),
                            const SizedBox(width: 4),
                            _strengthDot(RegExp(r'[A-Z]')
                                .hasMatch(pass)),
                            const SizedBox(width: 4),
                            _strengthDot(RegExp(r'[0-9]')
                                .hasMatch(pass)),
                            const SizedBox(width: 8),
                            Text(
                              _strengthLabel(pass),
                              style: TextStyle(
                                fontSize: 11,
                                color: _strengthColor(pass),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '8+ characters • 1 uppercase • 1 number',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400]),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password
                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: !_showConfirmPass,
                  decoration: _inputDecoration(
                      'Confirm Password', Icons.lock_outline)
                      .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPass
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() =>
                      _showConfirmPass = !_showConfirmPass),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (val != _passCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                // Error
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius:
                      BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!.contains('already exists')
                                ? 'This email is already registered. Please login instead.'
                                : _error!,
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF1D9E75),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2))
                        : const Text('Create Account',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account? Login',
                      style:
                      TextStyle(color: Color(0xFF1D9E75)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _strengthScore(String pass) {
    int score = 0;
    if (pass.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass)) score++;
    return score;
  }

  String _strengthLabel(String pass) {
    final score = _strengthScore(pass);
    if (score == 1) return 'Weak';
    if (score == 2) return 'Medium';
    return 'Strong';
  }

  Color _strengthColor(String pass) {
    final score = _strengthScore(pass);
    if (score == 1) return Colors.red;
    if (score == 2) return Colors.orange;
    return Colors.green;
  }

  Widget _strengthDot(bool met) {
    return Container(
      width: 28,
      height: 4,
      decoration: BoxDecoration(
        color: met ? Colors.green : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label, IconData icon) {
    return InputDecoration(
      labelText: label,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}