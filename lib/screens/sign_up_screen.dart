import 'dart:convert';
import 'package:a2y_app/constants/api_constants.dart';
import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/screens/login_screen.dart';
import 'package:a2y_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    setState(() => isLoading = true);

    final url = Uri.parse(
      '${ApiConstants.baseApiPath}/api/auth/signup?userName=$name&email=$email&password=$password',
    );

    try {
      final response = await http.post(url, headers: {'accept': '*/*'});

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        goToNextScreen(context, const LoginScreen());
      } else {
        final message =
            json.decode(response.body)['message'] ?? 'Signup failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      fontFamily: globatInterFamily,
                      color: Color.fromRGBO(44, 44, 44, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create new account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      fontFamily: globatInterFamily,
                      color: Color.fromRGBO(97, 96, 96, 1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    style: TextStyle(
                      fontFamily: globatInterFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    controller: nameController,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter full name'
                        : null,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontFamily: globatInterFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(166, 166, 166, 1),
                      ),
                      hintText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    style: TextStyle(
                      fontFamily: globatInterFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    controller: emailController,
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Enter valid email'
                        : null,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontFamily: globatInterFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(166, 166, 166, 1),
                      ),
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    style: TextStyle(
                      fontFamily: globatInterFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) => value != null && value.length < 6
                        ? 'Min 6 characters'
                        : null,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontFamily: globatInterFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(166, 166, 166, 1),
                      ),
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    style: TextStyle(
                      fontFamily: globatInterFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    controller: confirmPasswordController,
                    obscureText: true,
                    validator: (value) => value != passwordController.text
                        ? 'Passwords do not match'
                        : null,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontFamily: globatInterFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(166, 166, 166, 1),
                      ),
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Signup',
                              style: TextStyle(
                                fontFamily: globatInterFamily,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => goToNextScreen(context, const LoginScreen()),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account ?',
                          style: TextStyle(
                            fontFamily: globatInterFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(97, 96, 96, 1),
                          ),
                          children: [
                            TextSpan(
                              text: ' Log in',
                              style: TextStyle(
                                fontFamily: globatInterFamily,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
