import 'package:a2y_app/constants/global_var.dart';
import 'package:flutter/material.dart';

class CompanyDetails extends StatelessWidget {
  final String displayOrgName;
  final int clientId;

  const CompanyDetails({
    super.key,
    required this.displayOrgName,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayOrgName,
          style: const TextStyle(
            fontFamily: globatInterFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(144, 144, 144, 1),
          ),
        ),
      ],
    );
  }
}
