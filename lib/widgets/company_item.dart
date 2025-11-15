import 'package:a2y_app/model/companyModel.dart';
import 'package:a2y_app/widgets/company_actions.dart';
import 'package:a2y_app/widgets/company_details.dart';
import 'package:a2y_app/widgets/company_icon.dart';
import 'package:a2y_app/screens/unfied_screen.dart';
import 'package:a2y_app/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CompanyItem extends StatelessWidget {
  final CompanyModel company;
  final Function(String, CompanyModel) onMenuAction;

  const CompanyItem({
    super.key,
    required this.company,
    required this.onMenuAction,
  });

  void _navigateToUnifiedScreen(BuildContext context) {
    goToNextScreenPush(
      context,
      UnifiedScreen(companyData: company, clientId: company.clientId),
    );
  }

  Widget _buildCooldownButton() {
    Map<String, dynamic> cooldownData = _getCooldownData();

    Color bgColor = cooldownData['bgColor'];
    Color textColor = cooldownData['textColor'];
    Color dotColor = cooldownData['dotColor'];
    String label = cooldownData['label'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color.fromRGBO(229, 231, 235, 1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCooldownData() {
    if (company.cooldownPeriod1 == null) {
      return {
        'bgColor': const Color.fromRGBO(243, 244, 246, 1),
        'textColor': const Color.fromRGBO(107, 114, 128, 1),
        'dotColor': const Color.fromRGBO(156, 163, 175, 1),
        'label': 'No Data',
      };
    }

    int cooldownValue = company.cooldownPeriod1!;

    if (cooldownValue <= 5) {
      return {
        'bgColor': const Color.fromRGBO(240, 253, 244, 1),
        'textColor': const Color.fromRGBO(22, 163, 74, 1),
        'dotColor': const Color.fromRGBO(34, 197, 94, 1),
        'label': '${cooldownValue}days',
      };
    } else if (cooldownValue <= 15) {
      return {
        'bgColor': const Color.fromRGBO(254, 252, 232, 1),
        'textColor': const Color.fromRGBO(161, 98, 7, 1),
        'dotColor': const Color.fromRGBO(245, 158, 11, 1),
        'label': '${cooldownValue}days',
      };
    } else {
      return {
        'bgColor': const Color.fromRGBO(254, 242, 242, 1),
        'textColor': const Color.fromRGBO(220, 38, 38, 1),
        'dotColor': const Color.fromRGBO(239, 68, 68, 1),
        'label': '${cooldownValue}days',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToUnifiedScreen(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            CompanyIcon(initial: company.initial, color: company.companyColor),
            const SizedBox(width: 16),
            Expanded(
              child: CompanyDetails(
                displayOrgName: company.displayOrgName,
                clientId: company.clientId,
              ),
            ),
            const SizedBox(width: 16),
            _buildCooldownButton(),
            const SizedBox(width: 16),
            CompanyActions(company: company, onMenuAction: onMenuAction),
          ],
        ),
      ),
    );
  }
}
