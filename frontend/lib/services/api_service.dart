import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/session.dart';

class ApiService {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(
          utf8.decode(
              base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int;
      return DateTime.now().millisecondsSinceEpoch / 1000 > exp;
    } catch (e) {
      return true;
    }
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;
    if (_isTokenExpired(token)) {
      await prefs.clear();
      return false;
    }
    return true;
  }

  // ── Auth ──
  static Future<User> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${Constants.baseUrl}/auth/register'),
      headers: _headers,
      body: jsonEncode(
          {'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 201) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception(
        jsonDecode(res.body)['detail'] ?? 'Registration failed');
  }

  static Future<User> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${Constants.baseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception(
        jsonDecode(res.body)['detail'] ?? 'Login failed');
  }

  // ── Profile ──
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/auth/profile/$userId'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load profile');
  }

  static Future<void> updateProfile({
    required int userId,
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (age != null) body['age'] = age;
    if (height != null) body['height'] = height;
    if (weight != null) body['weight'] = weight;
    if (gender != null) body['gender'] = gender;

    final res = await http.put(
      Uri.parse('${Constants.baseUrl}/auth/profile/$userId'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  // ── Admin ──
  static Future<List<dynamic>> getAllUsers() async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/admin/users'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to load users');
  }
// ── Admin User Management ──

  static Future<void> addUser({
    required String name,
    required String email,
    required String password,
    String role = "user",
  }) async {
    final res = await http.post(
      Uri.parse('${Constants.baseUrl}/admin/users'),
      headers: _headers,
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception(
        jsonDecode(res.body)['detail'] ?? "Failed to add user",
      );
    }
  }


  static Future<void> updateUser({
    required int userId,
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? fitnessGoal,
    String? role,
  }) async {

    final body = <String, dynamic>{};

    if (name != null) body["name"] = name;
    if (email != null) body["email"] = email;
    if (age != null) body["age"] = age;
    if (height != null) body["height"] = height;
    if (weight != null) body["weight"] = weight;
    if (gender != null) body["gender"] = gender;
    if (fitnessGoal != null) {
      body["fitness_goal"] = fitnessGoal;
    }
    if (role != null) body["role"] = role;


    final res = await http.put(
      Uri.parse(
        '${Constants.baseUrl}/admin/users/$userId',
      ),
      headers: _headers,
      body: jsonEncode(body),
    );


    if (res.statusCode != 200) {
      throw Exception(
        jsonDecode(res.body)['detail'] ?? "Failed to update user",
      );
    }
  }


  static Future<void> deleteUser(int userId) async {

    final res = await http.delete(
      Uri.parse(
        '${Constants.baseUrl}/admin/users/$userId',
      ),
      headers: _headers,
    );


    if (res.statusCode != 200) {
      throw Exception(
        jsonDecode(res.body)['detail'] ?? "Failed to delete user",
      );
    }
  }
  // ── Admin Exercise Management ──

  static Future<List<Exercise>> getAdminExercises() async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/admin/exercises'),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);

      return data
          .map((e) => Exercise.fromJson(e))
          .toList();
    }

    throw Exception("Failed to load admin exercises");
  }


  static Future<void> toggleExercise(int exerciseId) async {
    final res = await http.put(
      Uri.parse(
        '${Constants.baseUrl}/admin/exercises/$exerciseId/toggle',
      ),
      headers: _headers,
    );

    if (res.statusCode != 200) {
      throw Exception(
        jsonDecode(res.body)['detail'] ??
            "Failed to toggle exercise",
      );
    }
  }
  static Future<Map<String, dynamic>> getReports() async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/admin/reports'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to load reports');
  }
  static Future<Map<String, dynamic>> getAdminSummary() async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/sessions/admin-summary'),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load admin summary");
  }
  // ── Exercises ──
  static Future<List<Exercise>> getExercises() async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/exercises/'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Exercise.fromJson(e)).toList();
    }
    throw Exception('Failed to load exercises');
  }

  // ── Sessions ──
  static Future<int> startSession(int userId, int exerciseId) async {
    final res = await http.post(
      Uri.parse('${Constants.baseUrl}/sessions/start'),
      headers: _headers,
      body: jsonEncode(
          {'user_id': userId, 'exercise_id': exerciseId}),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body)['session_id'];
    }
    throw Exception('Failed to start session');
  }

  static Future<SessionSummary> endSession(int sessionId) async {
    final res = await http.post(
      Uri.parse('${Constants.baseUrl}/sessions/end'),
      headers: _headers,
      body: jsonEncode({'session_id': sessionId}),
    );
    if (res.statusCode == 200) {
      return SessionSummary.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to end session');
  }

  static Future<List<HistoryItem>> getHistory(int userId) async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/sessions/history/$userId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => HistoryItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load history');
  }

  static Future<Map<String, dynamic>> getSummary(int userId) async {
    final res = await http.get(
      Uri.parse('${Constants.baseUrl}/sessions/summary/$userId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to load summary');
  }

  // ── AI Analyze ──
  static Future<Map<String, dynamic>> analyzeFrame(
      String frameBase64,
      int exerciseId,
      int sessionId) async {
    final res = await http.post(
      Uri.parse('${Constants.baseUrl}/analyze/'),
      headers: _headers,
      body: jsonEncode({
        'frame_base64': frameBase64,
        'exercise_id': exerciseId,
        'session_id': sessionId,
      }),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {
      'posture_status': 'incorrect',
      'feedback_message': 'No pose detected',
      'rep_count': 0,
      'accuracy_percent': 0.0,
    };
  }
}