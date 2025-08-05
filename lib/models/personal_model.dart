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

    // Gelen veri bir liste mi diye kontrol et
    if (specialtyData is List) {
      specialties = List<String>.from(specialtyData.map((x) => x as String));
    }
    // Gelen veri bir string mi diye kontrol et (ve boş değilse)
    else if (specialtyData is String && specialtyData.isNotEmpty) {
      // Tek bir string geldiyse, onu tek elemanlı bir listeye çevir
      specialties = [specialtyData];
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
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
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
