import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme.dart';
import '../models/workout.dart';
import '../models/user.dart';
import '../models/nutrition_log.dart';
import '../models/weight_log.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _base = AppConstants.baseUrl;
  final _storage = const FlutterSecureStorage();

  // ── Token management ──────────────────────────────────────────────────────

  Future<String?> getToken() => _storage.read(key: 'jwt_token');

  Future<void> _saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'jwt_token');

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ── Error handling ────────────────────────────────────────────────────────

  void _checkStatus(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    String msg = 'Request failed (${res.statusCode})';
    try {
      final body = jsonDecode(res.body);
      msg = body['detail'] ?? msg;
    } catch (_) {}
    throw ApiException(res.statusCode, msg);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Registers a new user. Backend: POST /auth/register
  Future<UserModel> register({
    required String email,
    required String password,
    int? heightIn,
    int? weightLbs,
    int? age,
    String? sex,
    String? activityLevel,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        if (heightIn != null) 'height_in': heightIn,
        if (weightLbs != null) 'weight_lbs': weightLbs,
        if (age != null) 'age': age,
        if (sex != null) 'sex': sex,
        if (activityLevel != null) 'activity_level': activityLevel,
      }),
    );
    _checkStatus(res);
    return UserModel.fromJson(jsonDecode(res.body));
  }

  /// Logs in user. Backend uses OAuth2 form format: POST /auth/token
  Future<void> login(String email, String password) async {
    // OAuth2PasswordRequestForm expects application/x-www-form-urlencoded
    final res = await http.post(
      Uri.parse('$_base/auth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    _checkStatus(res);
    final data = jsonDecode(res.body);
    await _saveToken(data['access_token']);
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  /// GET /users/me
  Future<UserModel> getMe() async {
    final res = await http.get(
      Uri.parse('$_base/users/me'),
      headers: await _headers(),
    );
    _checkStatus(res);
    return UserModel.fromJson(jsonDecode(res.body));
  }

  /// PATCH /users/me
  Future<UserModel> updateMe(Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$_base/users/me'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    _checkStatus(res);
    return UserModel.fromJson(jsonDecode(res.body));
  }

  // ── Workouts ──────────────────────────────────────────────────────────────

  /// GET /workouts
  Future<List<WorkoutModel>> getWorkouts() async {
    final res = await http.get(
      Uri.parse('$_base/workouts'),
      headers: await _headers(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List)
        .map((e) => WorkoutModel.fromJson(e))
        .toList();
  }

  /// POST /workouts
  Future<WorkoutModel> createWorkout({
    required String type,
    required int durationMinutes,
    required String intensity,
    required DateTime performedAt,
    int? caloriesBurned,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/workouts'),
      headers: await _headers(),
      body: jsonEncode({
        'type': type,
        'duration_minutes': durationMinutes,
        'intensity': intensity,
        'performed_at': performedAt.toIso8601String(),
        if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      }),
    );
    _checkStatus(res);
    return WorkoutModel.fromJson(jsonDecode(res.body));
  }

  /// DELETE /workouts/{id}
  Future<void> deleteWorkout(String workoutId) async {
    final res = await http.delete(
      Uri.parse('$_base/workouts/$workoutId'),
      headers: await _headers(),
    );
    _checkStatus(res);
  }

  // ── Exercises ─────────────────────────────────────────────────────────────

  /// POST /workouts/{workout_id}/exercises
  Future<ExerciseModel> addExercise(
    String workoutId,
    Map<String, dynamic> data,
  ) async {
    final res = await http.post(
      Uri.parse('$_base/workouts/$workoutId/exercises'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    _checkStatus(res);
    return ExerciseModel.fromJson(jsonDecode(res.body));
  }

  /// DELETE /workouts/{workout_id}/exercises/{exercise_id}
  Future<void> deleteExercise(String workoutId, String exerciseId) async {
    final res = await http.delete(
      Uri.parse('$_base/workouts/$workoutId/exercises/$exerciseId'),
      headers: await _headers(),
    );
    _checkStatus(res);
  }

  // ── Nutrition ─────────────────────────────────────────────────────────────

  /// GET /nutrition
  Future<List<NutritionModel>> getNutritionLogs() async {
    final res = await http.get(
      Uri.parse('$_base/nutrition'),
      headers: await _headers(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List)
        .map((e) => NutritionModel.fromJson(e))
        .toList();
  }

  /// POST /nutrition
  Future<NutritionModel> logNutrition({
    required int calories,
    required DateTime loggedAt,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/nutrition'),
      headers: await _headers(),
      body: jsonEncode({
        'calories': calories,
        'logged_at': loggedAt.toIso8601String(),
        if (proteinG != null) 'protein_g': proteinG,
        if (carbsG != null) 'carbs_g': carbsG,
        if (fatG != null) 'fat_g': fatG,
      }),
    );
    _checkStatus(res);
    return NutritionModel.fromJson(jsonDecode(res.body));
  }

  /// DELETE /nutrition/{id}
  Future<void> deleteNutritionLog(String logId) async {
    final res = await http.delete(
      Uri.parse('$_base/nutrition/$logId'),
      headers: await _headers(),
    );
    _checkStatus(res);
  }

  // ── Weight ────────────────────────────────────────────────────────────────

  /// GET /weight
  Future<List<WeightLogModel>> getWeightLogs() async {
    final res = await http.get(
      Uri.parse('$_base/weight'),
      headers: await _headers(),
    );
    _checkStatus(res);
    return (jsonDecode(res.body) as List)
        .map((e) => WeightLogModel.fromJson(e))
        .toList();
  }

  /// POST /weight
  Future<WeightLogModel> logWeight(double weightLbs, DateTime loggedAt) async {
    final res = await http.post(
      Uri.parse('$_base/weight'),
      headers: await _headers(),
      body: jsonEncode({
        'weight_lbs': weightLbs,
        'logged_at': loggedAt.toIso8601String(),
      }),
    );
    _checkStatus(res);
    return WeightLogModel.fromJson(jsonDecode(res.body));
  }

  /// DELETE /weight/{id}
  Future<void> deleteWeightLog(String logId) async {
    final res = await http.delete(
      Uri.parse('$_base/weight/$logId'),
      headers: await _headers(),
    );
    _checkStatus(res);
  }
}
