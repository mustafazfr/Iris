import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';

import 'package:denemeye_devam/features/appointments/screens/salon_detail_screen.dart'; // Yeni detay sayfamızı import ettik

class SalonCard extends StatelessWidget {
  final String salonId;
  final String name;
  final String rating;
  final List<String> services;
  final bool hasCampaign;
  final String? imagePath; // Opsiyonel hale getirdik, eğer görsel yoksa null olabilir

  const SalonCard({
    super.key,
    required this.salonId,
    required this.name,
    required this.rating,
    required this.services,
    this.hasCampaign = false,
    this.imagePath, // Artık varsayılan bir yol atamıyoruz, dışarıdan gelmezse null kalır.
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // <-- BURASI DEĞİŞTİ: Kartı InkWell ile sarmaladık
      onTap: () {
        // Tıklandığında SalonDetailScreen'a yönlendiriyoruz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalonDetailScreen(salonId: salonId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15), // Kartın köşe yuvarlaklığına uygun
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: AppColors.cardColor,
        child: Container( // Kartın içindeki padding'i buraya aldık
          width: 160, // Kart genişliği
          margin: const EdgeInsets.only(right: 15, bottom: 10), // Sağda boşluk, altta hafif gölge için
          padding: const EdgeInsets.all(12.0), // İç padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salon Resmi veya İkon
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: AppColors.backgroundColorDark,
                  height: 70,
                  width: double.infinity,
                  child: Center(
                    // Eğer imagePath varsa Image.asset göster, yoksa Icon göster
                    child: imagePath != null && imagePath!.isNotEmpty
                        ? Image.network(
                      imagePath!,
                      fit: BoxFit.cover,
                      height: 70,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.store, size: 40, color: AppColors.iconColor), // Hata durumunda ikon
                    )
                        : Icon(Icons.store, size: 40, color: AppColors.iconColor), // imagePath yoksa direkt ikon
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Salon Adı
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textColorDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Yıldızlar ve Puan
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.starColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textColorLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Kampanya Etiketi (Eğer varsa)
                  if (hasCampaign)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tagColorActive,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Kampanya',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Hizmet Etiketleri (Wrap ile alt alta akabilir)
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: services.map((service) => _buildServiceTag(service)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hizmet Etiketi Oluşturucu Fonksiyon
  Widget _buildServiceTag(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tagColorPassive,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service,
        style: TextStyle(
          color: AppColors.textColorDark,
          fontSize: 10,
        ),
      ),
    );
  }
}