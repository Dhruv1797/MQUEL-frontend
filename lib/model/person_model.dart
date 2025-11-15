class PersonData {
  final String clientId;
  final String id;
  final String sheetName;
  final String name;
  final String designation;
  final String city;
  final String organization;
  final String email;
  final String mobile;
  final String attended;
  final String assignedUnassigned;
  final String eventName;
  final String eventDate;
  final String createdAt;
  final String updatedAt;
  final int orgId;
  final String company; // Added missing field
  final bool isGoodLead; // Added new field
  final bool meetingDone; // Added missing field
  final bool isFocused; // Added missing field
  final int coolDownTime; // Added missing field

  PersonData({
    required this.clientId,
    required this.id,
    required this.sheetName,
    required this.name,
    required this.designation,
    required this.city,
    required this.organization,
    required this.email,
    required this.mobile,
    required this.attended,
    required this.assignedUnassigned,
    required this.eventName,
    required this.eventDate,
    required this.createdAt,
    required this.updatedAt,
    required this.orgId,
    required this.company, // Added missing field
    required this.isGoodLead, // Added new field
    required this.meetingDone, // Added missing field
    required this.isFocused, // Added missing field
    required this.coolDownTime, // Added missing field
  });

  factory PersonData.fromJson(Map<String, dynamic> json) {
    String getValue(dynamic value) {
      if (value == null || (value is String && value.trim().isEmpty)) {
        return 'no-data';
      }
      return value.toString();
    }

    int getIntValue(dynamic value) {
      if (value == null) {
        return 0;
      }
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      if (value is double) {
        return value.toInt();
      }
      return 0;
    }

    bool getBoolValue(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) {
        final v = value.toLowerCase();
        if (v == 'true') return true;
        if (v == 'false') return false;
      }
      if (value is num) return value != 0;
      return false;
    }

    return PersonData(
      clientId: getValue(json['clientId']),
      id: getValue(json['id']),
      sheetName: getValue(json['sheetName']),
      name: getValue(json['name']),
      designation: getValue(json['designation']),
      city: getValue(json['city']),
      organization: getValue(json['organization']),
      email: getValue(json['email']),
      mobile: getValue(json['mobile']),
      attended: getValue(json['attended']),
      assignedUnassigned: getValue(json['assignedUnassigned']),
      eventName: getValue(json['eventName']),
      eventDate: getValue(json['eventDate']),
      createdAt: getValue(json['createdAt']),
      updatedAt: getValue(json['updatedAt']),
      orgId: getIntValue(json['orgId']),
      company: getValue(json['company']), // Added missing field mapping
      isGoodLead: json['isGoodLead'] ?? true, // Added new field mapping
      meetingDone: getBoolValue(
        json['meetingDone'],
      ), // Added missing field mapping
      isFocused: getBoolValue(json['isFocused']), // Added missing field mapping
      coolDownTime: getIntValue(
        json['coolDownTime'],
      ), // Added missing field mapping
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId == 'no-data' ? null : int.tryParse(clientId),
      'id': id == 'no-data' ? null : int.tryParse(id),
      'sheetName': sheetName == 'no-data' ? null : sheetName,
      'name': name == 'no-data' ? null : name,
      'designation': designation == 'no-data' ? null : designation,
      'city': city == 'no-data' ? null : city,
      'organization': organization == 'no-data' ? null : organization,
      'email': email == 'no-data' ? null : email,
      'mobile': mobile == 'no-data' ? null : mobile,
      'attended': attended == 'no-data' ? null : attended,
      'assignedUnassigned': assignedUnassigned == 'no-data'
          ? null
          : assignedUnassigned,
      'eventName': eventName == 'no-data' ? null : eventName,
      'eventDate': eventDate == 'no-data' ? null : eventDate,
      'createdAt': createdAt == 'no-data' ? null : createdAt,
      'updatedAt': updatedAt == 'no-data' ? null : updatedAt,
      'orgId': orgId,
      'company': company == 'no-data'
          ? null
          : company, // Added missing field mapping
      'isGoodLead': isGoodLead, // Added new field mapping
      'meetingDone': meetingDone, // Added missing field mapping
      'isFocused': isFocused, // Added missing field mapping
      'coolDownTime': coolDownTime, // Added missing field mapping
    };
  }
}
