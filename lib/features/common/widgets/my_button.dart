import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart'; // app_fonts.dart dosyanızın yolu

class MyCustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const MyCustomButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5.0,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              // Butona basıldığında bir dalgalanma (ripple) rengi
              return Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
            }
            return null;
          },
        ),
        elevation: WidgetStateProperty.resolveWith<double?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return 10.0;
            }
            return 5.0;
          },
        ),
      ),
      child: Text(
        buttonText,
        // Kalın Poppins stilini kullanıyoruz ve metin rengini beyaz yapıyoruz
        style: AppFonts.poppinsBold(color: AppColors.textOnPrimary),
      ),
    );
  }
}