import 'package:flutter/material.dart';

class AppFonts {
  static const String poppins = 'Poppins';
  static const String montserrat = 'Montserrat';

  // Mevcut stilleriniz...
  static TextStyle displayLarge({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle displayMedium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // Bu stil, UI kit'teki H6 Bold ile aynı olduğundan
  // isteğe bağlı olarak kaldırılabilir veya korunabilir.
  static TextStyle poppinsBold({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: fontSize ?? 16, // Varsayılan boyut 16
      fontWeight: FontWeight.w700, // Kalınlık 700 (bold)
      color: color,
    );
  }

  static TextStyle bodyLarge({Color? color}) {
    return TextStyle(
      fontFamily: montserrat,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontFamily: montserrat,
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return TextStyle(
      fontFamily: montserrat,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // --- YENİ EKLENEN POPPINS BAŞLIK STİLLERİ ---

  // H1 Styles - 34px
  static TextStyle h1Bold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 34,
      fontWeight: FontWeight.w700, // Bold
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h1SemiBold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 34,
      fontWeight: FontWeight.w600, // SemiBold
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h1Medium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 34,
      fontWeight: FontWeight.w500, // Medium
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h1Regular({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 34,
      fontWeight: FontWeight.w400, // Regular
      height: 1.5,
      color: color,
    );
  }

  // H2 Styles - 30px
  static TextStyle h2Bold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 30,
      fontWeight: FontWeight.w700,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h2SemiBold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 30,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h2Medium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 30,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h2Regular({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 30,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  // H3 Styles - 24px
  static TextStyle h3Bold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h3SemiBold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h3Medium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h3Regular({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  // H4 Styles - 20px
  static TextStyle h4Bold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h4SemiBold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h4Medium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h4Regular({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  // H5 Styles - 17px
  static TextStyle h5Bold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h5SemiBold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h5Medium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h5Regular({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 17,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  // H6 Styles - 16px
  static TextStyle h6Bold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h6SemiBold({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h6Medium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle h6Regular({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }
}