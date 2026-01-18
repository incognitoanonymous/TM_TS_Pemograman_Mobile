import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../login_screen.dart';
import 'book_detail_screen.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _logout() {
    AppData.logout();
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => const LoginScreen()), 
      (route) => false
    );
  }

  // Fungsi refresh untuk update tampilan jika data berubah
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${AppData.currentUser?.name ?? "Member"}'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Refresh Manual (Berguna jika data dirasa belum muncul)
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: _refresh,
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: "Katalog Buku"),
            Tab(icon: Icon(Icons.history), text: "Peminjaman Saya"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookCatalog(),
          _buildMyLoans(),
        ],
      ),
    );
  }

  // === TAB 1: KATALOG BUKU ===
  Widget _buildBookCatalog() {
    // Ambil data langsung dari sumber utama
    final books = AppData.books;

    if (books.isEmpty) {
      return const Center(child: Text("Belum ada buku di perpustakaan"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 80,
              color: book.isAvailable ? Colors.blue[100] : Colors.grey[300],
              child: Icon(Icons.book, color: book.isAvailable ? AppColors.primaryBlue : Colors.grey),
            ),
            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${book.author} (${book.year})"),
                const SizedBox(height: 4),
                // Label Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: book.isAvailable ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    book.isAvailable ? "Tersedia" : "Dipinjam",
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold, 
                      color: book.isAvailable ? Colors.green[800] : Colors.red[800]
                    ),
                  ),
                )
              ],
            ),
            isThreeLine: true,
            
            // Klik untuk ke Detail
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
              ).then((_) => _refresh()); // Refresh saat kembali
            },
            
            // Tombol Pinjam Cepat (Arahkan ke Detail saja agar konsisten)
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        );
      },
    );
  }

  // === TAB 2: PEMINJAMAN SAYA ===
  Widget _buildMyLoans() {
    final myLoans = AppData.loans.where((l) => l.memberId == AppData.currentUser?.id).toList();

    if (myLoans.isEmpty) {
      return const Center(child: Text("Belum ada riwayat peminjaman"));
    }

    return ListView.builder(
      itemCount: myLoans.length,
      itemBuilder: (context, index) {
        final loan = myLoans[index];
        // Cari buku berdasarkan ID (Handle safe code jika buku dihapus)
        final book = AppData.books.firstWhere(
          (b) => b.id == loan.bookId, 
          orElse: () => Book(id: '0', title: 'Buku Dihapus', author: '-', category: '-', description: '-', year: 0)
        );

        Color statusColor = Colors.grey;
        if (loan.status == LoanStatus.approved) statusColor = Colors.green;
        if (loan.status == LoanStatus.rejected) statusColor = Colors.red;
        if (loan.status == LoanStatus.requested) statusColor = Colors.orange;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(book.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${loan.status.name.toUpperCase()}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                if (loan.dueDate != null) Text("Jatuh Tempo: ${loan.dueDate!.day}/${loan.dueDate!.month}/${loan.dueDate!.year}"),
              ],
            ),
          ),
        );
      },
    );
  }
}