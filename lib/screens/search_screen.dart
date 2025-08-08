// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/repositories/saloon_repository.dart';

import '../features/appointments/screens/salon_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<SaloonModel>> _futureSaloons;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Tümü',
    'Saç Bakımı',
    'Manikür',
    'Cilt Bakımı',
    'Masaj',
  ];
  String _selectedCategory = 'Tümü';

  @override
  void initState() {
    super.initState();
    _futureSaloons =
        SaloonRepository(Supabase.instance.client).getAllSaloons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Arama yap',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
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

            // --- CATEGORY CHIPS ---
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final sel = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: sel,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                      selectedColor: AppColors.accentColor,
                      backgroundColor: Colors.white,
                      labelStyle: AppFonts.bodyMedium(
                        color: sel ? Colors.white : AppColors.textColorDark,
                      ).copyWith(
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: sel
                              ? AppColors.accentColor
                              : AppColors.dividerColor.withOpacity(0.5),
                        ),
                      ),
                      elevation: sel ? 3 : 0,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // --- SALON LIST ---
            Expanded(
              child: FutureBuilder<List<SaloonModel>>(
                future: _futureSaloons,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Veri alınırken hata oluştu.',
                        style: AppFonts.bodyMedium(color: Colors.red),
                      ),
                    );
                  }

                  final all = snap.data ?? [];
                  final bySearch = _searchController.text.isEmpty
                      ? all
                      : all
                      .where((s) => s.saloonName
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                      .toList();
                  final filtered = _selectedCategory == 'Tümü'
                      ? bySearch
                      : bySearch.where((s) {
                    return s.services.any(
                            (srv) => srv.serviceName == _selectedCategory);
                  }).toList();

                  if (filtered.isEmpty) return _buildNoResults();

                  return ListView.separated(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.dividerColor),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) => _buildSalonRow(filtered[idx]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonRow(SaloonModel salon) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SalonDetailScreen(salonId: salon.saloonId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              )
                  : Container(
                width: 80,
                height: 80,
                color: AppColors.backgroundColorDark,
                child: Icon(Icons.store, color: AppColors.iconColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          salon.saloonName,
                          style: AppFonts.poppinsBold(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 14, color: AppColors.starColor),
                          const SizedBox(width: 4),
                          Text(
                            salon.avgRating != null
                                ? salon.avgRating!.toStringAsFixed(1)
                                : '-',
                            style: AppFonts.bodySmall(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (salon.services.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: salon.services.map((srv) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF3FD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            srv.serviceName,
                            style: AppFonts.bodySmall(
                                color: const Color(0xFF5360F4)),
                          ),
                        );
                      }).toList(),
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
        Text(
          'Arama sonucunuz bulunamadı.',
          style: AppFonts.poppinsBold(
            fontSize: 18,
            color: AppColors.textColorLight.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Farklı bir kategori veya isim deneyin.',
          textAlign: TextAlign.center,
          style: AppFonts.bodyMedium(
            color: AppColors.textColorLight.withOpacity(0.6),
          ),
        ),
      ],
    ),
  );
}
