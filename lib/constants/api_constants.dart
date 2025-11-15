import 'package:shared_preferences/shared_preferences.dart';
import 'package:a2y_app/services/auth_guard.dart';

class ApiConstants {
  static const String baseApiPath = '/backend';

  static Future<String?> getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    await AuthGuard.enforceTokenValidity(redirectOnExpire: true);

    final token = await getBearerToken();
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  ApiConstants._();
}
