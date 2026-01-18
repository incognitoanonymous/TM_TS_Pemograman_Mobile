import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../login_screen.dart';

class LibrarianDashboard extends StatefulWidget {
  const LibrarianDashboard({super.key});

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  int _selectedIndex = 0;

  void _logout() {
    AppData.logout();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildBookManagement(),
      _buildLoanRequests(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Librarian Panel'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        selectedItemColor: AppColors.primaryBlue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Kelola Buku'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: 'Peminjaman'),
        ],
      ),
      // Tombol Tambah Buku hanya muncul di Tab 0
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Tambah Buku", style: TextStyle(color: Colors.white)),
              onPressed: () => _showBookDialog(context, null),
            )
          : null,
    );
  }

  // --- TAB 1: MANAJEMEN BUKU ---
  Widget _buildBookManagement() {
    return ListView.builder(
      itemCount: AppData.books.length,
      itemBuilder: (context, index) {
        final book = AppData.books[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Penulis: ${book.author} | Tahun: ${book.year}"), // Menampilkan tahun
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showBookDialog(context, book)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Konfirmasi hapus sederhana
                    AppData.deleteBook(book.id);
                    _refresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Buku dihapus")));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // === FORM INPUT BUKU (TERMASUK TAHUN) ===
  void _showBookDialog(BuildContext context, Book? book) {
    final titleCtrl = TextEditingController(text: book?.title ?? '');
    final authorCtrl = TextEditingController(text: book?.author ?? '');
    final catCtrl = TextEditingController(text: book?.category ?? '');
    
    // Controller untuk Tahun (Konversi int ke String jika edit, kosong jika baru)
    final yearCtrl = TextEditingController(text: book?.year.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(book == null ? 'Tambah Buku Baru' : 'Edit Buku'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl, 
                decoration: const InputDecoration(labelText: 'Judul Buku', icon: Icon(Icons.book)),
              ),
              TextField(
                controller: authorCtrl, 
                decoration: const InputDecoration(labelText: 'Penulis', icon: Icon(Icons.person)),
              ),
              TextField(
                controller: catCtrl, 
                decoration: const InputDecoration(labelText: 'Kategori', icon: Icon(Icons.category)),
              ),
              // Input Tahun Terbit
              TextField(
                controller: yearCtrl, 
                decoration: const InputDecoration(labelText: 'Tahun Terbit', icon: Icon(Icons.calendar_today)),
                keyboardType: TextInputType.number, // Keyboard angka
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              if (titleCtrl.text.isEmpty) return;

              // Ambil tahun dari input, default ke 2024 jika kosong/error
              int inputYear = int.tryParse(yearCtrl.text) ?? 2024;

              if (book == null) {
                // Tambah Buku Baru
                AppData.addBook(Book(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text,
                  author: authorCtrl.text,
                  category: catCtrl.text,
                  description: 'Deskripsi belum diisi.',
                  year: inputYear, // Simpan Tahun
                ));
              } else {
                // Edit Buku Lama
                book.title = titleCtrl.text;
                book.author = authorCtrl.text;
                book.category = catCtrl.text;
                book.year = inputYear; // Update Tahun
                AppData.updateBook(book);
              }
              Navigator.pop(ctx);
              _refresh();
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- TAB 2: APPROVAL PEMINJAMAN ---
  Widget _buildLoanRequests() {
    final activeLoans = AppData.loans.where((l) => l.status != LoanStatus.returned).toList();
    activeLoans.sort((a, b) => a.status == LoanStatus.requested ? -1 : 1);

    if (activeLoans.isEmpty) return const Center(child: Text("Tidak ada aktivitas peminjaman aktif"));

    return ListView.builder(
      itemCount: activeLoans.length,
      itemBuilder: (context, index) {
        final loan = activeLoans[index];
        final book = AppData.books.firstWhere((b) => b.id == loan.bookId, orElse: () => Book(id: '0', title: 'Unknown', author: '-', category: '-', description: '-', year: 0));
        final user = AppData.users.firstWhere((u) => u.id == loan.memberId);

        return Card(
          color: loan.status == LoanStatus.requested ? Colors.yellow[50] : Colors.white,
          child: ListTile(
            title: Text("${book.title} (Member: ${user.name})"),
            subtitle: Text("Status: ${loan.status.name.toUpperCase()}"),
            trailing: _buildActionButtons(loan),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(Loan loan) {
    if (loan.status == LoanStatus.requested) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
            tooltip: "Approve",
            onPressed: () {
              AppData.approveLoan(loan);
              _refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
            tooltip: "Reject",
            onPressed: () {
              AppData.rejectLoan(loan);
              _refresh();
            },
          ),
        ],
      );
    } else if (loan.status == LoanStatus.approved) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
        onPressed: () {
          AppData.returnBook(loan);
          _refresh();
          if (loan.fineAmount > 0) {
            _showFineDialog(loan.fineAmount);
          }
        },
        child: const Text("Terima Kembali", style: TextStyle(color: Colors.white, fontSize: 10)),
      );
    }
    return const SizedBox();
  }

  void _showFineDialog(double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Keterlambatan!"),
        content: Text("Member terkena denda sebesar Rp $amount"),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }
}