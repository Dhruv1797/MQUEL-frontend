import 'package:a2y_app/constants/api_constants.dart';
import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:a2y_app/screens/init_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print(ApiConstants.baseApiPath);
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),

        home: const InitScreen(),
      ),
    );
  }
}
