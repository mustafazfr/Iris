class PersonalModel {
  final String personalId;
  final String saloonId;
  final String name;
  final String surname;
  final List<String>? specialty;
  final String? profilePhotoUrl;
  final String? phoneNumber;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonalModel({
    required this.personalId,
    required this.saloonId,
    required this.name,
    required this.surname,
    this.specialty,
    this.profilePhotoUrl,
    this.phoneNumber,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersonalModel.fromJson(Map<String, dynamic> json) {
    List<String>? specialties;
    final specialtyData = json['specialty'];

    if (specialtyData is List) {
      specialties = specialtyData.map((x) => x.toString()).toList();
    } else if (specialtyData is String && specialtyData.isNotEmpty) {
      final s = specialtyData.trim();
      if (s.startsWith('{') && s.endsWith('}')) {
        // "{Berber,Kuaför}" -> ["Berber","Kuaför"]
        final inner = s.substring(1, s.length - 1);
        specialties = inner
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else {
        specialties = [s];
      }
    }

    return PersonalModel(
      personalId: json['personal_id'],
      saloonId: json['saloon_id'],
      name: json['name'],
      surname: json['surname'],
      specialty: specialties,
      profilePhotoUrl: json['profile_photo_url'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'personal_id': personalId,
      'saloon_id': saloonId,
      'name': name,
      'surname': surname,
      'specialty': specialty,
      'profile_photo_url': profilePhotoUrl,
      'phone_number': phoneNumber,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
