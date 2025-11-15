import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/screens/init_screen.dart';

class AuthGuard {
  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      return json.decode(payloadString) as Map<String, dynamic>;
    } catch (e, st) {
      debugPrint('[AuthGuard] Failed to decode JWT payload: $e');
      debugPrint('[AuthGuard] Stack: $st');
      return null;
    }
  }

  static bool _isExpired(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) return true;
    final exp = payload['exp'];
    if (exp == null) return true;
    int expSeconds;
    if (exp is int) {
      expSeconds = exp;
    } else if (exp is double) {
      expSeconds = exp.toInt();
    } else if (exp is String) {
      expSeconds = int.tryParse(exp) ?? 0;
    } else {
      return true;
    }

    final nowSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final remaining = expSeconds - nowSeconds;
    debugPrint(
      '[AuthGuard] JWT exp=$expSeconds, now=$nowSeconds, remaining=$remaining s',
    );
    return remaining <= 0;
  }

  static Future<bool> enforceTokenValidity({
    bool redirectOnExpire = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        debugPrint(
          '[AuthGuard] No token present; skipping expiry enforcement.',
        );
        return true;
      }

      if (_isExpired(token)) {
        debugPrint(
          '[AuthGuard] Token expired. Clearing auth state and redirecting.',
        );
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        await prefs.remove('tenant_id');
        await prefs.setBool('is_logged_in', false);

        if (redirectOnExpire) {
          final state = navigatorKey.currentState;
          if (state != null) {
            state.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const InitScreen()),
              (route) => false,
            );
          } else {
            debugPrint(
              '[AuthGuard] navigatorKey has no currentState; cannot navigate.',
            );
          }
        }
        return false;
      }

      return true;
    } catch (e, st) {
      debugPrint('[AuthGuard] Error during expiry enforcement: $e');
      debugPrint('[AuthGuard] Stack: $st');

      return true;
    }
  }
}
