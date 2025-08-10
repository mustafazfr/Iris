// lib/models/reservation_model.dart

import 'saloon_model.dart';
import 'service_model.dart';

enum ReservationStatus { pending, confirmed, completed, cancelled, noShow }

class ReservationModel {
  final String? reservationId;
  final String userId;
  final String saloonId;
  final String? personalId;
  final DateTime reservationDate;
  final String reservationTime;
  final double totalPrice;
  final ReservationStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SaloonModel? saloon;
  final ServiceModel? service;

  ReservationModel({
    this.reservationId,
    required this.userId,
    required this.saloonId,
    this.personalId,
    required this.reservationDate,
    required this.reservationTime,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.saloon,
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
      reservationId: json['reservation_id'] as String?,
      userId: json['user_id'] as String? ?? '',
      saloonId: json['saloon_id'] as String? ?? '',
      personalId: json['personal_id'] as String?,
      reservationDate: DateTime.tryParse(json['reservation_date'] ?? '') ?? DateTime.now(),
      reservationTime: json['reservation_time'] as String? ?? '00:00',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: ReservationStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      saloon: json['saloons'] != null ? SaloonModel.fromJson(json['saloons']) : null,
      service: service,
    );
  }

  // Sadece veritabanı fonksiyonuna (RPC) yollanacak veriyi hazırlar.
  Map<String, dynamic> toRpcJson() {
    return {
      'p_user_id': userId,
      'p_saloon_id': saloonId,
      'p_reservation_date': reservationDate.toIso8601String().split('T')[0],
      'p_reservation_time': reservationTime,
      'p_total_price': totalPrice,
      'p_status': status.name,
    };
  }
}