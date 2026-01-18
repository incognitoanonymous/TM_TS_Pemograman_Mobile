import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  // Status awal: Light Mode (False)
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Fungsi untuk mendapatkan Tema saat ini
  ThemeData get currentTheme {
    if (_isDarkMode) {
      // --- SETTINGAN DARK MODE ---
      return ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange, // Warna utama saat gelap
        scaffoldBackgroundColor: const Color(0xFF121212), // Hitam agak abu
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      );
    } else {
      // --- SETTINGAN LIGHT MODE ---
      return ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo, // Warna utama saat terang
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.white,
        useMaterial3: true,
      );
    }
  }

  // Fungsi untuk ubah status (Saklar Lampu)
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Kabari seluruh aplikasi kalau warna berubah!
  }
}