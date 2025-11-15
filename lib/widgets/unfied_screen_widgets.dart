import 'dart:developer';

import 'package:a2y_app/provider/user_provider.dart';
import 'package:a2y_app/widgets/cool_down_dialog.dart';
import 'package:a2y_app/widgets/company_delete_dialog.dart';
import 'package:a2y_app/widgets/company_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:a2y_app/constants/global_var.dart';
import 'package:a2y_app/widgets/people_helper.dart';
import 'package:a2y_app/widgets/edit_person_dialog.dart';
import 'package:a2y_app/widgets/delete_dialog.dart';
import 'package:a2y_app/model/person_model.dart';
import 'package:a2y_app/controller/unified_screen_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class UnifiedScreenWidgetBuilders {
  final BuildContext context;
  final UnifiedScreenController controller;

  UnifiedScreenWidgetBuilders({
    required this.context,
    required this.controller,
  });

  Widget buildPeopleStatusCell(dynamic value, bool isHeader) {
    if (isHeader) {
      return const Text(
        'Assigned/Unassigned',
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    if (value == null || value is! Map<String, dynamic>) {
      return const Text('Unknown');
    }

    Map<String, dynamic> statusData = value;
    String label = statusData['label'] ?? 'Unknown';

    Color containerColor;
    Color textColor;

    if (label.toLowerCase().contains('assigned') &&
        !label.toLowerCase().contains('unassigned')) {
      containerColor = const Color.fromRGBO(220, 252, 231, 1);
      textColor = const Color.fromRGBO(22, 163, 74, 1);
    } else if (label.toLowerCase().contains('unassigned')) {
      containerColor = const Color.fromRGBO(254, 226, 226, 1);
      textColor = const Color.fromRGBO(220, 38, 38, 1);
    } else {
      containerColor = const Color.fromRGBO(255, 247, 237, 1);
      textColor = const Color.fromRGBO(194, 120, 3, 1);
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: globatInterFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPeopleActionsCell(bool isHeader, Map<String, dynamic>? rowData) {
    if (isHeader) {
      return const Text(
        'Actions',
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isUserRole = userProvider.role == 'USER';

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildActionButton(
              onPressed: () {
                if (rowData != null) {
                  try {
                    final personIdString = rowData['id'];
                    final personId = int.parse(personIdString.toString());
                    final personName = rowData['name']?.toString() ?? 'Unknown';
                    _showDeletePersonDialog(personId, personName);
                  } catch (e) {
                    print("Error parsing person ID: $e");
                  }
                }
              },
              icon: "assets/images/trash.svg",
              isDisabled: isUserRole,
            ),
            const SizedBox(width: 6),
            _buildActionButton(
              onPressed: () {
                if (rowData != null) {
                  _handleEditPerson(rowData);
                }
              },
              icon: "assets/images/profile_edit.svg",
              isDisabled: isUserRole,
            ),
          ],
        );
      },
    );
  }

  Widget buildGoodLeadCell(bool isHeader, dynamic value) {
    if (isHeader) {
      return const Text(
        'Good Lead',
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    final bool isGood = value is bool
        ? value
        : value.toString().toLowerCase() == 'true';

    if (!isGood) {
      return const Text(
        'No',
        style: TextStyle(fontSize: 13, color: Color.fromRGBO(130, 130, 130, 1)),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade400),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
              const SizedBox(width: 6),
              Text(
                'Good Lead',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildNumberStatusCell(dynamic value, bool isHeader) {
    print("value: $value");
    if (isHeader) {
      return const Text(
        'Latest CoolDown',
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    if (value == null) {
      return const Text('No Data');
    }

    int numberValue;
    if (value is int) {
      numberValue = value;
    } else if (value is String) {
      numberValue = int.tryParse(value) ?? 0;
    } else {
      return const Text('No Data');
    }

    Color bgColor;
    Color textColor;
    Color dotColor;
    String label;

    if (numberValue < 10) {
      bgColor = const Color.fromRGBO(254, 242, 242, 1);
      textColor = const Color.fromRGBO(220, 38, 38, 1);
      dotColor = const Color.fromRGBO(239, 68, 68, 1);
      label = numberValue.toString();
    } else if (numberValue < 50) {
      bgColor = const Color.fromRGBO(254, 252, 232, 1);
      textColor = const Color.fromRGBO(161, 98, 7, 1);
      dotColor = const Color.fromRGBO(245, 158, 11, 1);
      label = numberValue.toString();
    } else {
      bgColor = const Color.fromRGBO(240, 253, 244, 1);
      textColor = const Color.fromRGBO(22, 163, 74, 1);
      dotColor = const Color.fromRGBO(34, 197, 94, 1);
      label = numberValue.toString();
    }

    return Row(
      children: [
        Container(
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
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: globatInterFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCooldownCell(dynamic value, bool isHeader) {
    print("value: $value");
    if (isHeader) {
      return const Text(
        'Latest Cooldown',
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    if (value == null || value is! Map<String, dynamic>) {
      return const Text('No Data');
    }

    Map<String, dynamic> cooldown = value;

    Color bgColor;
    Color textColor;
    Color dotColor;

    switch (cooldown['color']) {
      case 'green':
        bgColor = const Color.fromRGBO(240, 253, 244, 1);
        textColor = const Color.fromRGBO(22, 163, 74, 1);
        dotColor = const Color.fromRGBO(34, 197, 94, 1);
        break;
      case 'red':
        bgColor = const Color.fromRGBO(254, 242, 242, 1);
        textColor = const Color.fromRGBO(220, 38, 38, 1);
        dotColor = const Color.fromRGBO(239, 68, 68, 1);
        break;
      case 'yellow':
        bgColor = const Color.fromRGBO(254, 252, 232, 1);
        textColor = const Color.fromRGBO(161, 98, 7, 1);
        dotColor = const Color.fromRGBO(245, 158, 11, 1);
        break;
      case 'grey':
      default:
        bgColor = const Color.fromRGBO(243, 244, 246, 1);
        textColor = const Color.fromRGBO(107, 114, 128, 1);
        dotColor = const Color.fromRGBO(156, 163, 175, 1);
        break;
    }

    return Row(
      children: [
        Container(
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
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                cooldown['label'] ?? 'No Data',
                style: TextStyle(
                  fontFamily: globatInterFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCompanyActionsCell(bool isHeader, Map<String, dynamic>? rowData) {
    if (isHeader) {
      return const Text(
        'Actions',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: globatInterFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(130, 130, 130, 1),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isUserRole = userProvider.role == 'USER';

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              onPressed: () => _deleteCompany(rowData),
              icon: "assets/images/trash.svg",
              isDisabled: isUserRole,
            ),
            const SizedBox(width: 6),
            _buildActionButton(
              onPressed: () => _editCompany(rowData),
              icon: "assets/images/profile_edit.svg",
              isDisabled: isUserRole,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String icon,
    bool isDisabled = false,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: isDisabled ? null : onPressed,
      icon: SvgPicture.asset(
        icon,
        height: 16,
        width: 16,
        color: isDisabled
            ? Colors.grey.shade400
            : const Color.fromRGBO(107, 114, 128, 1),
      ),
    );
  }

  void _handleEditPerson(Map<String, dynamic> rowData) {
    try {
      final personIdFromRow = rowData['id'];
      PersonData? person = controller.getPersonById(personIdFromRow.toString());

      if (person == null) {
        throw Exception('Person not found with ID: $personIdFromRow');
      }

      EditPersonDialog.show(
        context,
        person: person,
        onEditComplete: () => controller.loadPeople(),
      );
    } catch (e) {
      PeopleHelper.showErrorSnackbar(
        context,
        'Error opening edit dialog: ${e.toString()}',
      );
    }
  }

  void _showDeletePersonDialog(int personId, String personName) {
    DeleteConfirmationDialog.show(
      context,
      personName: personName,
      onConfirm: () => _handleDeletePerson(personId, personName),
    );
  }

  Future<void> _handleDeletePerson(int personId, String personName) async {
    final success = await controller.handleDeletePerson(personId);

    if (context.mounted) {
      if (success) {
        PeopleHelper.showSuccessSnackbar(
          context,
          '$personName deleted successfully',
        );
      } else {
        PeopleHelper.showErrorSnackbar(context, 'Failed to delete person');
      }
    }
  }

  void _deleteCompany(Map<String, dynamic>? rowData) {
    if (rowData != null) {
      final int companyId = rowData['id'];
      final int clientId = rowData['clientId'];
      final String companyName = rowData['name'] ?? 'Unknown Company';
      print("companyId $companyId");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CompanyDeleteDialog(
            companyName: companyName,
            companyId: companyId,
            clientId: clientId,
            controller: controller,
          );
        },
      );
    }
  }

  void _cooldownCompany(Map<String, dynamic>? rowData) {
    if (rowData != null) {
      print('cooldown company: $rowData');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CooldownDialog(rowData: rowData);
        },
      );
    }
  }

  void _editCompany(Map<String, dynamic>? rowData) {
    if (rowData != null) {
      log('Edit company: $rowData');

      EditCompanyDialog.show(
        context,
        company: rowData,
        onEditComplete: () {
          controller.loadData();

          print('Company updated successfully');
        },
      );
    }
  }
}
