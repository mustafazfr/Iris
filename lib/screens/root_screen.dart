import 'package:denemeye_devam/features/auth/screens/home_page.dart';
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';

// Ekran importları
import 'package:denemeye_devam/features/appointments/screens/appointments_screen.dart';
import 'package:denemeye_devam/screens/search_screen.dart';
import 'package:denemeye_devam/screens/favorites_screen.dart';
import 'package:denemeye_devam/screens/profile_screen.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';

// Bildirimler ekranı importu
import 'notifications_screen.dart';
import 'dashboard_screen.dart';

// ---- CUSTOM BAŞLIK ----
class BigScreenTitleBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const BigScreenTitleBar({
    Key? key,
    required this.title,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // bottom: 24 — Favoriler sayfasındaki boşlukla eşit
      padding: const EdgeInsets.only(
        top: 60,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF211E3B),
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- ROOT YÖNLENDİRİCİ ----
class RootScreen extends StatelessWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return authViewModel.user == null
        ? const HomePage()
        : const MainApp();
  }
}

// ---- MAIN APP ----
class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _searchController.addListener(() {
      Provider.of<SearchViewModel>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        Provider.of<SearchViewModel>(context, listen: false)
            .toggleSearch(false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) {
        _searchController.clear();
        _searchFocusNode.unfocus();
        Provider.of<SearchViewModel>(context, listen: false)
            .toggleSearch(false);
      }
    });
  }

  PreferredSizeWidget? _getAppBar(BuildContext context) {
    if (_selectedIndex == 0) return _dashboardAppBar(context);
    // Diğer sayfalarda AppBar yerine BigScreenTitleBar kullanılıyor
    return null;
  }

  AppBar _dashboardAppBar(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.user;
    final String userName = user?.userMetadata?['name'] ?? 'Kullanıcı';
    final String userSurname = user?.userMetadata?['surname'] ?? '';
    final String fullName = '$userName $userSurname'.trim();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      elevation: 0.0,
      shape: Border(
        bottom: BorderSide(
          color: AppColors.dividerColor,
          width: 1,
        ),
      ),
      toolbarHeight: 80.0,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => _onItemTapped(4),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person_outline,
                size: 28,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              fullName,
              style: AppFonts.h5SemiBold(color: AppColors.textColorDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                height: 8.0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Salon ara...',
                        style:
                        AppFonts.bodyMedium(color: AppColors.textColorLight),
                      ),
                    ),
                    Icon(Icons.tune, color: AppColors.textColorLight),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_outlined,
                color: AppColors.primaryColor,
                size: 30,
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 24,
      left: 35,
      right: 35,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(icon: Icons.home_outlined, index: 0),
                _buildNavItem(icon: Icons.calendar_today_outlined, index: 1),
                const SizedBox(width: 56),
                _buildNavItem(icon: Icons.favorite_border, index: 3),
                _buildNavItem(icon: Icons.person_outline, index: 4),
              ],
            ),
          ),
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/iris_logo.jpg',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyStack = [];

    Widget bodyContent = IndexedStack(
      index: _selectedIndex,
      children: [
        const DashboardScreen(),
        Column(
          children: [
            BigScreenTitleBar(
              title: 'Randevularım',
              onBack: () => _onItemTapped(0),
            ),
            const Expanded(child: AppointmentsScreen()),
          ],
        ),
        Column(
          children: [
            BigScreenTitleBar(
              title: 'Salon Ara',
              onBack: () => _onItemTapped(0),
            ),
            Expanded(child: SearchScreen()),
          ],
        ),
        Column(
          children: [
            BigScreenTitleBar(
              title: 'Favorilerim',
              onBack: () => _onItemTapped(0),
            ),
            const Expanded(child: FavoritesScreen()),
          ],
        ),
        Column(
          children: [
            BigScreenTitleBar(
              title: 'Profilim',
              onBack: () => _onItemTapped(0),
            ),
            const Expanded(child: ProfileScreen()),
          ],
        ),
      ],
    );

    bodyStack.add(bodyContent);
    bodyStack.add(_buildFloatingNavBar());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _getAppBar(context),
      body: Stack(children: bodyStack),
    );
  }
}
