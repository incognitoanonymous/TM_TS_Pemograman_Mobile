import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';
// Import constants sudah dihapus karena tidak dipakai
import '../login_screen.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  
  void _logout() {
    AppData.logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
  }

  // === FITUR: Tambah Librarian ===
  void _showAddLibrarianDialog() {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Librarian Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nama Petugas")),
            TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && userCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
                // Buat User dengan role Librarian
                AppData.register(User(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  username: userCtrl.text,
                  password: passCtrl.text,
                  role: UserRole.librarian, // <--- OTOMATIS LIBRARIAN
                ));
                setState(() {}); // Refresh list
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Librarian berhasil ditambahkan")));
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ringkasan Perpustakaan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                _statCard("Total Buku", AppData.books.length.toString(), Colors.blue),
                _statCard("Total Member", AppData.users.where((u) => u.role == UserRole.member).length.toString(), Colors.orange),
              ],
            ),
            Row(
              children: [
                // Hitung Librarian
                _statCard("Total Librarian", AppData.users.where((u) => u.role == UserRole.librarian).length.toString(), Colors.purple),
                _statCard("Total Denda (Rp)", _calculateTotalFines(), Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            
            // List Semua Staff (Librarian & Manager)
            const Text("Daftar Staff (Librarian)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...AppData.users.where((u) => u.role == UserRole.librarian).map((u) => ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
              title: Text(u.name),
              subtitle: Text("User: ${u.username}"),
            )),

            const SizedBox(height: 20),
            const Text("Daftar Member Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...AppData.users.where((u) => u.role == UserRole.member).take(5).map((u) => ListTile(
              leading: const Icon(Icons.person),
              title: Text(u.name),
              subtitle: Text(u.username),
            )),
          ],
        ),
      ),
      // === TOMBOL TAMBAH LIBRARIAN ===
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLibrarianDialog,
        backgroundColor: Colors.black87,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Librarian", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  String _calculateTotalFines() {
    double total = 0;
    for (var l in AppData.loans) {
      total += l.fineAmount;
    }
    return total.toStringAsFixed(0);
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1), // Menggunakan withValues agar support Flutter terbaru
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}