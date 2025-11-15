import 'package:flutter/material.dart';

class CompanyModel {
  final int clientId;
  final String orgName;
  final int? cooldownPeriod1;
  final int? cooldownPeriod2;
  final int? cooldownPeriod3;
  final DateTime? createdOn;

  CompanyModel({
    required this.clientId,
    required this.orgName,
    this.cooldownPeriod1,
    this.cooldownPeriod2,
    this.cooldownPeriod3,
    this.createdOn,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      clientId: json['clientId'] ?? 0,
      orgName: json['orgName'] ?? 'no-data',
      cooldownPeriod1: json['cooldownPeriod1'],
      cooldownPeriod2: json['cooldownPeriod2'],
      cooldownPeriod3: json['cooldownPeriod3'],
      createdOn: json['createdOn'] != null
          ? DateTime.tryParse(json['createdOn'])
          : _generateRandomDate(json['clientId'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'orgName': orgName,
      'cooldownPeriod1': cooldownPeriod1,
      'cooldownPeriod2': cooldownPeriod2,
      'cooldownPeriod3': cooldownPeriod3,
      'createdOn': createdOn?.toIso8601String(),
    };
  }

  static DateTime _generateRandomDate(int clientId) {
    final random = clientId % 365;
    return DateTime.now().subtract(Duration(days: random));
  }

  String get displayOrgName => orgName.isEmpty ? 'no-data' : orgName;
  String get displayCooldownPeriod1 => cooldownPeriod1?.toString() ?? 'no-data';
  String get displayCooldownPeriod2 => cooldownPeriod2?.toString() ?? 'no-data';
  String get displayCooldownPeriod3 => cooldownPeriod3?.toString() ?? 'no-data';
  String get initial => orgName.isNotEmpty ? orgName[0].toUpperCase() : 'N';

  String get displayCreatedOn {
    if (createdOn == null) return 'N/A';
    return '${createdOn!.day.toString().padLeft(2, '0')}-${createdOn!.month.toString().padLeft(2, '0')}-${createdOn!.year}';
  }

  Color get companyColor {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[clientId % colors.length];
  }
}
