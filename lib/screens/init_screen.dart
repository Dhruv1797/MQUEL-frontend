import 'package:a2y_app/provider/user_provider.dart';
import 'package:a2y_app/screens/company_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../screens/reset_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await userProvider.loadUser();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        debugPrint('InitScreen: JWT token found (length=${token.length}).');
        final payload = _decodeJwtPayload(token);
        if (payload != null) {
          final exp = payload['exp'];
          debugPrint('InitScreen: Decoded JWT exp (Unix seconds) => $exp');
          if (exp is int) {
            final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            final secondsUntilExpiry = exp - nowSeconds;
            debugPrint(
              'InitScreen: now=$nowSeconds, exp=$exp, secondsUntilExpiry=$secondsUntilExpiry',
            );
            if (nowSeconds >= exp) {
              debugPrint(
                'InitScreen: JWT expired. Logging out and clearing token.',
              );
              await userProvider.logout();
            } else {
              debugPrint(
                'InitScreen: JWT valid. Proceeding with app initialization.',
              );
            }
          } else {
            debugPrint(
              'InitScreen: JWT exp not an int. Actual type: ${exp.runtimeType}',
            );
          }
        } else {
          debugPrint('InitScreen: Failed to decode JWT payload.');
        }
      } else {
        debugPrint('InitScreen: No JWT token found in SharedPreferences.');
      }
    } catch (e) {
      debugPrint('JWT decode/expiry check error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 1500));
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded);
      if (map is Map<String, dynamic>) return map;
      return null;
    } catch (_) {
      return null;
    }
  }

  Widget _getDestinationScreen() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print("userProvider.isLoggedIn ${userProvider.isLoggedIn}");
    print("userProvider.needsPasswordReset ${userProvider.needsPasswordReset}");
    if (userProvider.isLoggedIn) {
      print(userProvider.needsPasswordReset);
      if (userProvider.needsPasswordReset) {
        return const ResetPasswordScreen();
      } else {
        return CompanyDashboardScreen();
      }
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/MAQUEL_logo.png',
                    width: 160,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Getting things ready...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _getDestinationScreen();
      },
    );
  }
}
