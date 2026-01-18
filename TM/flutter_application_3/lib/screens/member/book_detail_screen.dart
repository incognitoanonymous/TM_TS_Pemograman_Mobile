import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../data/dummy_data.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  // === 1. FUNGSI MENAMPILKAN DIALOG KONFIRMASI ===
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib memilih tombol, tidak bisa klik luar
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Peminjaman"),
        content: Text(
          "Apakah Anda yakin ingin meminjam buku '${book.title}'?\n\n"
          "Durasi peminjaman adalah ${AppConstants.defaultLoanDurationDays} hari."
        ),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Tutup dialog saja
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          
          // Tombol Ya, Pinjam
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              // A. Proses Peminjaman di Data
              AppData.requestLoan(book);
              
              // B. Tutup Dialog
              Navigator.pop(ctx); 
              
              // C. Tampilkan Pesan Sukses
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Berhasil! Menunggu persetujuan petugas.'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                )
              );

              // D. Kembali ke Dashboard (Tutup halaman detail)
              Navigator.pop(context); 
            },
            child: const Text("Ya, Pinjam", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Buku"),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Buku
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  const SizedBox(height: 8),
                  Text("Penulis: ${book.author}", style: const TextStyle(fontSize: 16)),
                  Text("Kategori: ${book.category}", style: const TextStyle(fontSize: 16)),
                  Text("Tahun Terbit: ${book.year}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text(book.description, style: const TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Info Denda
            const Text("Informasi Peminjaman:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: AppColors.alertRed),
                title: const Text("Ketentuan Denda"),
                subtitle: Text("Jika terlambat mengembalikan, dikenakan denda sebesar Rp ${AppConstants.defaultFinePerDay} per hari."),
              ),
            ),

            const Spacer(),

            // === 2. UPDATE TOMBOL PINJAM ===
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: book.isAvailable ? AppColors.primaryBlue : Colors.grey
                ),
                // LOGIKA: 
                // Jika Available -> Tampilkan Dialog Konfirmasi
                // Jika Tidak -> Tombol Mati (null)
                onPressed: book.isAvailable 
                  ? () => _showConfirmationDialog(context) 
                  : null,
                
                child: Text(
                  book.isAvailable ? "PINJAM BUKU INI" : "SEDANG DIPINJAM", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}