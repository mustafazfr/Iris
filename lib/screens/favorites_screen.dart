// lib/screens/favorites_screen.dart
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart'; // SearchViewModel eklendi

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa her açıldığında listenin güncel olduğundan emin olalım
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).fetchFavoriteSaloons();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hem FavoritesViewModel hem SearchViewModel'daki değişiklikleri dinlemek için Consumer2 kullanıyoruz
    return Consumer2<FavoritesViewModel, SearchViewModel>(
      builder: (context, favoritesViewModel, searchViewModel, child) {
        // Arama sorgusuna göre filtrelenmiş listeyi elde et
        final List<SaloonModel> displaySaloons = searchViewModel.searchQuery.isEmpty
            ? favoritesViewModel.favoriteSaloons
            : favoritesViewModel.favoriteSaloons.where((saloon) {
          final query = searchViewModel.searchQuery.toLowerCase();
          return saloon.saloonName.toLowerCase().contains(query) ||
              (saloon.saloonAddress?.toLowerCase().contains(query) ?? false);
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColorLight,
          // AppBar'ı buradan kaldırdık. Artık RootScreen'daki MainApp yönetecek.
          body: favoritesViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : displaySaloons.isEmpty
              ? _buildEmptyFavorites(context, searchViewModel.searchQuery.isNotEmpty)
              : _buildFavoritesList(favoritesViewModel, displaySaloons),
        );
      },
    );
  }

  Widget _buildEmptyFavorites(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSearching ? Icons.search_off : Icons.favorite_border, size: 80, color: AppColors.iconColor.withAlpha(128)),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'Arama sonucunuz bulunamadı.' : 'Henüz favori salonunuz yok.',
            style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorLight),
          ),
          const SizedBox(height: 10),
          Text(
            isSearching ? 'Farklı bir arama terimi deneyin.' : 'Beğendiğiniz salonları favorilerinize ekleyin!',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium(color: AppColors.textColorLight),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesViewModel viewModel, List<SaloonModel> saloonsToDisplay) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: saloonsToDisplay.length,
      itemBuilder: (context, index) {
        final salon = saloonsToDisplay[index];
        return FavoriteSalonCard(
          salon: salon,
          onRemoveFavorite: () => viewModel.toggleFavorite(salon.saloonId),
          onBookAppointment: () => viewModel.navigateToSalonDetail(context, salon),
        );
      },
    );
  }
}

// FavoriteSalonCard değişmedi, sadece SaloonModel aldığı için adı güncel
class FavoriteSalonCard extends StatelessWidget {
  final SaloonModel salon;
  final VoidCallback onRemoveFavorite;
  final VoidCallback onBookAppointment;

  const FavoriteSalonCard({
    super.key,
    required this.salon,
    required this.onRemoveFavorite,
    required this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final tags = salon.services != null && salon.services!.isNotEmpty
        ? salon.services!.map((e) => e.serviceName).toList()
        : ["Makyaj", "Saç Kesim", "Saç Bakım"];
    final showTags = tags.length > 2 ? tags.take(2).toList() : tags;
    final showMore = tags.length > 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SOLDA: TAM RADIUS FOTO
              ClipRRect(
                borderRadius: BorderRadius.circular(22), // Tüm köşeler radius
                child: salon.titlePhotoUrl != null && salon.titlePhotoUrl!.isNotEmpty
                    ? Image.network(
                  salon.titlePhotoUrl!,
                  width: 95,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 75,
                  height: double.infinity,
                  color: Colors.white,
                  child: Icon(Icons.store, size: 32, color: AppColors.primaryColor),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Salon adı
                      Text(
                        salon.saloonName,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Puan - Adres - Mesafe
                      Row(
                        children: [
                          Icon(Icons.star, size: 13, color: Color(0xFFD7D9E2)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              salon.ratingCount?.toStringAsFixed(1) ?? "4.1",
                              style: const TextStyle(
                                color: Color(0xFFD7D9E2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.circle, size: 7, color: Color(0xFFD7D9E2)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              salon.saloonAddress ?? "İstanbul",
                              style: const TextStyle(
                                color: Color(0xFFD7D9E2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.circle, size: 7, color: Color(0xFFD7D9E2)),
                          const SizedBox(width: 6),
                          const Text(
                            "5 Km",
                            style: TextStyle(
                              color: Color(0xFFD7D9E2),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Hizmetler tagleri (küçük font, tek satırda)
                      SizedBox(
                        height: 22,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: [
                            ...showTags.map((tag) => Container(
                              margin: const EdgeInsets.only(right: 7),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            )),
                            if (showMore)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6), // <-- HİZMETLER ile BUTON arasında 6px boşluk
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryColor,
                                side: const BorderSide(color: AppColors.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                minimumSize: const Size(110, 34),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              onPressed: onBookAppointment,
                              child: const Text("Randevu Oluştur"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Favori butonu sağ üstte, tamamen yuvarlatılmış kartta
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onRemoveFavorite,
              child: Icon(Icons.favorite, color: AppColors.primaryColor, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}








