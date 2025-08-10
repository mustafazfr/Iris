// lib/viewmodels/saloon_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reservation_model.dart';
import '../models/saloon_model.dart';
import '../models/salon_category_summary_model.dart';
import '../models/salon_service_model.dart';
import '../repositories/saloon_repository.dart';
import '../repositories/reservation_repository.dart';

class SalonDetailViewModel extends ChangeNotifier {
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);
  final ReservationRepository _reservationRepository = ReservationRepository(Supabase.instance.client);

  // --- EKRAN STATE'LERİ ---
  SaloonModel? salon;
  bool isLoading = true;
  List<SalonCategorySummaryModel> categories = [];
  List<SalonServiceModel> services = [];
  SalonCategorySummaryModel? selectedCategory;
  bool isServiceLoading = false;

  List<String> availableTimeSlots = [];
  bool areTimeSlotsLoading = false;

  // --- SEPET STATE'LERİ (Daha önce State sınıfındaydı, şimdi burada) ---
  final Map<SalonServiceModel, int> _cart = {};
  Map<SalonServiceModel, int> get cart => _cart;

  int get totalCartCount => _cart.values.fold(0, (sum, count) => sum + count);
  double get totalCartPrice {
    if (_cart.isEmpty) return 0.0;
    double total = 0;
    _cart.forEach((service, count) {
      total += service.saloonPrice * count;
    });
    return total;
  }

  // --- RANDEVU TARİH/SAAT STATE'LERİ ---
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;

  // --- METODLAR ---

  Future<void> fetchSalonDetails(String salonId) async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _saloonRepository.getSaloonById(salonId),
        _saloonRepository.fetchSalonCategorySummary(salonId),
      ]);

      salon = results[0] as SaloonModel?;
      categories = results[1] as List<SalonCategorySummaryModel>;

      if (categories.isNotEmpty) {
        await selectCategory(categories.first, initialFetch: true);
      }

      // YENİ EKLENDİ: Ekran ilk açıldığında bugünün saatlerini çek
      if (salon != null) {
        await fetchAvailableTimeSlots(selectedDate);
      }

    } catch (e) {
      debugPrint("fetchSalonDetails Hata: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(SalonCategorySummaryModel category, {bool initialFetch = false}) async {
    if (salon == null || (!initialFetch && selectedCategory == category)) return;

    selectedCategory = category;
    isServiceLoading = true;
    notifyListeners();

    try {
      services = await _saloonRepository.fetchSalonServicesByCategory(
        saloonId: salon!.saloonId,
        categoryId: category.categoryId,
      );
    } catch (e) {
      debugPrint('${category.name} için servisler alınırken hata: $e');
      services = [];
    } finally {
      isServiceLoading = false;
      notifyListeners();
    }
  }

  // --- SEPET METODLARI ---
  void addServiceToCart(SalonServiceModel service) {
    _cart[service] = (_cart[service] ?? 0) + 1;
    notifyListeners();
  }

  void removeServiceFromCart(SalonServiceModel service) {
    if (_cart.containsKey(service)) {
      _cart.remove(service);
      notifyListeners();
    }
  }

  bool isServiceInCart(SalonServiceModel service) {
    return _cart.containsKey(service);
  }

  // --- RANDEVU TARİH/SAAT METODLARI ---
  void selectNewDate(DateTime date) async {
    selectedDate = date;
    selectedTimeSlot = null; // Yeni tarih seçildiğinde saat seçimini sıfırla
    notifyListeners();

    // Yeni tarih için müsait saatleri çek
    await fetchAvailableTimeSlots(date);
  }
  Future<void> fetchAvailableTimeSlots(DateTime date) async {
    if (salon == null) return;

    areTimeSlotsLoading = true;
    notifyListeners();

    try {
      availableTimeSlots = await _saloonRepository.getAvailableTimeSlots(
        saloonId: salon!.saloonId,
        date: date,
      );
    } catch (e) {
      debugPrint("Müsait saatler alınamadı: $e");
      availableTimeSlots = []; // Hata durumunda listeyi boşalt
    } finally {
      areTimeSlotsLoading = false;
      notifyListeners();
    }
  }

  void selectTime(String time) {
    selectedTimeSlot = time;
    notifyListeners();
  }
  Future<bool> createReservation() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (salon == null || userId == null || selectedTimeSlot == null || cart.isEmpty) {
      debugPrint("Randevu için eksik bilgi!");
      return false;
    }

    final serviceIds = cart.keys.map((service) => service.serviceId).toList();
    final servicePrices = cart.keys.map((service) => service.saloonPrice).toList();

    // **** DÜZELTME BURADA ****
    // personalId'yi modelden kaldırdığımız için buradan da kaldırıyoruz.
    final newReservation = ReservationModel(
      userId: userId,
      saloonId: salon!.saloonId,
      reservationDate: selectedDate,
      reservationTime: selectedTimeSlot!,
      totalPrice: totalCartPrice,
      status: ReservationStatus.pending,
    );

    try {
      await _reservationRepository.createReservationWithServices(
          newReservation, serviceIds, servicePrices);

      cart.clear();
      selectedTimeSlot = null;
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint("ViewModel'deki createReservation Hata: $e");
      if (e is PostgrestException) {
        debugPrint("Supabase Hata: ${e.message}");
      }
      return false;
    }
  }
}