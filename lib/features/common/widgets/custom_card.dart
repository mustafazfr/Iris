import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart'; // AppColors sınıfını import etmeyi unutma

class CustomCard extends StatelessWidget {
  final Widget child; // Kartın içine gelecek içeriği alacak
  final double elevation; // Kartın gölge derinliği
  final double borderRadius; // Kartın köşe yuvarlaklığı
  final EdgeInsetsGeometry padding; // Kartın iç boşluğu
  final Color? color; // Kartın arka plan rengi
  final BoxConstraints? constraints; // Kartın boyut kısıtlamaları (opsiyonel)

  const CustomCard({
    super.key,
    required this.child, // İçerik zorunlu
    this.elevation = 15.0, // Varsayılan gölge değeri
    this.borderRadius = 20.0, // Varsayılan köşe yuvarlaklığı
    this.padding = const EdgeInsets.all(30.0), // Varsayılan iç boşluk
    this.color, // Varsayılan olarak null, AppColors.cardColor kullanılacak
    this.constraints, // Varsayılan olarak null
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: color ?? AppColors.cardColor, // Eğer renk verilmezse AppColors'tan al
      child: Container( // Card'ın içindeki padding ve constraints'i yönetmek için Container
        constraints: constraints,
        padding: padding,
        child: child, // İçeriği buraya yerleştiriyoruz
      ),
    );
  }
}