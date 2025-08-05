// lib/repositories/reservation_repository.dart
import 'package:denemeye_devam/models/reservation_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRepository {
  final SupabaseClient _client;
  ReservationRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> createReservation(ReservationModel reservation) async {
    try {
      // Modeli JSON'a çevirip 'reservations' tablosuna ekliyoruz.
      // reservationId veritabanı tarafından otomatik oluşturulacağı için yollamıyoruz.
      final reservationData = reservation.toJson()..remove('reservation_id');

      await _client.from('reservations').insert(reservationData);

    } catch (e) {
      debugPrint('createReservation Hata: $e');
      throw Exception('Randevu oluşturulurken bir hata oluştu.');
    }
  }
  Future<List<ReservationModel>> getReservationsForUser() async {
    if (_userId == null) return [];

    try {
      // Sorguyu veritabanı şemasına uygun hale getiriyoruz.
      final data = await _client
          .from('reservations')
          .select('*, saloons(saloon_name, title_photo_url), reservation_services(*, services(*))') // DEĞİŞTİ: services -> reservation_services(*, services(*))
          .eq('user_id', _userId!);

      // Gelen veriyi ReservationModel'e çeviriyoruz.
      // Model'i de bu iç içe yapıyı okuyacak şekilde güncellememiz gerekecek.
      return data.map((item) => ReservationModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('getReservationsForUser Hata: $e');
      throw Exception('Randevular getirilirken bir hata oluştu.');
    }
  }

  /// Bir randevunun durumunu günceller (örn: iptal etme).
  Future<void> updateReservationStatus(String reservationId, ReservationStatus status) async {
    try {
      final statusString = status.toString().split('.').last;
      await _client
          .from('reservations')
          .update({'status': statusString})
          .eq('reservation_id', reservationId);
    } catch (e) {
      debugPrint('updateReservationStatus Hata: $e');
      throw Exception('Randevu durumu güncellenirken bir hata oluştu.');
    }
  }
}
