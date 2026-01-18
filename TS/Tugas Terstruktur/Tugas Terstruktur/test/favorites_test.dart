import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import sesuai nama project di pubspec.yaml
import 'package:my_book_app/chapter11/favorites_manager.dart'; 

void main() {
  group('Uji Coba Favorites Manager (Chapter 12)', () {
    
    test('Buku baru harusnya belum ada di favorit', () {
      SharedPreferences.setMockInitialValues({});
      final manager = FavoritesManager();
      expect(manager.isFavorite('Flutter Keren'), false);
    });

    test('Menambah favorit harus menyimpan data', () async {
      SharedPreferences.setMockInitialValues({});
      final manager = FavoritesManager();

      // Aksi: Like
      await manager.toggleFavorite('Dart Master');

      // Cek: Harusnya True
      expect(manager.isFavorite('Dart Master'), true);
    });

    // --- BAGIAN INI YANG KITA PERBAIKI ---
    test('Menghapus favorit harus menghilangkan data', () async {
      // 1. Reset Mock (Anggap HP kosong)
      SharedPreferences.setMockInitialValues({});
      final manager = FavoritesManager();

      // 2. Kita MASUKKAN dulu bukunya secara manual (Simulasi User nge-Like)
      await manager.toggleFavorite('Buku Jelek');
      // Pastikan bukunya benar-benar masuk dulu
      expect(manager.isFavorite('Buku Jelek'), true);

      // 3. Sekarang baru kita HAPUS (Simulasi User nge-Like lagi/Un-like)
      await manager.toggleFavorite('Buku Jelek');

      // 4. Verifikasi: Harusnya sekarang hilang (False)
      expect(manager.isFavorite('Buku Jelek'), false);
    });
  });
}