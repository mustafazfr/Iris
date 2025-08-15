import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/repositories/favorites_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/appointments/screens/salon_detail_screen.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository = FavoritesRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Arayüzde gösterilecek olan, SaloonModel tipindeki listeler
  List<SaloonModel> _favoriteSaloons = [];
  List<SaloonModel> get favoriteSaloons => _favoriteSaloons;

  // Hızlı kontrol için sadece favori salonların ID'lerini tutan set
  Set<String> _favoriteSaloonIds = {};


  /// Veritabanından kullanıcının favori salonlarını çeker ve state'i günceller.
  Future<void> fetchFavoriteSaloons() async {
    _isLoading = true;
    notifyListeners();


    final currentUserId = _repository.getCurrentUserId();

    if (currentUserId != null) {
      // 1. Veritabanından FavouriteModel listesini çek.
      final favouriteModels = await _repository.getFavoriteSaloons(currentUserId);

      // 2. Bu listenin içindeki SaloonModel'leri ayıklayıp yeni bir liste oluştur.
      final saloons = favouriteModels
          .where((fav) => fav.saloon != null) // Sadece salonu olan favorileri al (güvenlik önlemi)
          .map((fav) => fav.saloon!)         // İçindeki SaloonModel'i çıkar
          .toList();

      // 3. Oluşturduğun bu temiz SaloonModel listesini ve ID set'ini state değişkenlerine ata.
      _favoriteSaloons = saloons;
      _favoriteSaloonIds = saloons.map((s) => s.saloonId).toSet();

    } else {
      // Kullanıcı giriş yapmamışsa listeleri boşalt.
      _favoriteSaloons = [];
      _favoriteSaloonIds = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Verilen salon ID'sinin favorilerde olup olmadığını anında kontrol eder.
  bool isSalonFavorite(String salonId) {
    return _favoriteSaloonIds.contains(salonId);
  }

  /// Bir salonun favori durumunu değiştirir (ekler veya çıkarır).
  /// Bu, tüm favori işlemlerinin yönetildiği merkezi fonksiyondur.
  Future<void> toggleFavorite(String saloonId, {SaloonModel? salon}) async {
    final wasFav = _favoriteSaloonIds.contains(saloonId);

    if (wasFav) {
      // 1) İyimser: hemen çıkar
      _favoriteSaloonIds.remove(saloonId);
      _favoriteSaloons.removeWhere((s) => s.saloonId == saloonId);
      notifyListeners();

      try {
        // 2) Server
        await _repository.removeFavorite(saloonId);
      } catch (e) {
        // 3) Rollback
        _favoriteSaloonIds.add(saloonId);
        if (salon != null) _favoriteSaloons.insert(0, salon);
        notifyListeners();
        rethrow;
      }
    } else {
      // 1) İyimser: hemen ekle
      _favoriteSaloonIds.add(saloonId);
      if (salon != null) {
        _favoriteSaloons.insert(0, salon);
      }
      notifyListeners();

      try {
        // 2) Server
        await _repository.addFavorite(saloonId);

        // (opsiyonel) salon null geldiyse detayı tazelemek için:
        if (salon == null) {
          await fetchFavoriteSaloons(/* force: true */);
        }
      } catch (e) {
        // 3) Rollback
        _favoriteSaloonIds.remove(saloonId);
        _favoriteSaloons.removeWhere((s) => s.saloonId == saloonId);
        notifyListeners();
        rethrow;
      }
    }
  }


  /// Bir salona tıklandığında detay sayfasına yönlendirme yapan fonksiyon.
  void navigateToSalonDetail(BuildContext context, SaloonModel salon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalonDetailScreen(salonId: salon.saloonId),
      ),
    );
  }
}