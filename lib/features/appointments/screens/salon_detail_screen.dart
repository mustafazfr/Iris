// GEREKLİ TÜM IMPORT'LAR BURADA
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/models/service_model.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../models/comment_model.dart';
import '../../../viewmodels/comments_viewmodel.dart';
import '../../../viewmodels/favorites_viewmodel.dart';
import '../../../viewmodels/saloon_detail_viewmodel.dart';

class SalonDetailScreen extends StatefulWidget {
  final String salonId;

  const SalonDetailScreen({super.key, required this.salonId});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  int _selectedGalleryIndex = 1;

  final List<String> _galleryImages = [];

  final List<Map<String, String>> _personnel = List.generate(10, (i) { // Örnek olması için sayıyı 10'a çıkardım
    return {
      'name': 'Jhon Doe ${i+1}',
      'role': 'Saç Stilisti',
      'avatarUrl': 'https://via.placeholder.com/100'
    };
  });

  final List<String> _allPossibleCategories = ['Cilt Bakım', 'Nail Art', 'Saç Kesim', 'Saç Bakım'];
  String _selectedCategory = 'Cilt Bakım';

  // --- SEPET YÖNETİMİ ---
  final Map<ServiceModel, int> _cart = {};
  final double _couponDiscount = 10.0;

  int get _totalCount => _cart.length;

  double get _totalPrice => _cart.isEmpty
      ? 0.0
      : _cart.keys.map((s) => s.basePrice).reduce((a, b) => a + b);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
  }

  void _addService(ServiceModel service) {
    setState(() {
      if (!_cart.containsKey(service)) {
        _cart[service] = 1;
      }
    });
  }

  void _removeService(ServiceModel service) {
    setState(() {
      _cart.remove(service);
    });
  }
  // --- SEPET YÖNETİMİ BİTİŞ ---

  List<ServiceModel> _filterByCategory(List<ServiceModel> services) {
    return services.where((s) {
      final name = s.serviceName.toLowerCase();
      switch (_selectedCategory) {
        case 'Cilt Bakım':
          return name.contains('cilt') || name.contains('bakım') || name.contains('kolajen') || name.contains('oksijen');
        case 'Nail Art':
          return name.contains('nail') || name.contains('tırnak');
        case 'Saç Kesim':
          return name.contains('saç') && name.contains('kesim');
        case 'Saç Bakım':
          return name.contains('saç') && name.contains('bakım');
        default:
          return true;
      }
    }).toList();
  }

  List<String> _getAvailableCategories(List<ServiceModel> allServices) {
    final Map<String, bool Function(String)> categoryChecks = {
      'Cilt Bakım': (name) => name.contains('cilt') || name.contains('bakım') || name.contains('kolajen') || name.contains('oksijen'),
      'Nail Art': (name) => name.contains('nail') || name.contains('tırnak'),
      'Saç Kesim': (name) => name.contains('saç') && name.contains('kesim'),
      'Saç Bakım': (name) => name.contains('saç') && name.contains('bakım'),
    };

    final availableCategories = <String>[];
    categoryChecks.forEach((categoryName, checkFunction) {
      if (allServices.any((service) => checkFunction(service.serviceName.toLowerCase()))) {
        availableCategories.add(categoryName);
      }
    });
    return availableCategories;
  }

  int _getTabIndex(String tabText) {
    switch (tabText) {
      case 'Hakkımızda':
        return 0;
      case 'Galeri':
        return 1;
      case 'Personeller':
        return 2;
      case 'Yorumlar':
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildNewTab(String text) {
    return Builder(
      builder: (context) {
        final tabController = DefaultTabController.of(context);
        if (tabController == null) return Tab(text: text);

        return ListenableBuilder(
          listenable: tabController.animation!,
          builder: (context, child) {
            final currentIndex = tabController.index;
            final isSelected = currentIndex == _getTabIndex(text);

            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5A67D8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkingHoursRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
        Text(
          hours,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
          SalonDetailViewModel()..fetchSalonDetails(widget.salonId),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentsViewModel()..fetchComments(widget.salonId),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesViewModel(),
        ),
      ],
      child: Consumer2<SalonDetailViewModel, CommentsViewModel>(
        builder: (context, salonVM, commentsVM, child) {
          if (salonVM.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (salonVM.salon == null) {
            return const Scaffold(
              body: Center(child: Text('Salon bilgileri alınamadı.')),
            );
          }
          final salon = salonVM.salon!;
          final availableCategories = _getAvailableCategories(salon.services);

          if (availableCategories.isNotEmpty && !availableCategories.contains(_selectedCategory)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedCategory = availableCategories.first;
                });
              }
            });
          }

          final filteredServices = _filterByCategory(salon.services);

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(context),
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.backgroundColorLight,
                        AppColors.backgroundColorDark,
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderWithActions(context, salon),
                      const SizedBox(height: 10),
                      _buildCalendar(context, salonVM),
                      const SizedBox(height: 20),
                      _buildServicesListSection(salon, salonVM, filteredServices, availableCategories),
                      const SizedBox(height: 20),
                      DefaultTabController(
                        length: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TabBar(
                                isScrollable: true,
                                labelPadding: EdgeInsets.zero,
                                indicatorColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                tabs: [
                                  _buildNewTab('Hakkımızda'),
                                  _buildNewTab('Galeri'),
                                  _buildNewTab('Personeller'),
                                  _buildNewTab('Yorumlar'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 450,
                              child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _aboutSection(salon),
                                  _gallerySection(),
                                  _personnelSection(),
                                  _commentsTabSection(commentsVM),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 160),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SafeArea(
                    top: false,
                    child: _buildBottomBarContent(context, salonVM),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- WIDGET BUILDER'LAR ----
  AppBar _buildAppBar(BuildContext context) {
    final favVM = context.watch<FavoritesViewModel>();
    final detailVM = context.read<SalonDetailViewModel>();
    final isFav = favVM.isSalonFavorite(widget.salonId);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.arrow_back, color: AppColors.textColorDark),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: AppColors.primaryColor,
            ),
          ),
          onPressed: () =>
              favVM.toggleFavorite(widget.salonId, salon: detailVM.salon),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
  Widget _buildHeaderWithActions(BuildContext context, SaloonModel salon) {
    return Column(
      children: [
        _buildHeader(context, salon),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _actionItem(Icons.favorite_border, 'Favoriler'),
                    const SizedBox(width: 16),
                    _actionItem(Icons.location_on_outlined, 'Konuma git'),
                    const SizedBox(width: 16),
                    _actionItem(Icons.share_outlined, 'Paylaş'),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    Text('4.1', style: AppFonts.poppinsBold()),
                    const SizedBox(width: 8),
                    Text('99+ yorum',
                        style: AppFonts.bodySmall(color: AppColors.textColorLight)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Divider(
            thickness: 1,
            height: 10,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.percent,
                          size: 24, color: AppColors.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '50% indirim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'FREE50 Kodu ile',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                height: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
  Widget _actionItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: AppColors.primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppFonts.poppinsBold(
            fontSize: 12,
            color: AppColors.textColorDark,
          ),
        ),
      ],
    );
  }

  Widget _aboutSection(SaloonModel salon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İris Güzellik Salonu\'nda kendinizi özel hissetmeniz için uzman ellerde kişiye özel bakım sunuyoruz. Doğal güzelliğinizi ön plana çıkaran, güvenli ve modern hizmetlerle yanınızdayız.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          const Text(
            'Çalışma Saatleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildWorkingHoursRow('Haftaiçi', '09:00 - 21:00'),
          const SizedBox(height: 8),
          _buildWorkingHoursRow('Haftasonu', '09:00 - 22:00'),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Salon Adresi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  salon.saloonAddress ?? 'Adres bilgisi girilmemiş.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.shade100,
              image: const DecorationImage(
                image: AssetImage('assets/map_placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gallerySection() {
    if (_galleryImages.isEmpty) {
      return const Center(
        child: Text(
          'Galeride resim bulunmuyor.',
          style: TextStyle(color: AppColors.textColorLight),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_galleryImages.length, (i) {
              final isSelected = i == _selectedGalleryIndex;
              final width = isSelected ? 120.0 : 100.0;
              final height = isSelected ? 160.0 : 130.0;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGalleryIndex = i;
                  });
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: isSelected
                        ? Border.all(color: AppColors.primaryColor, width: 3)
                        : null,
                    image: DecorationImage(
                      image: NetworkImage(_galleryImages[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // DEĞİŞİKLİK: Personel bölümü ListView'dan GridView'a çevrildi.
  Widget _personnelSection() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,        // Her satırda 3 personel
        crossAxisSpacing: 16,     // Yatay boşluk
        mainAxisSpacing: 16,      // Dikey boşluk
        childAspectRatio: 0.8,    // Genişlik/Yükseklik oranı
      ),
      itemCount: _personnel.length,
      itemBuilder: (context, i) {
        final p = _personnel[i];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(p['avatarUrl'] ?? ''),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Text(
              p['name'] ?? '',
              style: AppFonts.poppinsBold(fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              p['role'] ?? '',
              style: AppFonts.bodySmall(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _commentsTabSection(CommentsViewModel vm) {
    final TextEditingController commentController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                ? Center(child: Text(vm.error!))
                : vm.comments.isEmpty
                ? const Center(child: Text("Henüz yorum yapılmamış."))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: vm.comments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) => _buildCommentListItem(vm.comments[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Yorumunuzu yazın...',
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final text = commentController.text.trim();
                    if (text.isEmpty) return;
                    vm.postComment(text: text, userId: '', salonId: widget.salonId, rating: 5, userName: '').then((_) {
                      commentController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesListSection(SaloonModel salon, SalonDetailViewModel vm,
      List<ServiceModel> filteredServices, List<String> availableCategories) {
    if (availableCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
        child: Center(
          child: Text(
            'Bu salonda henüz hizmet bulunmuyor.',
            style: AppFonts.bodyMedium(color: AppColors.textColorLight),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildCategoryTabs(availableCategories),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _selectedCategory,
            style: AppFonts.poppinsBold(fontSize: 26),
          ),
        ),
        const SizedBox(height: 8),
        if (filteredServices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Text(
                'Bu kategoride servis bulunamadı.',
                style: AppFonts.bodyMedium(color: AppColors.textColorLight),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: filteredServices.length,
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              return _buildServiceListItem(service);
            },
            separatorBuilder: (context, index) {
              return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
            },
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCategoryTabs(List<String> categories) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final cat = categories[idx];
            final bool isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.15)
                      : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: isSelected
                        ? AppFonts.poppinsBold(fontSize: 14)
                        .copyWith(color: AppColors.primaryColor)
                        : AppFonts.bodyMedium(color: AppColors.textColorDark),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildCalendar(
      BuildContext context, SalonDetailViewModel viewModel) {
    final List<DateTime> weekDates =
    List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = viewModel.selectedDate?.day == date.day;

          return GestureDetector(
            onTap: () => viewModel.selectNewDate(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color:
                isSelected ? AppColors.accentColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'tr_TR').format(date),
                    style: AppFonts.bodyMedium(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textColorDark,
                    ),
                  ),
                  Text(
                    DateFormat('dd').format(date),
                    style: AppFonts.poppinsBold(
                      fontSize: 20,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textColorDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildCommentsSection(CommentsViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return Center(child: Text(vm.error!));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.comments.length,
      itemBuilder: (context, i) => _buildCommentListItem(vm.comments[i]),
    );
  }
  Widget _buildCommentListItem(CommentModel c) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.userName, style: AppFonts.poppinsBold()),
                const SizedBox(height: 4),
                Text(c.commentText),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd MMM yyyy – HH:mm', 'tr_TR')
                      .format(c.createdAt),
                  style: AppFonts.bodySmall(color: AppColors.textColorLight),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              c.rating,
                  (_) => const Icon(Icons.star, size: 16, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceListItem(ServiceModel service) {
    final bool isAdded = _cart.containsKey(service);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              service.imageUrl ?? 'https://via.placeholder.com/90',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 90, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: AppFonts.poppinsBold(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${service.basePrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${service.estimatedTime.inMinutes} Dak',
                      style: AppFonts.bodySmall(color: AppColors.textColorLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 90,
            child: Align(
              alignment: Alignment.center,
              child: isAdded
                  ? ElevatedButton(
                onPressed: () => _removeService(service),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Çıkart', style: AppFonts.bodySmall(color: Colors.white)),
                    const SizedBox(width: 4),
                    const Icon(Icons.remove, size: 16, color: Colors.white),
                  ],
                ),
              )
                  : OutlinedButton(
                onPressed: () => _addService(service),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ekle', style: AppFonts.bodySmall(color: AppColors.primaryColor)),
                    const SizedBox(width: 4),
                    const Icon(Icons.add, size: 16, color: AppColors.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SaloonModel salon) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            child: salon.titlePhotoUrl != null &&
                salon.titlePhotoUrl!.isNotEmpty
                ? Image.network(
              salon.titlePhotoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image, color: Colors.white)),
            )
                : Image.asset('assets/map_placeholder.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.saloonName,
                    style: AppFonts.poppinsBold(fontSize: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('4.1 • İstanbul • 5 Km',
                          style: AppFonts.bodySmall(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    salon.saloonAddress ?? 'Adres belirtilmemiş',
                    style: AppFonts.bodySmall(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Makyaj', 'Saç Kesim', 'Saç Bakım']
                        .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t, style: AppFonts.bodyMedium(color: Colors.white)),
                    ))
                        .toList(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomBarContent(BuildContext context, SalonDetailViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 2),
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_totalCount', style: AppFonts.poppinsBold(color: Colors.white)),
                Text('\$${_totalPrice.toStringAsFixed(0)}', style: AppFonts.bodySmall(color: Colors.white)),
                Text('vergiler dahil',
                    style:
                    AppFonts.bodySmall(color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_cart.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen randevu almak için en az bir hizmet seçin.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                _showConfirmationSheet(context, vm);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text('Randevu Al', style: AppFonts.poppinsBold(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ---- YENİ ONAY POP-UP KODU ----
  void _showConfirmationSheet(BuildContext context, SalonDetailViewModel viewModel) {
    const primaryColor = Color(0xFF5A67D8);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            DateTime pickedDate = viewModel.selectedDate ?? DateTime.now();
            TimeOfDay pickedTime = viewModel.selectedTimeSlot != null
                ? TimeOfDay(
              hour: int.parse(viewModel.selectedTimeSlot!.split(':')[0]),
              minute: int.parse(viewModel.selectedTimeSlot!.split(':')[1]),
            )
                : const TimeOfDay(hour: 9, minute: 0);

            double subtotal = _cart.isEmpty
                ? 0.0
                : _cart.keys.map((e) => e.basePrice).reduce((a, b) => a + b);
            double totalAmount = subtotal - _couponDiscount;

            void removeServiceFromPopup(ServiceModel s) {
              setState(() {});
              modalSetState(() {
                _removeService(s);
              });
            }

            Future<void> selectDate() async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: pickedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                modalSetState(() => pickedDate = date);
                viewModel.selectNewDate(date);
              }
            }

            Future<void> selectTime() async {
              final TimeOfDay? t = await showTimePicker(
                context: context,
                initialTime: pickedTime,
              );
              if (t != null) {
                modalSetState(() => pickedTime = t);
                final formatted = t.format(context);
                viewModel.selectTime(formatted);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16, right: 16, top: 24
              ),
              child: Wrap(
                children: [
                  Center(
                    child: Text(
                      'Randevu Noktası',
                      style: AppFonts.poppinsBold(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationSalonInfoCard(viewModel.salon!, primaryColor),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: selectDate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tarih Seç :', style: AppFonts.bodyMedium(color: Colors.grey.shade600)),
                        Row(
                          children: [
                            Text(
                              DateFormat('dd.MM.yyyy').format(pickedDate),
                              style: AppFonts.poppinsBold(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: selectTime,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saat Seç :', style: AppFonts.bodyMedium(color: Colors.grey.shade600)),
                        Row(
                          children: [
                            Text(
                              pickedTime.format(context),
                              style: AppFonts.poppinsBold(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.access_time_filled, color: Colors.grey, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  if (_cart.isNotEmpty)
                    ..._cart.keys.map((service) =>
                        _buildConfirmationServiceTile(service, primaryColor, removeServiceFromPopup)
                    ).toList()
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("Sepetinizde hizmet bulunmuyor."),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildConfirmationPriceDetails(subtotal, totalAmount),
                  const SizedBox(height: 24),
                  _buildConfirmationFinalButton(primaryColor),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //--- ONAY POP-UP YARDIMCI WIDGET'LARI ---

  Widget _buildConfirmationSalonInfoCard(SaloonModel salon, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                salon.saloonName,
                style: AppFonts.poppinsBold(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  salon.saloonAddress ?? 'Adres bilgisi yok',
                  style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationServiceTile(ServiceModel service, Color primaryColor, Function(ServiceModel) onRemove) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              service.imageUrl ?? 'https://via.placeholder.com/80x80?text=Hizmet',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.serviceName,
                  style: AppFonts.poppinsBold(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${service.estimatedTime.inMinutes} Dak',
                      style: AppFonts.bodySmall(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  onPressed: () => onRemove(service),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text('Çıkart', style: AppFonts.bodySmall()),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${service.basePrice.toStringAsFixed(0)}',
                style: AppFonts.poppinsBold(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationPriceDetails(double subtotal, double totalAmount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Toplam Hizmet Bedeli', style: AppFonts.bodyMedium(color: Colors.grey.shade700)),
            Text('\$${subtotal.toStringAsFixed(0)}', style: AppFonts.bodyMedium()),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kupon indirimi', style: AppFonts.bodyMedium(color: Colors.grey.shade700)),
            Text('-\$${_couponDiscount.toStringAsFixed(0)}', style: AppFonts.bodyMedium(color: Colors.green.shade600)),
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Toplam Tutar', style: AppFonts.poppinsBold(fontSize: 18)),
            Text('\$${totalAmount.toStringAsFixed(0)}', style: AppFonts.poppinsBold(fontSize: 20)),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationFinalButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Randevunuz başarıyla oluşturuldu!'), backgroundColor: Colors.green)
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          'Randevuyu Onayla',
          style: AppFonts.poppinsBold(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}