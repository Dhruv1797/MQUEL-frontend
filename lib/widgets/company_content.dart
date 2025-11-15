import 'package:a2y_app/controller/company_dasboard_controller.dart';
import 'package:a2y_app/widgets/company_list.dart';
import 'package:a2y_app/widgets/empty_state.dart';
import 'package:a2y_app/widgets/error_state.dart';
import 'package:flutter/material.dart';

class CompanyContent extends StatelessWidget {
  final CompanyDashboardController controller;

  const CompanyContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.isNotEmpty) {
      return ErrorState(
        errorMessage: controller.errorMessage,
        onRetry: controller.loadCompanies,
      );
    }

    if (controller.filteredCompanies.isEmpty) {
      return EmptyState();
    }

    return CompanyList(
      companies: controller.filteredCompanies,
      onMenuAction: (action, company) =>
          controller.handleMenuAction(action, company, context),
    );
  }
}
