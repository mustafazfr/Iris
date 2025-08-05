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

  // ViewModel oluşturulduğunda favorileri çekmesi için constructor'a ekliyoruz.
  FavoritesViewModel() {
    fetchFavoriteSaloons();
  }

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
  Future<void> toggleFavorite(String salonId, {SaloonModel? salon}) async {
    if (isSalonFavorite(salonId)) {
      // Favoriden Çıkar
      await _repository.removeFavorite(salonId);
      _favoriteSaloons.removeWhere((s) => s.saloonId == salonId);
      _favoriteSaloonIds.remove(salonId);
    } else {
      // Favoriye Ekle
      await _repository.addFavorite(salonId);
      _favoriteSaloonIds.add(salonId);
      // Eğer salon bilgisi de verildiyse, listeye ekleyerek arayüzün anında güncellenmesini sağla
      if (salon != null) {
        _favoriteSaloons.insert(0, salon);
      }
    }
    // Değişiklik sonrası tüm dinleyicilere haber ver!
    notifyListeners();
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