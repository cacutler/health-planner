import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get loading => _loading;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Called on app start — checks if a stored token is still valid
  Future<void> tryAutoLogin() async {
    final token = await _api.getToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      _user = await _api.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _api.clearToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.login(email, password);
      _user = await _api.getMe();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      await _api.register(email: email, password: password);
      await _api.login(email, password);
      _user = await _api.getMe();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      _user = await _api.getMe();
      notifyListeners();
    } catch (_) {}
  }
}
