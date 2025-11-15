class InteractionHistory {
  final String participantName;
  final String organization;
  final String designation;
  final String eventName;
  final DateTime eventDate;
  final String description;
  final bool meetingDone;
  final String? createdAt;

  InteractionHistory({
    required this.participantName,
    required this.organization,
    required this.designation,
    required this.eventName,
    required this.eventDate,
    required this.description,
    required this.meetingDone,
    this.createdAt,
  });

  factory InteractionHistory.fromJson(Map<String, dynamic> json) {
    return InteractionHistory(
      participantName: json['participantName'] ?? '',
      organization: json['organization'] ?? '',
      designation: json['designation'] ?? '',
      eventName: json['eventName'] ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'])
          : DateTime.now(),
      description: json['description'] ?? '',
      meetingDone: json['meetingDone'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantName': participantName,
      'organization': organization,
      'designation': designation,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'description': description,
      'meetingDone': meetingDone,
      if (createdAt != null) 'createdAt': createdAt!,
    };
  }

  Map<String, dynamic> toTableFormat() {
    return {
      'participantName': participantName.isNotEmpty
          ? participantName
          : 'No Data',
      'organization': organization.isNotEmpty ? organization : 'No Data',
      'designation': designation.isNotEmpty ? designation : 'No Data',
      'eventName': eventName.isNotEmpty ? eventName : 'No Data',
      'eventDate': eventDate.toString().split(' ')[0],
      'meetingDone': meetingDone,
      'description': description,
      'createdAt': createdAt ?? 'No Data',
      'actions': 'edit_forward',
    };
  }

  InteractionHistory copyWith({
    String? participantName,
    String? organization,
    String? designation,
    String? eventName,
    DateTime? eventDate,
    String? description,
    bool? meetingDone,
    String? createdAt,
  }) {
    return InteractionHistory(
      participantName: participantName ?? this.participantName,
      organization: organization ?? this.organization,
      designation: designation ?? this.designation,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      description: description ?? this.description,
      meetingDone: meetingDone ?? this.meetingDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'InteractionHistory(participantName: $participantName, organization: $organization, designation: $designation, eventName: $eventName, eventDate: $eventDate, description: $description, meetingDone: $meetingDone, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InteractionHistory &&
        other.participantName == participantName &&
        other.organization == organization &&
        other.designation == designation &&
        other.eventName == eventName &&
        other.eventDate == eventDate &&
        other.description == description &&
        other.meetingDone == meetingDone &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return participantName.hashCode ^
        organization.hashCode ^
        designation.hashCode ^
        eventName.hashCode ^
        eventDate.hashCode ^
        description.hashCode ^
        meetingDone.hashCode ^
        createdAt.hashCode;
  }
}
