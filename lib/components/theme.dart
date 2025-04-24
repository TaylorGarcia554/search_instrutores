import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 0, 0, 0),
    secondary: Color.fromARGB(255, 33, 30, 183),
    surfaceContainer: Color.fromARGB(255, 221, 221, 221),
    surface: Color.fromARGB(255, 240, 240, 240),
    onPrimary: Color(0xff211951),
    onSecondary: Color.fromARGB(255, 243, 243, 243),
    onSurfaceVariant: Color.fromARGB(255, 0, 0, 0),
    onSurface: Color.fromARGB(255, 2, 2, 2),
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 233, 233, 233),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 255, 255, 255),
    secondary: Color(0xFFB71E3F),
    surfaceContainer: Color.fromARGB(255, 58, 57, 57),
    surface: Color.fromARGB(255, 0, 0, 0),
    onPrimary: Color(0xff211951),
    onSecondary: Color.fromARGB(255, 255, 255, 255),
    onSurfaceVariant: Color.fromARGB(255, 255, 255, 255),
    onSurface: Color.fromARGB(255, 255, 255, 255),
  ),
  scaffoldBackgroundColor: const Color(0xff232323),
  useMaterial3: true,
);
