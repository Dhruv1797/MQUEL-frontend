class NotificationModel {
  final List<int> participantIds;
  final int notificationId;
  final String type;

  NotificationModel({
    required this.participantIds,
    required this.notificationId,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      participantIds: List<int>.from(json['participantIds'] ?? []),
      notificationId: json['notificationId'] ?? 0,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantIds': participantIds,
      'notificationId': notificationId,
      'type': type,
    };
  }

  String get displayMessage {
    switch (type) {
      case 'WEEKLY':
        return 'Less than 7 days remaining for cooldown to complete';
      case 'DAILY':
        return 'Cooldown over';
      default:
        return 'New notification';
    }
  }
}
