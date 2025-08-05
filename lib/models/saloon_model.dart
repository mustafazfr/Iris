import 'package:denemeye_devam/models/service_model.dart'; // <-- ServiceModel'i import etmemiz gerekiyor!
class SaloonModel {
  final String saloonId;
  final String? titlePhotoUrl;
  final String saloonName;
  final String? saloonDescription;
  final String? saloonAddress;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ServiceModel> services;
  final double avgRating;
  final int ratingCount;

  SaloonModel({
    required this.saloonId,
    this.titlePhotoUrl,
    required this.saloonName,
    this.saloonDescription,
    this.saloonAddress,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    required this.createdAt,
    required this.updatedAt,
    this.services = const [],
    this.avgRating = 0.0,
    this.ratingCount = 0,
  });

  factory SaloonModel.fromJson(Map<String, dynamic> json) {
    return SaloonModel(
      saloonId: json['saloon_id'] as String? ?? '', // null gelirse boş string ata
      titlePhotoUrl: json['title_photo_url'] as String?,
      saloonName: json['saloon_name'] as String? ?? 'İsimsiz Salon', // null gelirse varsayılan isim ata
      saloonDescription: json['saloon_description'] as String?,
      saloonAddress: json['saloon_address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      services: json['saloon_services'] != null
          ? (json['saloon_services'] as List)
          .map((saloonServiceJson) {
        if (saloonServiceJson['services'] != null) {
          return ServiceModel.fromJson(saloonServiceJson['services']);
        }
        return null;
      })
          .where((service) => service != null)
          .cast<ServiceModel>()
          .toList()
          : [],
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0, // YENİ
      ratingCount: json['rating_count'] as int? ?? 0, // YENİ
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saloon_id': saloonId,
      'title_photo_url': titlePhotoUrl,
      'saloon_name': saloonName,
      'saloon_description': saloonDescription,
      'saloon_address': saloonAddress,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
