import 'package:flutter/material.dart';
import 'package:search_instrutores/utils/cor.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
      primary: Color(0xff3A5BA0),
      secondary: Color.fromRGBO(19, 14, 47, 1),
      primaryContainer: Color(0xFF241E45),
      surfaceContainer: Color.fromARGB(255, 221, 221, 221),
      surface: Color.fromRGBO(255, 240, 240, 240),
      onPrimary: Color(0xff3A5BA0),
      onSecondary: Color(0xff2C4373),
      onSurfaceVariant: Color.fromARGB(255, 0, 0, 0),
      onSurface: Color.fromARGB(255, 2, 2, 2),
      outlineVariant: Color.fromARGB(255, 18, 18, 18)),
  cardColor: const Color(0xffD9D9D9),
  extensions: [
    // Adiciona a extensão de tema personalizada
    AppColors(
      inputBackground:Colors.white,
      inputBorder: const Color(0xFF000000),
      inputText: const Color(0xFF000000),
      chartColor: const Color(0xff3A5BA0),
    ),
  ],
  scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
      primary: Color(0xff130E2F),
      secondary: Color.fromRGBO(19, 14, 47, 1),
      surfaceContainer: Color.fromARGB(255, 58, 57, 57),
      surface: Color(0xff1B1B29),
      onPrimary: Color(0xFF130E2F),
      onSecondary: Color(0xff241E45),
      onSurfaceVariant: Color.fromARGB(255, 255, 255, 255),
      onSurface: Color.fromARGB(255, 255, 255, 255),
      outlineVariant: Color(0xffD9D9D9)),
  cardColor: const Color(0xff1B1B29),
  extensions: [
    // Adiciona a extensão de tema personalizada
    AppColors(
      inputBackground: const Color(0xFF1F2937),
      inputBorder: const Color(0xFF374151),
      inputText: const Color(0xFF000000),
      chartColor: const Color(0xff3A5BA0)
    ),
  ],
  scaffoldBackgroundColor: const Color(0xff232323),
  useMaterial3: true,
);
