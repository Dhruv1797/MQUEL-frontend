class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final bool isReset;
  final String role;
  final String? token;
  final int? tenantId;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    required this.isReset,
    required this.role,
    this.token,
    this.tenantId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] ?? json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      isReset: json['isReset'] ?? false,
      role: json['role'] ?? '',
      token: json['token'],
      tenantId: json['tenantId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'isReset': isReset,
      'role': role,
      'token': token,
      'tenantId': tenantId,
    };
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    bool? isReset,
    String? role,
    String? token,
    int? tenantId,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      isReset: isReset ?? this.isReset,
      role: role ?? this.role,
      token: token ?? this.token,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, email: $email, isReset: $isReset, role: $role, token: $token, tenantId: $tenantId)';
  }
}
