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
    // Profil ekranının ihtiyaç duyduğu tüm ViewModel'ları dinle
    return Consumer3<AuthViewModel, AppointmentsViewModel, FavoritesViewModel>(
      builder: (context, authViewModel, appointmentsViewModel, favoritesViewModel, child) {
        // ViewModel'lardan verileri alalım
        final user = authViewModel.user;
        final appointmentCount = appointmentsViewModel.allAppointments.length;
        final favoriteCount = favoritesViewModel.favoriteSaloons.length;

        // Supabase'den gelen kullanıcı adı ve soyadını alalım
        // Kayıt sırasında 'data' içine eklediğimiz 'name' ve 'surname' alanlarına ulaşıyoruz
        final String userName = user?.userMetadata?['name'] ?? 'Misafir';
        final String userSurname = user?.userMetadata?['surname'] ?? 'Kullanıcı';
        final String fullName = '$userName $userSurname';

        return Scaffold(
          backgroundColor: AppColors.backgroundColorLight,
          appBar: AppBar(
            title: Text(
              'Profilim',
              style: AppFonts.h5Bold(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
          ),
          body: Consumer3<AuthViewModel, AppointmentsViewModel, FavoritesViewModel>(
            builder: (context, authViewModel, appointmentsViewModel, favoritesViewModel, child) {
              // ViewModel'lardan verileri al
              final user = authViewModel.user;
              final appointmentCount = appointmentsViewModel.allAppointments.length;
              final favoriteCount = favoritesViewModel.favoriteSaloons.length;
              final String userName = user?.userMetadata?['name'] ?? 'Misafir';
              final String userSurname = user?.userMetadata?['surname'] ?? 'Kullanıcı';
              final String fullName = '$userName $userSurname';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                            border: Border.all(color: Colors.white, width: 5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 85,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        fullName,
                        style: AppFonts.poppinsBold(fontSize: 26, color: AppColors.textColorDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? 'E-posta adresi yok',
                        style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 220,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil Düzenleme özelliği yakında eklenecektir.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            foregroundColor: AppColors.textOnPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 6,
                          ),
                          child: Text(
                            'Profili düzenle',
                            style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textOnPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Card(
                        color: AppColors.cardColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildStatRow(icon: Icons.calendar_today, text: 'Toplam randevu sayısı: $appointmentCount'),
                              const SizedBox(height: 12),
                              _buildStatRow(icon: Icons.favorite, text: 'Favori salon sayısı: $favoriteCount'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ======================================================
                      // YENİ EKLENEN ÇIKIŞ YAP BUTONU VE MANTIĞI
                      // ======================================================
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          label: Text(
                            'Çıkış Yap',
                            style: AppFonts.bodyLarge(color: Colors.redAccent),
                          ),
                          onPressed: () async {
                            // Önce ViewModel üzerinden çıkış işlemini bekle
                            await authViewModel.signOut();

                            // İşlem bittikten sonra, UI katmanında yönlendirmeyi yap.
                            // Bu, kodun sorumluluklarını net bir şekilde ayırır.
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const HomePage()),
                                    (route) => false, // Tüm geçmişi temizle
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.red.withOpacity(0.2)),
                            ),
                            backgroundColor: Colors.red.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // İstatistik satırlarını daha şık göstermek için küçük bir helper metot
  Widget _buildStatRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppFonts.bodyMedium(color: AppColors.textColorDark),
        ),
      ],
    );
  }
}