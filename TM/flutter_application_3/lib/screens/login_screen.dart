import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/models.dart'; // Pastikan ini mengarah ke file model Anda (bisa models.dart atau user.dart)
import '../utils/constants.dart';
import '../widgets/custom_button.dart'; // Import CustomButton
import 'register_screen.dart';
import 'member/member_dashboard.dart';
import 'librarian/librarian_dashboard.dart';
import 'manager/manager_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil text input
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false; // Fitur lihat password

  void _handleLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong'),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }

    // Panggil logika login dari Dummy Data
    User? user = AppData.login(username, password);

    if (user != null) {
      // Login Berhasil -> Arahkan sesuai Role
      Widget nextScreen;
      switch (user.role) {
        case UserRole.member:
          nextScreen = const MemberDashboard();
          break;
        case UserRole.librarian:
          nextScreen = const LibrarianDashboard();
          break;
        case UserRole.manager:
          nextScreen = const ManagerDashboard();
          break;
      }

      // Gunakan pushReplacement agar user tidak bisa kembali ke halaman login dengan tombol Back
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => nextScreen)
      );
    } else {
      // Login Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Gagal! Username atau password salah.'),
          backgroundColor: AppColors.alertRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView( // Agar tidak error saat keyboard muncul
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- LOGO & JUDUL ---
              const Icon(
                Icons.local_library_rounded, 
                size: 80, 
                color: AppColors.primaryBlue
              ),
              const SizedBox(height: 16),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.primaryBlue
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sistem Manajemen Perpustakaan",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // --- INPUT FORM ---
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Sembunyikan text
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- TOMBOL LOGIN (Pakai CustomButton) ---
              CustomButton(
                text: 'MASUK (LOGIN)',
                onPressed: _handleLogin,
                color: AppColors.primaryBlue,
              ),

              const SizedBox(height: 16),

              // --- LINK KE REGISTER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => const RegisterScreen())
                      );
                    },
                    child: const Text(
                      'Daftar Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}