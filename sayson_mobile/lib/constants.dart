import 'package:flutter/material.dart';

// ===== API =====
// Lab 4 host link for Android emulator (backend on localhost:8000)
const String kBaseUrl = 'http://10.0.2.2:8000';

// ===== Styling =====
const double kPadding = 16.0;

const Color kLikeColor = Colors.redAccent;
const Color kCommentColor = Colors.blueAccent;

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6A4A20),
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF6A4A20),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
