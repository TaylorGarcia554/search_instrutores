import 'package:flutter/material.dart';

class Cor {
  static const Color background = Color(0xffEAE7E7);
  static const Color branco = Color(0xffFEFEFE);
  static const Color texto = Color(0xff000000);
  static const Color bordaBotao = Color.fromARGB(255, 0, 138, 37);
}

class AppColors extends ThemeExtension<AppColors> {
  final Color inputBackground;
  final Color inputBorder;
  final Color inputText;
  final Color chartColor;

  AppColors({
    required this.inputBackground,
    required this.inputBorder,
    required this.inputText,
    required this.chartColor
  });

  @override
  AppColors copyWith({
    Color? inputBackground,
    Color? inputBorder,
    Color? inputText,
    Color? chartColor,
  }) {
    return AppColors(
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputText: inputText ?? this.inputText,
      chartColor: chartColor ?? this.chartColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputText: Color.lerp(inputText, other.inputText, t)!,
      chartColor: Color.lerp(chartColor, other.chartColor, t)!,
    );
  }
}
