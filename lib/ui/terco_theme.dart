import 'package:flutter/material.dart';

const Color tercoSeedColor = Color(0xFF1A365D);

ThemeData tercoLightTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: tercoSeedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}

ThemeData tercoDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: tercoSeedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
