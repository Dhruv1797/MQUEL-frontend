import 'package:a2y_app/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  Future<void> setUser(UserModel user) async {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
    await prefs.setBool('is_logged_in', true);

    if (user.token != null) {
      await prefs.setString('auth_token', user.token!);
    }
    if (user.tenantId != null) {
      await prefs.setInt('tenant_id', user.tenantId!);
    }
  }

  Future<void> loadUser() async {
    _isLoading = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (userData != null && isLoggedIn) {
        final userJson = json.decode(userData);
        _user = UserModel.fromJson(userJson);
        _isLoggedIn = true;
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
    await prefs.remove('tenant_id');
    await prefs.setBool('is_logged_in', false);
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _user = updatedUser;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(updatedUser.toJson()));
  }

  bool get needsPasswordReset => _user?.isReset == false;

  String get fullName {
    if (_user == null) return '';
    return '${_user!.firstName} ${_user!.lastName}'.trim();
  }

  String get firstName => _user?.firstName ?? '';

  String get email => _user?.email ?? '';

  String get role => _user?.role ?? '';

  int get userId => _user?.id ?? 0;

  String? get token => _user?.token;

  int? get tenantId => _user?.tenantId;

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<int?> getTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('tenant_id');
  }
}
