import 'package:a2y_app/widgets/company_content.dart';
import 'package:a2y_app/controller/company_dasboard_controller.dart';
import 'package:flutter/material.dart';

class CompanyListSection extends StatelessWidget {
  final CompanyDashboardController controller;

  const CompanyListSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color.fromRGBO(204, 204, 204, 1),
                    width: 2,
                  ),
                ),
                child: CompanyContent(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
