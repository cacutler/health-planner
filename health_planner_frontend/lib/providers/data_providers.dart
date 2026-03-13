import 'package:flutter/foundation.dart';
import '../models/nutrition_log.dart';
import '../models/weight_log.dart';
import '../services/api_service.dart';

class NutritionProvider extends ChangeNotifier {
  final _api = ApiService();

  List<NutritionModel> _logs = [];
  bool _loading = false;
  String? _error;

  List<NutritionModel> get logs => _logs;
  bool get loading => _loading;
  String? get error => _error;

  int get todayCalories {
    final today = DateTime.now();
    return _logs
        .where(
          (l) =>
              l.loggedAt.year == today.year &&
              l.loggedAt.month == today.month &&
              l.loggedAt.day == today.day,
        )
        .fold(0, (sum, l) => sum + l.calories);
  }

  Future<void> fetchLogs() async {
    _loading = true;
    notifyListeners();
    try {
      _logs = await _api.getNutritionLogs();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> logNutrition({
    required int calories,
    required DateTime loggedAt,
    double? proteinG,
    double? carbsG,
    double? fatG,
  }) async {
    try {
      final entry = await _api.logNutrition(
        calories: calories,
        loggedAt: loggedAt,
        proteinG: proteinG,
        carbsG: carbsG,
        fatG: fatG,
      );
      _logs.insert(0, entry);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLog(String id) async {
    try {
      await _api.deleteNutritionLog(id);
      _logs.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}

class WeightProvider extends ChangeNotifier {
  final _api = ApiService();

  List<WeightLogModel> _logs = [];
  bool _loading = false;
  String? _error;

  List<WeightLogModel> get logs => _logs;
  bool get loading => _loading;
  String? get error => _error;

  WeightLogModel? get latest => _logs.isNotEmpty ? _logs.first : null;

  Future<void> fetchLogs() async {
    _loading = true;
    notifyListeners();
    try {
      _logs = await _api.getWeightLogs();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> logWeight(double weightLbs, DateTime loggedAt) async {
    try {
      final entry = await _api.logWeight(weightLbs, loggedAt);
      _logs.insert(0, entry);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLog(String id) async {
    try {
      await _api.deleteWeightLog(id);
      _logs.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
