// lib/repositories/reservation_repository.dart
import 'package:denemeye_devam/models/reservation_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
extension _NowX on DateTime {
  String get d => DateFormat('yyyy-MM-dd').format(this);
  String get hm => DateFormat('HH:mm').format(this);
}

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
  Future<Map<String, dynamic>?> getNearestUpcomingApproved() async {
    if (_userId == null) return null;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final rows = await _client
        .from('reservations')
        .select(
        'reservation_id,reservation_date,reservation_time,status, '
            'saloons(saloon_name)'
    )
        .eq('user_id', _userId!)
        .eq('status', 'approved')
        .gte('reservation_date', today)
        .order('reservation_date', ascending: true)
        .order('reservation_time', ascending: true)
        .limit(5);

    if (rows.isEmpty) return null;

    for (final r in rows) {
      final String d = r['reservation_date'] as String;
      final String t = (r['reservation_time'] as String);
      final String hhmm = t.length >= 5 ? t.substring(0, 5) : t; // "09:00"
      final dt = DateTime.parse('$d $hhmm:00');
      if (dt.isAfter(now)) return Map<String, dynamic>.from(r);
    }
    return null;
  }

  Future<int> getActiveCount() async {
    if (_userId == null) return 0;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final rows = await _client
        .from('reservations')
        .select('reservation_date,reservation_time,status')
        .eq('user_id', _userId!)
    // in_ yerine filter
        .filter('status', 'in', '("approved","pending")')
        .gte('reservation_date', today);

    int c = 0;
    for (final r in rows) {
      final String d = r['reservation_date'] as String;
      final String t = (r['reservation_time'] as String);
      final String hhmm = t.length >= 5 ? t.substring(0, 5) : t;
      final dt = DateTime.parse('$d $hhmm:00');
      if (dt.isAfter(now)) c++;
    }
    return c;
  }
}


