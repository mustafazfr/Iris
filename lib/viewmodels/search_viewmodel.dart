// lib/viewmodels/search_viewmodel.dart DOSYASINI GÜNCELLEYİN

import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/repositories/saloon_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchViewModel extends ChangeNotifier {
  final SaloonRepository _repository =
  SaloonRepository(Supabase.instance.client);

  // --- STATE (DURUM) DEĞİŞKENLERİ ---


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _mainSearchQuery = '';
  // --- BURAYA EKLEYİN ---
  String get searchQuery => _mainSearchQuery; // Dışarıdan erişim için getter

  // Kategori seçimi için
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  // Veri listeleri
  List<SaloonModel> _allSaloons = []; // Veritabanından gelen tüm salonlar
  List<SaloonModel> _filteredSaloons = []; // Ekranda gösterilecek filtrelenmiş liste
  List<SaloonModel> get filteredSaloons => _filteredSaloons;

  // Statik kategori listesi
  final List<String> categories = [
    'Saç bakımı', 'Manikür', 'Cilt Bakımı', 'Masaj', 'Epilasyon', 'Makyaj'
  ];

  // ViewModel oluşturulduğunda salonları çek
  SearchViewModel() {
    fetchAllSaloons();
  }

  /// Veritabanından tüm salonları çeker ve başlangıç listesini ayarlar.
  Future<void> fetchAllSaloons() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSaloons = await _repository.getAllSaloons();
      _filteredSaloons = _allSaloons; // Başlangıçta hepsi gösterilir
    } catch (e) {
      debugPrint("fetchAllSaloons Hata: $e");
      _allSaloons = [];
      _filteredSaloons = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Hem arama metnine hem de seçili kategoriye göre filtreleme yapan ana metot.
  void _filterResults() {
    List<SaloonModel> results;

    // Filtreleme yapılacak ana liste her zaman `_allSaloons` olmalı
    if (_mainSearchQuery.isEmpty && _selectedCategory == null) {
      results = _allSaloons; // Hiçbir filtre yoksa tümünü göster
    } else {
      results = _allSaloons.where((saloon) {
        final query = _mainSearchQuery.toLowerCase();
        final category = _selectedCategory?.toLowerCase();

        // 1. Kategori Kontrolü
        // Eğer bir kategori seçiliyse, salonun o kategoride hizmeti var mı?
        final categoryMatches = category == null ||
            saloon.services
                .any((s) => s.serviceName.toLowerCase().contains(category));

        // Kategori uyuşmuyorsa direkt false dön, devamını kontrol etme
        if (!categoryMatches) return false;

        // 2. Arama Metni Kontrolü
        // Arama çubuğu boşsa, sadece kategori filtresi yeterli
        if (query.isEmpty) return true;

        // Arama metni, salon adında veya herhangi bir hizmet adında geçiyor mu?
        final nameMatches = saloon.saloonName.toLowerCase().contains(query);
        final serviceMatches =
        saloon.services.any((s) => s.serviceName.toLowerCase().contains(query));

        return nameMatches || serviceMatches;
      }).toList();
    }
    _filteredSaloons = results;
    notifyListeners();
  }

  /// AppBar'dan gelen arama metnini günceller ve filtrelemeyi tetikler.
  void setSearchQuery(String query) {
    _mainSearchQuery = query;
    _filterResults();
  }

  /// Kategori seçildiğinde veya seçim kaldırıldığında filtrelemeyi tetikler.
  void selectCategory(String? category) {
    // Eğer aynı kategoriye tekrar tıklanırsa seçimi kaldır (toggle)
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    _filterResults();
  }

  // Arama modunu yöneten bool'u ve toggle'ı da ekleyelim (RootScreen ile uyum için)
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  void toggleSearch(bool value) {
    _isSearching = value;
    if (!value) {
      _mainSearchQuery = ''; // Arama kapatıldığında sorguyu temizle
    }
    notifyListeners();
  }
}