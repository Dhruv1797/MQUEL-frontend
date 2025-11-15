import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32, bottom: 32, left: 70),
      decoration: BoxDecoration(
        color: Color.fromRGBO(246, 246, 246, 1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(204, 204, 204, 1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final displayName = userProvider.fullName.isNotEmpty
                        ? userProvider.fullName
                        : userProvider.firstName.isNotEmpty
                        ? userProvider.firstName
                        : 'User';

                    return Text(
                      'Welcome back, $displayName',
                      style: const TextStyle(
                        fontFamily: globatInterFamily,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Discover a powerful platform designed to help you visualize your sheet data\neffortlessly. Manage your clients with ease and gain insights that drive your business\nforward. Let\'s get started!',
                  style: TextStyle(
                    fontFamily: globatInterFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(121, 121, 121, 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 8,
            child: SizedBox(
              height: 200,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset("assets/images/laptop_girl.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
