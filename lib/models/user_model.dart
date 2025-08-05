class UserModel {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String? displayName;
  final String? profilePhotoUrl;
  final String? phoneNumber;
  final String? address;
  final bool verification;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    this.displayName,
    this.profilePhotoUrl,
    this.phoneNumber,
    this.address,
    this.verification = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,
      displayName: json['display_name'],
      profilePhotoUrl: json['profile_photo_url'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      verification: json['verification'] ?? false,
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'display_name': displayName,
      'profile_photo_url': profilePhotoUrl,
      'phone_number': phoneNumber,
      'address': address,
      'verification': verification,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
