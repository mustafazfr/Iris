class PersonalSaloonServiceModel {
  final String id;
  final String personalId;
  final String saloonId;
  final String serviceId;
  final double price;
  final bool isAvailable;

  PersonalSaloonServiceModel({
    required this.id,
    required this.personalId,
    required this.saloonId,
    required this.serviceId,
    required this.price,
    required this.isAvailable,
  });

  factory PersonalSaloonServiceModel.fromJson(Map<String, dynamic> json) {
    return PersonalSaloonServiceModel(
      id: json['id'],
      personalId: json['personal_id'],
      saloonId: json['saloon_id'],
      serviceId: json['service_id'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isAvailable: json['is_available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personal_id': personalId,
      'saloon_id': saloonId,
      'service_id': serviceId,
      'price': price,
      'is_available': isAvailable,
    };
  }
}
