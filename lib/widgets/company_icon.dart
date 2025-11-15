import 'package:a2y_app/constants/global_var.dart';
import 'package:flutter/material.dart';

class CompanyIcon extends StatelessWidget {
  final String initial;
  final Color color;

  const CompanyIcon({super.key, required this.initial, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: globatInterFamily,
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
