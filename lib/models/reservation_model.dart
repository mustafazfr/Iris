
import 'saloon_model.dart';
import 'service_model.dart';

enum ReservationStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow
}

class ReservationModel {
  final String reservationId;
  final String userId;
  final String saloonId;
  final DateTime reservationDate;     // sadece tarih
  final String reservationTime;       // saat kısmı, HH:mm:ss string olarak alınır
  final double totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SaloonModel? saloon;
  final ServiceModel? service;

  ReservationModel({
    required this.reservationId,
    required this.userId,
    required this.saloonId,
    required this.reservationDate,
    required this.reservationTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.saloon, // Constructor'a eklendi
    this.service,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    ServiceModel? service;
    if (json['reservation_services'] != null && (json['reservation_services'] as List).isNotEmpty) {
      final serviceData = json['reservation_services'][0]['services'];
      if (serviceData != null) {
        service = ServiceModel.fromJson(serviceData);
      }
    }

    return ReservationModel(
      // --- NULL KONTROLLERİ EKLENDİ ---
      reservationId: json['reservation_id'] as String? ?? '', // null ise boş string ata
      userId: json['user_id'] as String? ?? '',
      saloonId: json['saloon_id'] as String? ?? '',
      reservationDate: DateTime.tryParse(json['reservation_date'] ?? '') ?? DateTime.now(),
      reservationTime: json['reservation_time'] as String? ?? '00:00',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: ReservationStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      saloon: json['saloons'] != null
          ? SaloonModel.fromJson(json['saloons'])
          : null,
      service: service,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_id': reservationId,
      'user_id': userId,
      'saloon_id': saloonId,
      'reservation_date': reservationDate.toIso8601String().split('T')[0], // sadece tarih
      'reservation_time': reservationTime, // genelde string tutulur (örn: "14:30:00")
      'total_price': totalPrice,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
