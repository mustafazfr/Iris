// lib/screens/search_screen.dart (SON HALİ)

import 'dart:async';
import 'package:denemeye_devam/models/category_summary_model.dart';
import 'package:denemeye_devam/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import '../features/appointments/screens/salon_detail_screen.dart';
import '../repositories/saloon_repository.dart';

class SearchScreen extends StatefulWidget {
  // Artık dışarıdan gelen initial parametrelerine ihtiyacımız olabilir
  // ama AppBar'ı etkilemeyecekler.
  final String? initialCategoryId;
  final String? initialCategoryName;

  const SearchScreen({
    super.key,
    this.initialCategoryId,
    this.initialCategoryName,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  late final SaloonRepository _saloonRepository;
  late final CategoryRepository _categoryRepository;

  Future<List<SaloonModel>>? _saloonsFuture;
  Future<List<CategorySummaryModel>>? _categoriesFuture;

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    _saloonRepository = SaloonRepository(supabase);
    _categoryRepository = CategoryRepository(supabase);
    _selectedCategoryId = widget.initialCategoryId;
    _searchController.addListener(_onSearchChanged);
    _categoriesFuture = _categoryRepository.fetchAllCategories();
    _triggerSearch();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _triggerSearch();
    });
  }

  void _triggerSearch() {
    setState(() {
      _saloonsFuture = _saloonRepository.searchSaloons(
        query: _searchController.text,
        categoryId: _selectedCategoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Artık canPop veya karmaşık AppBar mantığı yok.
    return Scaffold(
      backgroundColor: Colors.white,
      // SafeArea, ekranın durum çubuğunun altına girmesini engeller.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Salon Ara",
                  style: AppFonts.h2Bold(color: AppColors.textColorDark),
                ),
              ),
            ),
            // Arama Çubuğu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Salon adı ile ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.tagColorPassive.withOpacity(0.1),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            _buildCategoryChips(),

            const SizedBox(height: 8),

            Expanded(
              child: FutureBuilder<List<SaloonModel>>(
                future: _saloonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryColor));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Hata: ${snapshot.error}',
                            style: AppFonts.bodyMedium(color: Colors.red)));
                  }
                  final saloons = snapshot.data ?? [];
                  if (saloons.isEmpty) {
                    return _buildNoResults();
                  }
                  return ListView.separated(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.dividerColor.withOpacity(0.5)),
                    itemCount: saloons.length,
                    itemBuilder: (ctx, idx) => _buildSalonRow(saloons[idx]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return FutureBuilder<List<CategorySummaryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 40);
        final allCategories = snapshot.data!;
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allCategories.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                final isSelected = _selectedCategoryId == null;
                return _buildChip(
                  label: "Tümü",
                  isSelected: isSelected,
                  onSelected: (_) {
                    if (!isSelected) {
                      setState(() => _selectedCategoryId = null);
                      _triggerSearch();
                    }
                  },
                );
              }
              final cat = allCategories[i - 1];
              final isSelected = cat.categoryId == _selectedCategoryId;
              return _buildChip(
                label: cat.name,
                isSelected: isSelected,
                onSelected: (_) {
                  if (!isSelected) {
                    setState(() => _selectedCategoryId = cat.categoryId);
                    _triggerSearch();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChip(
      {required String label,
        required bool isSelected,
        required ValueChanged<bool> onSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: AppColors.primaryColor,
        backgroundColor: Colors.white,
        labelStyle: AppFonts.bodyMedium(
          color: isSelected ? Colors.white : AppColors.textColorDark,
        ).copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.dividerColor.withOpacity(0.5),
          ),
        ),
        elevation: isSelected ? 2 : 0,
        pressElevation: 0,
      ),
    );
  }

  Widget _buildSalonRow(SaloonModel salon) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SalonDetailScreen(salonId: salon.saloonId))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: salon.titlePhotoUrl != null &&
                  salon.titlePhotoUrl!.isNotEmpty
                  ? Image.network(
                salon.titlePhotoUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.store, color: Colors.grey)),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200);
                },
              )
                  : Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.store, color: Colors.grey)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(salon.saloonName,
                      style: AppFonts.h6Bold(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(salon.saloonAddress ?? 'Adres bilgisi yok',
                      style:
                      AppFonts.bodySmall(color: AppColors.textColorLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: AppColors.starColor),
                      const SizedBox(width: 4),
                      Text(salon.avgRating.toStringAsFixed(1),
                          style: AppFonts.bodyMedium()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off,
            size: 80, color: AppColors.textColorLight.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text('Arama sonucunuz bulunamadı.',
            style: AppFonts.h5Bold(
                color: AppColors.textColorLight.withOpacity(0.8))),
        const SizedBox(height: 8),
        Text('Farklı bir kategori veya isim deneyin.',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium(
                color: AppColors.textColorLight.withOpacity(0.6))),
      ],
    ),
  );
}