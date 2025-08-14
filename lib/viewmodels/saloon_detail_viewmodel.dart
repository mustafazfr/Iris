// lib/viewmodels/saloon_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/personal_model.dart';
import '../models/reservation_model.dart';
import '../models/saloon_model.dart';
import '../models/salon_category_summary_model.dart';
import '../models/salon_service_model.dart';
import '../repositories/saloon_repository.dart';
import '../repositories/reservation_repository.dart';

// YENİ: çalışma saatleri modeli
import '../models/working_hour_model.dart';

class SalonDetailViewModel extends ChangeNotifier {
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);
  final ReservationRepository _reservationRepository = ReservationRepository(Supabase.instance.client);
  final _sb = Supabase.instance.client;

  // --- EKRAN STATE'LERİ ---
  SaloonModel? salon;
  bool isLoading = true;

  List<String> galleryUrls = [];
  bool isGalleryLoading = false;

  List<PersonalModel> personals = [];
  bool isPersonalsLoading = false;

  List<SalonCategorySummaryModel> categories = [];
  List<SalonServiceModel> services = [];
  SalonCategorySummaryModel? selectedCategory;
  bool isServiceLoading = false;

  // YENİ: Çalışma saatleri
  List<WorkingHourModel> workingHours = [];
  bool isWorkingHoursLoading = false;

  // --- Randevu slotları ---
  List<String> availableTimeSlots = [];
  bool areTimeSlotsLoading = false;

  // --- SEPET STATE'LERİ ---
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

  Future<void> fetchGallery(String saloonId) async {
    try {
      isGalleryLoading = true; notifyListeners();

      // Tablo/kolon adlarını kendi şemanıza göre uyarlayın:
      final res = await _sb
          .from('saloon_gallery')              // örn. tablo adı
          .select('image_url, sort_order')     // örn. kolonlar
          .eq('saloon_id', saloonId)
          .order('sort_order', ascending: true);

      galleryUrls = (res as List)
          .map((e) => (e['image_url'] as String?) ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Galeri alınamadı: $e');
      galleryUrls = [];
    } finally {
      isGalleryLoading = false; notifyListeners();
    }
  }

  Future<void> fetchSalonDetails(String saloonId) async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _saloonRepository.getSaloonById(saloonId),
        _saloonRepository.fetchSalonCategorySummary(saloonId),
      ]);

      salon = results[0] as SaloonModel?;
      categories = results[1] as List<SalonCategorySummaryModel>;

      // personelleri çek
      await fetchPersonals();
      await fetchGallery(saloonId);

      if (categories.isNotEmpty) {
        await selectCategory(categories.first, initialFetch: true);
      }

      // (varsa) çalışma saatleri / slotlar
      await fetchWorkingHours(saloonId);
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
  Future<void> fetchPersonals() async {
    if (salon == null) return;
    try {
      isPersonalsLoading = true; notifyListeners();
      personals = await _saloonRepository.fetchPersonalsBySaloon(salon!.saloonId);
    } catch (e) {
      personals = [];
    } finally {
      isPersonalsLoading = false; notifyListeners();
    }
  }


  // YENİ: Çalışma saatlerini DB'den çek
  Future<void> fetchWorkingHours(String saloonId) async {
    try {
      isWorkingHoursLoading = true;
      notifyListeners();

      final res = await _sb
          .from('saloon_working_hours')
          .select('day_of_week, opening_time, closing_time, is_closed')
          .eq('saloon_id', saloonId)
          .order('day_of_week', ascending: true);

      workingHours = (res as List)
          .map((e) => WorkingHourModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Çalışma saatleri alınamadı: $e');
      workingHours = [];
    } finally {
      isWorkingHoursLoading = false;
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
  Future<void> selectNewDate(DateTime date) async {
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
      final slots = await _saloonRepository.getAvailableTimeSlots(
        saloonId: salon!.saloonId,
        date: date,
      );

      // normalize + sırala (HH:mm:ss string’lerinde sözlük sırası iş görür)
      availableTimeSlots = (slots as List).cast<String>()..sort();

      // *** EN ÖNEMLİ KISIM ***
      if (availableTimeSlots.isNotEmpty &&
          (selectedTimeSlot == null ||
              !availableTimeSlots.contains(selectedTimeSlot))) {
        selectedTimeSlot = availableTimeSlots.first; // en erkeni seç
      }
    } catch (e) {
      debugPrint("Müsait saatler alınamadı: $e");
      availableTimeSlots = [];
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
        newReservation,
        serviceIds,
        servicePrices,
      );

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
