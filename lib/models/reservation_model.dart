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

  // TEK HİZMET (geriye dönük uyumluluk için)
  final ServiceModel? service;

  // ÇOKLU HİZMET
  final List<ServiceModel> services;

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
    this.service,           // <— yeniden eklendi
    this.services = const [],
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // Çoklu hizmetleri topla
    final List<ServiceModel> svcList = [];
    final rs = json['reservation_services'];
    if (rs is List) {
      for (final item in rs) {
        final s = item?['services'];
        if (s != null) {
          svcList.add(ServiceModel.fromJson(s));
        }
      }
    }
    // Eski kodlarla uyum için ilkini tekli alana da koy
    final ServiceModel? firstService = svcList.isNotEmpty ? svcList.first : null;

    // ---- STATUS NORMALİZASYONU (return'den ÖNCE) ----
    final rawStatus = (json['status'] as String? ?? 'pending').toLowerCase();
    String normalized = rawStatus == 'canceled' ? 'cancelled' : rawStatus;
    if (normalized == 'no_show') normalized = 'noShow'; // olası farklı yazımlar

    return ReservationModel(
      reservationId: json['reservation_id'] as String?,
      userId: json['user_id'] as String? ?? '',
      saloonId: json['saloon_id'] as String? ?? '',
      personalId: json['personal_id'] as String?,
      reservationDate:
      DateTime.tryParse(json['reservation_date'] ?? '') ?? DateTime.now(),
      reservationTime: json['reservation_time'] as String? ?? '00:00',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: ReservationStatus.values.firstWhere(
            (e) => e.name == normalized,
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      saloon: json['saloons'] != null
          ? SaloonModel.fromJson(json['saloons'])
          : null,
      services: svcList,
      service: firstService,
    );
  }


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
