// lib/viewmodels/appointments_viewmodel.dart

import 'package:denemeye_devam/models/reservation_model.dart';
import 'package:denemeye_devam/repositories/reservation_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/cupertino.dart';


class AppointmentsViewModel extends ChangeNotifier {
  final ReservationRepository _repository = ReservationRepository(Supabase.instance.client);

  String? _nextSalonName, _nextDateStr, _nextTimeStr;
  int _otherActiveCount = 0;

  String? get nextSalonName => _nextSalonName;
  String? get nextDateStr => _nextDateStr;
  String? get nextTimeStr => _nextTimeStr;
  int get otherActiveCount => _otherActiveCount;
  bool get hasUpcoming => _nextSalonName != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ReservationModel> _allAppointments = [];
  List<ReservationModel> get allAppointments => _allAppointments;

  // ViewModel oluşturulduğunda verileri çek
  AppointmentsViewModel() {
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allAppointments = await _repository.getReservationsForUser();
      // Randevuları tarihe göre sıralayalım (en yeni en üstte)
      _allAppointments.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
    } catch (e) {
      debugPrint('$e');
      // Burada kullanıcıya bir hata mesajı göstermek için bir state tutabilirsiniz
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelAppointment(String reservationId) async {
    try {
      // Repository üzerinden randevu durumunu 'cancelled' olarak güncelle
      await _repository.updateReservationStatus(reservationId, ReservationStatus.cancelled);
      // Listeyi yerel olarak güncellemek yerine, en güncel veriyi çekmek daha güvenilirdir.
      await fetchAppointments();
    } catch (e) {
      debugPrint('$e');
      // Hata durumunda kullanıcıya bilgi ver
      rethrow;
    }
  }
  Future<void> fetchDashboardSummary() async {
    try {
      final nearest = await _repository.getNearestUpcomingApproved();
      final active = await _repository.getActiveCount();

      if (nearest != null) {
        final saloons = nearest['saloons'] as Map<String, dynamic>?;
        _nextSalonName = saloons?['saloon_name'] as String? ?? 'Randevu';

        final d = nearest['reservation_date'] as String;
        final t = (nearest['reservation_time'] as String);
        final hhmm = t.length >= 5 ? t.substring(0, 5) : t;

        _nextDateStr = DateFormat('d MMM yy', 'tr_TR')
            .format(DateTime.parse('$d 00:00:00')); // ör: 31 Tem 25
        _nextTimeStr = hhmm;                        // ör: 09:00
        _otherActiveCount = (active > 0) ? active - 1 : 0;
      } else {
        _nextSalonName = null;
        _nextDateStr = null;
        _nextTimeStr = null;
        _otherActiveCount = 0;
      }
    } catch (e) {
      debugPrint('fetchDashboardSummary err: $e');
      _nextSalonName = null;
      _nextDateStr = null;
      _nextTimeStr = null;
      _otherActiveCount = 0;
    }
    notifyListeners();
  }

// Yeniden randevu alma işlemi genellikle kullanıcıyı salon detay sayfasına yönlendirir.
// Bu mantık şimdilik UI katmanında kalabilir.
}