// lib/screens/search_screen.dart DOSYASINI GÜNCELLEYİN

import 'package:denemeye_devam/features/common/widgets/salon_card.dart';
import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Artık StatefulWidget'a gerek yok. Consumer ile ViewModel'ı dinleyeceğiz.
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColorLight,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- KATEGORİLER BÖLÜMÜ ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  'Kategoriler',
                  style: AppFonts.poppinsBold(
                      fontSize: 18, color: AppColors.textColorDark),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.categories[index];
                    final isSelected = viewModel.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          // Kategori seçimi için ViewModel'daki metodu çağır
                          viewModel.selectCategory(category);
                        },
                        selectedColor: AppColors.accentColor,
                        backgroundColor: AppColors.tagColorPassive,
                        labelStyle: AppFonts.bodyMedium(
                          color: isSelected ? Colors.white : AppColors.textColorDark,
                        ).copyWith(
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.accentColor
                                : AppColors.dividerColor.withValues(alpha: 0.5),
                          ),
                        ),
                        elevation: isSelected ? 3 : 1,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // --- ARAMA SONUÇLARI BÖLÜMÜ ---
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.filteredSaloons.isEmpty
                    ? _buildNoResultsFound()
                    : _buildSearchResultsList(viewModel),
              ),
            ],
          ),
        );
      },
    );
  }

  // "Sonuç Bulunamadı" mesajını gösteren widget
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 80, color: AppColors.textColorLight.withValues(alpha: 0.5)),
          const SizedBox(height: 20),
          Text(
            'Arama sonucunuz bulunamadı.',
            style: AppFonts.poppinsBold(
                fontSize: 18,
                color: AppColors.textColorLight.withValues(alpha: 0.8)),
          ),
          Text(
            'Farklı bir kelime veya kategoriyle arama yapmayı deneyin.',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium(
                color: AppColors.textColorLight.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  // Arama sonuçlarını listeleyen widget
  Widget _buildSearchResultsList(SearchViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: viewModel.filteredSaloons.length,
      itemBuilder: (context, index) {
        final salon = viewModel.filteredSaloons[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SalonCard(
            salonId: salon.saloonId,
            name: salon.saloonName,
            rating: '4.8', // TODO: Puanlama sistemini entegre et
            services: salon.services.map((s) => s.serviceName).toList(),
            // hasCampaign: salon.hasCampaign, // TODO: Kampanya modelini entegre et
          ),
        );
      },
    );
  }
}