// lib/viewmodels/appointments_viewmodel.dart

import 'package:denemeye_devam/models/reservation_model.dart';
import 'package:denemeye_devam/repositories/reservation_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/cupertino.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final ReservationRepository _repository = ReservationRepository(Supabase.instance.client);

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

// Yeniden randevu alma işlemi genellikle kullanıcıyı salon detay sayfasına yönlendirir.
// Bu mantık şimdilik UI katmanında kalabilir.
}