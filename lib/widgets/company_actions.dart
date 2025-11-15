import 'package:a2y_app/model/companyModel.dart';
import 'package:flutter/material.dart';

class CompanyActions extends StatelessWidget {
  final CompanyModel company;
  final Function(String, CompanyModel) onMenuAction;

  const CompanyActions({
    super.key,
    required this.company,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        onMenuAction(value, company);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Edit',
          child: Row(
            children: [
              Icon(Icons.archive, size: 16, color: Colors.grey),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'Delete',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 16, color: Colors.grey),
              SizedBox(width: 12),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }
}
