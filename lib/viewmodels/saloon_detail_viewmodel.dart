// lib/viewmodels/saloon_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saloon_model.dart';
import '../models/salon_category_summary_model.dart';
import '../models/salon_service_model.dart';
import '../repositories/saloon_repository.dart';

class SalonDetailViewModel extends ChangeNotifier {
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);

  // --- EKRAN STATE'LERİ ---
  SaloonModel? salon;
  bool isLoading = true;
  List<SalonCategorySummaryModel> categories = [];
  List<SalonServiceModel> services = [];
  SalonCategorySummaryModel? selectedCategory;
  bool isServiceLoading = false;

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
  void selectNewDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void selectTime(String time) {
    selectedTimeSlot = time;
    notifyListeners();
  }
}