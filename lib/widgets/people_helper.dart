import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:a2y_app/model/person_model.dart';

class PeopleHelper {
  static Map<String, dynamic> mapPersonForTable(PersonData person) {
    final Map<String, dynamic> statusData = _createStatusData(
      person.assignedUnassigned,
    );

    return {
      'clientId': person.clientId != 'no-data' ? person.clientId : 'N/A',
      'id': person.id,
      'sheetName': person.sheetName != 'no-data' ? person.sheetName : 'N/A',
      'name': person.name != 'no-data' ? person.name : 'N/A',
      'designation': person.designation != 'no-data'
          ? person.designation
          : 'N/A',
      'city': person.city != 'no-data' ? person.city : 'N/A',
      'organization': person.organization != 'no-data'
          ? person.organization
          : 'N/A',
      'company': person.company != 'no-data' ? person.company : 'N/A',
      'email': person.email != 'no-data' ? person.email : 'N/A',
      'mobile': person.mobile != 'no-data' ? person.mobile : 'N/A',
      'attended': person.attended != 'no-data' ? person.attended : 'N/A',
      'assignedUnassigned': person.assignedUnassigned != 'no-data'
          ? person.assignedUnassigned
          : 'N/A',
      'eventName': person.eventName != 'no-data' ? person.eventName : 'N/A',
      'eventDate': person.eventDate != 'no-data' ? person.eventDate : 'N/A',
      'createdAt': person.createdAt != 'no-data' ? person.createdAt : 'N/A',
      'updatedAt': person.updatedAt != 'no-data' ? person.updatedAt : 'N/A',
      'orgId': person.orgId,
      'status': statusData,
      'isGoodLead': person.isGoodLead,
    };
  }

  static Map<String, dynamic> _createStatusData(String assignedUnassigned) {
    if (assignedUnassigned == 'Assigned') {
      return {
        'label': 'Assigned',
        'icon': 'assets/images/green_point_days.svg',
      };
    } else if (assignedUnassigned == 'Unassigned') {
      return {
        'label': 'Unassigned',
        'icon': 'assets/images/red_point_days.svg',
      };
    } else {
      return {
        'label': assignedUnassigned != 'no-data'
            ? assignedUnassigned
            : 'Unknown',
        'icon': 'assets/images/light_green_point_days.svg',
      };
    }
  }

  static Widget getCooldownIcon(String color) {
    switch (color) {
      case 'green':
        return SvgPicture.asset("assets/images/green_point_days.svg");
      case 'red':
        return SvgPicture.asset("assets/images/red_point_days.svg");
      case 'light_green':
        return SvgPicture.asset("assets/images/light_green_point_days.svg");
      case 'yellow':
        return SvgPicture.asset("assets/images/green_point_days.svg");
      default:
        return const SizedBox.shrink();
    }
  }

  static void showSuccessSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
