import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/api_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final _api = ApiService();

  List<WorkoutModel> _workouts = [];
  bool _loading = false;
  String? _error;

  List<WorkoutModel> get workouts => _workouts;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchWorkouts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _workouts = await _api.getWorkouts();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<WorkoutModel?> createWorkout({
    required String type,
    required int durationMinutes,
    required String intensity,
    required DateTime performedAt,
    int? caloriesBurned,
  }) async {
    try {
      final w = await _api.createWorkout(
        type: type,
        durationMinutes: durationMinutes,
        intensity: intensity,
        performedAt: performedAt,
        caloriesBurned: caloriesBurned,
      );
      _workouts.insert(0, w);
      notifyListeners();
      return w;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteWorkout(String id) async {
    try {
      await _api.deleteWorkout(id);
      _workouts.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addExercise(String workoutId, Map<String, dynamic> data) async {
    try {
      final ex = await _api.addExercise(workoutId, data);
      final idx = _workouts.indexWhere((w) => w.id == workoutId);
      if (idx != -1) {
        final w = _workouts[idx];
        _workouts[idx] = WorkoutModel(
          id: w.id,
          userId: w.userId,
          type: w.type,
          durationMinutes: w.durationMinutes,
          intensity: w.intensity,
          caloriesBurned: w.caloriesBurned,
          performedAt: w.performedAt,
          createdAt: w.createdAt,
          exercises: [...w.exercises, ex],
        );
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
