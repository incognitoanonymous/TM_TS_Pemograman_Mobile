import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Wajib ada untuk Chapter 10 & 11

// --- IMPORT SEMUA CHAPTER ---
// Pastikan struktur folder kamu sudah sesuai:
import 'chapter10/theme_manager.dart'; // Logic Tema (Chapter 10)
import 'chapter11/favorites_manager.dart'; // Logic Favorit (Chapter 11)
import 'chapter09/main_09.dart' as ch9; // Alias ch9
import 'chapter15/main_15.dart' as ch15; // Alias ch15

void main() {
  runApp(
    // Kita pakai MultiProvider karena sekarang ada 2 fitur logic (Tema & Favorit)
    MultiProvider(
      providers: [
        // 1. Provider untuk Tema (Chapter 10)
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        // 2. Provider untuk Favorit (Chapter 11)
        ChangeNotifierProvider(create: (_) => FavoritesManager()),
      ],
      child: const MasterApp(),
    ),
  );
}

class MasterApp extends StatelessWidget {
  const MasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data tema agar aplikasi bisa berubah warna
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tugas Flutter Lengkap',

      // Gunakan tema dari ThemeNotifier (Dark/Light)
      theme: themeNotifier.currentTheme,

      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita butuh ini untuk akses tombol ganti tema
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Tugas"),
        centerTitle: true,
        actions: [
          // --- TOMBOL GANTI TEMA (CHAPTER 10) ---
          IconButton(
            tooltip: "Ganti Tema Gelap/Terang",
            icon: Icon(
                themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Silakan Pilih Chapter:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // --- TOMBOL KE CHAPTER 9 ---
            _buildChapterButton(
              context,
              title: "Chapter 9",
              subtitle: "UI List & Dummy Data",
              icon: Icons.format_list_bulleted,
              color: Colors.blue,
              destination: const ch9.BooksApp(),
            ),

            const SizedBox(height: 16), // Jarak antar tombol

            // --- TOMBOL KE CHAPTER 15 ---
            _buildChapterButton(
              context,
              title: "Chapter 15",
              subtitle: "Google Books API + Detail Page",
              icon: Icons.cloud_download,
              color: Colors.orange,
              destination: const ch15.BooksApp(),
            ),

            const SizedBox(height: 20),

            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk bikin tombol menu rapi
  Widget _buildChapterButton(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required Widget destination}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }
}
