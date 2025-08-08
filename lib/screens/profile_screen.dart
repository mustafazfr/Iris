// lib/screens/profile_screen.dart

import 'package:denemeye_devam/viewmodels/appointments_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:provider/provider.dart';
import '../features/auth/screens/home_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel'ları dinleyerek kod tekrarını önlüyoruz.
    return Consumer3<AuthViewModel, AppointmentsViewModel, FavoritesViewModel>(
      builder: (context, authViewModel, appointmentsViewModel, favoritesViewModel, child) {
        final user = authViewModel.user;
        final appointmentCount = appointmentsViewModel.allAppointments.length;
        final favoriteCount = favoritesViewModel.favoriteSaloons.length;

        final String userName = user?.userMetadata?['name'] ?? 'Misafir';
        final String userSurname = user?.userMetadata?['surname'] ?? 'Kullanıcı';
        final String fullName = '$userName $userSurname'.trim();

        return Scaffold(
          backgroundColor: Colors.white, // Arkaplan beyaz yapıldı
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // --- AVATAR ---
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE3DFFF),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 70,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  fullName,
                  style: AppFonts.poppinsBold(fontSize: 24, color: AppColors.textColorDark),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? 'E-posta adresi yok',
                  style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                ),
                const SizedBox(height: 30),
                // --- Profili Düzenle Butonu ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil Düzenleme özelliği yakında eklenecektir.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: Text(
                      'Profili Düzenle',
                      style: AppFonts.poppinsBold(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // --- Menü Öğeleri ---
                _buildProfileMenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Randevularım',
                  subtitle: '$appointmentCount Randevu',
                  onTap: () {
                    // TODO: Randevularım sayfasına yönlendir
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.favorite_border,
                  title: 'Favorilerim',
                  subtitle: '$favoriteCount Salon',
                  onTap: () {
                    // TODO: Favorilerim sayfasına yönlendir
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Ayarlar',
                  subtitle: 'Uygulama Ayarları',
                  onTap: () {
                    // TODO: Ayarlar sayfasına yönlendir
                  },
                ),
                const SizedBox(height: 30),
                // --- Çıkış Yap ---
                TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                  label: Text(
                    'Çıkış Yap',
                    style: AppFonts.bodyLarge(color: Colors.red),
                  ),
                  onPressed: () async {
                    await authViewModel.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomePage()),
                            (route) => false,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textColorDark, size: 24),
        title: Text(title, style: AppFonts.bodyLarge(color: AppColors.textColorDark)),
        subtitle: Text(subtitle, style: AppFonts.bodySmall(color: AppColors.textColorLight)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textColorLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
