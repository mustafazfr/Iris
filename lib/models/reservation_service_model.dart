class ReservationServiceModel {
  final String id;
  final String reservationId;
  final String serviceId;
  final double servicePriceAtRes;
  final int quantity;

  ReservationServiceModel({
    required this.id,
    required this.reservationId,
    required this.serviceId,
    required this.servicePriceAtRes,
    required this.quantity,
  });

  factory ReservationServiceModel.fromJson(Map<String, dynamic> json) {
    return ReservationServiceModel(
      id: json['id'],
      reservationId: json['reservation_id'],
      serviceId: json['service_id'],
      servicePriceAtRes: (json['service_price_at_res'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'service_id': serviceId,
      'service_price_at_res': servicePriceAtRes,
      'quantity': quantity,
    };
  }
}
