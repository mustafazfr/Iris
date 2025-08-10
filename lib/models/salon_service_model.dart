// lib/models/salon_service_model.dart

// Bu model, bir salonun bir kategori altındaki hizmetinin detayını tutar.
// (v_saloon_services_by_category VIEW'ından gelir)
class SalonServiceModel {
  final String serviceId;
  final String serviceName;
  final String? description;
  final String estimatedTime; // PG interval -> String
  final double saloonPrice;

  SalonServiceModel({
    required this.serviceId,
    required this.serviceName,
    this.description,
    required this.estimatedTime,
    required this.saloonPrice,
  });

  factory SalonServiceModel.fromJson(Map<String, dynamic> json) {
    // "00:30:00" gibi bir string'i "30 Dak" formatına çevirelim.
    String formatInterval(String? interval) {
      if (interval == null) return 'N/A';
      final parts = interval.split(':');
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final totalMinutes = (hours * 60) + minutes;
      return '$totalMinutes Dak';
    }

    return SalonServiceModel(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      description: json['description'],
      estimatedTime: formatInterval(json['estimated_time']),
      // COALESCE(ss.price, s.base_price) sonucu saloon_price olarak gelir.
      saloonPrice: (json['saloon_price'] as num? ?? 0.0).toDouble(),
    );
  }
}