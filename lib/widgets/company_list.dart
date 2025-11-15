import 'package:a2y_app/model/companyModel.dart';
import 'package:a2y_app/widgets/company_item.dart';
import 'package:flutter/material.dart';

class CompanyList extends StatelessWidget {
  final List<CompanyModel> companies;
  final Function(String, CompanyModel) onMenuAction;

  const CompanyList({
    super.key,
    required this.companies,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: companies.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey[200],
        indent: 20,
        endIndent: 20,
      ),
      itemBuilder: (context, index) {
        final company = companies[index];
        return CompanyItem(company: company, onMenuAction: onMenuAction);
      },
    );
  }
}
