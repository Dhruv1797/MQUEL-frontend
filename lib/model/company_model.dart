class Company {
  final int id;
  final int clientId;
  final String accountName;
  final String aeNam;
  final String? segment;
  final String focusedOrAssigned;
  final String? accountStatus;
  final String? pipelineStatus;
  final String? accountCategory;
  final bool isGoodLead;

  Company({
    required this.id,
    required this.clientId,
    required this.accountName,
    required this.aeNam,
    this.segment,
    required this.focusedOrAssigned,
    this.accountStatus,
    this.pipelineStatus,
    this.accountCategory,
    this.isGoodLead = true,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      clientId: json['clientId'] ?? 0,
      accountName: _parseToString(json['accountName']),
      aeNam: _parseToString(json['aeNam']),
      segment: json['segment'],
      focusedOrAssigned: _parseToString(json['focusedOrAssigned']),
      accountStatus: json['accountStatus'],
      pipelineStatus: json['pipelineStatus'],
      accountCategory: json['accountCategory'],
      isGoodLead: _parseBool(json['isGoodLead']),
    );
  }

  static String _parseToString(dynamic value) {
    if (value == null) return 'No Data';
    if (value is String) return value.isEmpty ? 'No Data' : value;
    return value.toString();
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final v = value.toLowerCase();
      if (v == 'true') return true;
      if (v == 'false') return false;
    }
    if (value is num) return value != 0;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'accountName': accountName,
      'aeNam': aeNam,
      'segment': segment,
      'focusedOrAssigned': focusedOrAssigned,
      'accountStatus': accountStatus,
      'pipelineStatus': pipelineStatus,
      'accountCategory': accountCategory,
      'isGoodLead': isGoodLead,
    };
  }

  Map<String, dynamic> toCompanyTableFormat() {
    return {
      'id': id,
      'clientId': clientId,
      'accountName': accountName,
      'aeNam': aeNam,
      'segment': segment ?? 'No Data',
      'focusedOrAssigned': focusedOrAssigned,
      'accountStatus': accountStatus ?? 'No Data',
      'pipelineStatus': pipelineStatus ?? 'No Data',
      'accountCategory': accountCategory ?? 'No Data',
      'isGoodLead': isGoodLead,
    };
  }
}
