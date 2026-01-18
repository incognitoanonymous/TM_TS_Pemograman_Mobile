import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/dummy_data.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Tipe User: 0 = Umum (Public), 1 = Mahasiswa (Student)
  int _selectedUserType = 0; 

  // --- CONTROLLERS ---
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController(); // Read only
  
  // Khusus Umum
  final _nikController = TextEditingController();
  
  // Khusus Mahasiswa
  final _studentIdController = TextEditingController(); // NIM
  final _majorController = TextEditingController();
  final _yearController = TextEditingController();

  // State untuk mematikan tombol (Disable Button)
  bool _isFormValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    _nikController.dispose();
    _studentIdController.dispose();
    _majorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // === VALIDATION LOGIC: AGE CALCULATION ===
  void _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    
    // Cek apakah bulan/tanggal ulang tahun sudah lewat tahun ini
    if (today.month < birthDate.month || 
       (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    _ageController.text = age.toString();
    _checkFormValidity(); // Cek validasi ulang setelah umur terisi
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005), 
      firstDate: DateTime(1950),   
      lastDate: DateTime.now(),    
    );
    if (picked != null) {
      setState(() {
        // Format tampilan di Textfield: DD/MM/YYYY
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        _calculateAge(picked);
      });
    }
  }

  // === VALIDATION LOGIC: DISABLE BUTTON ===
  void _checkFormValidity() {
    // Cek apakah form valid tanpa memunculkan pesan error merah
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    // 1. KONVERSI TANGGAL: String (DD/MM/YYYY) -> DateTime
    DateTime? parsedDate;
    try {
      List<String> parts = _dobController.text.split('/');
      if (parts.length == 3) {
        // Format DateTime(Year, Month, Day)
        parsedDate = DateTime(
          int.parse(parts[2]), 
          int.parse(parts[1]), 
          int.parse(parts[0])
        );
      }
    } catch (e) {
      print("Error parsing date: $e");
    }

    // 2. SIMPAN DATA KE MODEL
    // Variable disesuaikan dengan models.dart yang baru
    User newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: _usernameController.text,
      password: _passwordController.text,
      name: _nameController.text,
      role: UserRole.member, // Default member
      
      // === BAGIAN INI DIPERBAIKI ===
      // Hapus userType, sesuaikan nama variabel dengan Model
      
      // Data Identitas & Umur
      dateOfBirth: parsedDate,          // Sesuai models.dart
      age: int.tryParse(_ageController.text),
      
      // Simpan field sesuai tipe yang dipilih, sisanya null
      nik: _selectedUserType == 0 ? _nikController.text : null,
      
      studentId: _selectedUserType == 1 ? _studentIdController.text : null,
      major: _selectedUserType == 1 ? _majorController.text : null,
      enrollYear: _selectedUserType == 1 ? _yearController.text : null, // Sesuai models.dart
    );

    // Tambahkan ke List (Simulasi Database)
    AppData.register(newUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.'), backgroundColor: Colors.green),
    );
    Navigator.pop(context); // Kembali ke Login agar bisa langsung login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Akun'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        // Error muncul realtime saat user mengetik/pindah kolom
        autovalidateMode: AutovalidateMode.onUserInteraction, 
        onChanged: _checkFormValidity, // Cek setiap ada perubahan data untuk tombol submit
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === PILIHAN TIPE USER ===
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text("Umum"), icon: Icon(Icons.person)),
                  ButtonSegment(value: 1, label: Text("Mahasiswa"), icon: Icon(Icons.school)),
                ],
                selected: {_selectedUserType},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedUserType = newSelection.first;
                    // Reset validasi saat ganti tab
                    _formKey.currentState?.reset(); 
                    _isFormValid = false;
                  });
                },
              ),
              const SizedBox(height: 20),

              // === SHARED FIELDS (Semua tipe user butuh ini) ===
              _buildTextField(
                controller: _nameController,
                label: "Nama Lengkap",
                icon: Icons.badge,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nama wajib diisi";
                  // Validasi: Tidak boleh mengandung angka
                  if (RegExp(r'[0-9]').hasMatch(value)) return "Nama tidak boleh mengandung angka";
                  return null;
                },
              ),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer( // Mencegah keyboard muncul
                        child: _buildTextField(
                          controller: _dobController,
                          label: "Tanggal Lahir",
                          icon: Icons.calendar_today,
                          validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: "Umur",
                      icon: Icons.timelapse,
                      readOnly: true, // Auto calculate only
                      validator: (v) => v!.isEmpty ? "..." : null,
                    ),
                  ),
                ],
              ),

              // === CONDITIONAL FIELDS (Tergantung Pilihan) ===
              if (_selectedUserType == 0) ...[
                // A) PUBLIC USER FIELDS
                _buildTextField(
                  controller: _nikController,
                  label: "NIK (16 Digit)",
                  icon: Icons.credit_card,
                  isNumber: true,
                  maxLength: 16,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "NIK wajib diisi";
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "NIK harus berupa angka";
                    if (value.length != 16) return "NIK harus tepat 16 digit";
                    return null;
                  },
                ),
              ] else ...[
                // B) STUDENT FIELDS
                _buildTextField(
                  controller: _studentIdController,
                  label: "NIM (Student ID)",
                  icon: Icons.card_membership,
                  isNumber: true,
                  validator: (v) => v!.isEmpty ? "NIM wajib diisi" : null,
                ),
                _buildTextField(
                  controller: _majorController,
                  label: "Jurusan / Prodi",
                  icon: Icons.book,
                  validator: (v) => v!.isEmpty ? "Jurusan wajib diisi" : null,
                ),
                _buildTextField(
                  controller: _yearController,
                  label: "Tahun Angkatan",
                  icon: Icons.date_range,
                  isNumber: true,
                  maxLength: 4,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Tahun wajib diisi";
                    int? year = int.tryParse(v);
                    if (year == null || year < 2000 || year > DateTime.now().year) {
                      return "Tahun tidak realistis";
                    }
                    return null;
                  },
                ),
              ],

              const Divider(height: 30, thickness: 1),

              // === LOGIN CREDENTIALS ===
              const Text("Buat Akun Login", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              
              _buildTextField(
                controller: _usernameController,
                label: "Username",
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? "Username wajib diisi" : null,
              ),
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => v!.isEmpty ? "Password wajib diisi" : null,
              ),

              const SizedBox(height: 20),

              // === SUBMIT BUTTON (DISABLED IF INVALID) ===
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Warna Emas jika Valid, Abu-abu jika Invalid
                    backgroundColor: _isFormValid ? AppColors.accentGold : Colors.grey[300],
                    foregroundColor: _isFormValid ? Colors.black : Colors.grey[500],
                  ),
                  // Jika tidak valid, onPressed null (tombol mati)
                  onPressed: _isFormValid ? _handleRegister : null, 
                  child: const Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget untuk Input Field ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool isNumber = false,
    bool isPassword = false,
    bool readOnly = false,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        readOnly: readOnly,
        obscureText: isPassword,
        // Keyboard angka jika isNumber = true
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        // Filter input hanya angka jika isNumber = true
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          counterText: "", // Menyembunyikan hitungan karakter agar rapi
          errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}