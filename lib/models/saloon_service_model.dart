class SaloonServiceModel {
  final String id;
  final String saloonId;
  final String serviceId;
  final double price;
  final bool isActive;

  SaloonServiceModel({
    required this.id,
    required this.saloonId,
    required this.serviceId,
    required this.price,
    required this.isActive,
  });

  factory SaloonServiceModel.fromJson(Map<String, dynamic> json) {
    return SaloonServiceModel(
      id: json['id'],
      saloonId: json['saloon_id'],
      serviceId: json['service_id'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saloon_id': saloonId,
      'service_id': serviceId,
      'price': price,
      'is_active': isActive,
    };
  }
}
