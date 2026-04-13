class User {
  final String id; // PK
  final String fName;
  final String lName;
  final String email; // UK
  final bool isVerified;

  User({
    required this.id,
    required this.fName,
    required this.lName,
    required this.email,
    required this.isVerified,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      fName: json['fName'] ?? json['firstName'] ?? '',
      lName: json['lName'] ?? json['lastName'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fName': fName,
      'lName': lName,
      'isVerified': isVerified,
    };
  }

  // Create a copy with modifications
  User copyWith({
    String? id,
    String? email,
    String? fName,
    String? lName,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, fName: $fName, lName: $lName)';
}
