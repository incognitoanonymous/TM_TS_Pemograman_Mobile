import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager with ChangeNotifier {
  // List untuk menyimpan Judul Buku yang dilike
  List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  // Saat class ini dibuat, langsung coba muat data dari HP
  FavoritesManager() {
    _loadFavorites();
  }

  // 1. Muat data dari memori HP
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Ambil data dengan kunci 'favoriteBooks', kalau kosong kasih []
    _favoriteIds = prefs.getStringList('favoriteBooks') ?? [];
    notifyListeners();
  }

  // 2. Fungsi Tombol Love (Tambah/Hapus)
  Future<void> toggleFavorite(String bookTitle) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_favoriteIds.contains(bookTitle)) {
      _favoriteIds.remove(bookTitle); // Hapus kalau sudah ada
    } else {
      _favoriteIds.add(bookTitle); // Tambah kalau belum ada
    }
    
    // Simpan perubahan ke memori HP (Permanen)
    await prefs.setStringList('favoriteBooks', _favoriteIds);
    notifyListeners();
  }

  // 3. Cek apakah buku ini favorit? (Untuk warna icon hati)
  bool isFavorite(String bookTitle) {
    return _favoriteIds.contains(bookTitle);
  }
}