import 'package:flutter/material.dart';

// --- BAGIAN 1: Entry Point Chapter 9 ---
// Kita hapus 'void main()' karena file ini dipanggil dari main.dart utama
// Kita hapus 'MaterialApp' agar tombol BACK ke menu utama berfungsi otomatis

class BooksApp extends StatelessWidget {
  const BooksApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapter 9: Books Listing (Dummy)"),
        backgroundColor: Colors.blueAccent,
      ),
      body: BooksListing(),
    );
  }
}

// --- BAGIAN 2: Dummy Data ---
// Kita berikan tipe data yang jelas: List<Map<String, dynamic>>
List<Map<String, dynamic>> bookData() {
  return [
    {
      'title': 'Core Python Programming',
      'authors': ['Wesley J. Chun'],
      'image': 'assets/book_cover.png'
    },
    {
      'title': 'Java: The Complete Reference',
      'authors': ['Herbert Schildt'],
      'image': 'assets/book_cover.png'
    },
    {
      'title': 'Flutter in Action',
      'authors': ['Eric Windmill'],
      'image': 'assets/book_cover.png'
    },
    {
      'title': 'Clean Architecture',
      'authors': ['Robert C. Martin'],
      'image': 'assets/book_cover.png'
    }
  ];
}

// --- BAGIAN 3: Tampilan List ---
class BooksListing extends StatelessWidget {
  // Mengambil data dari fungsi di atas
  final List<Map<String, dynamic>> booksListing = bookData();

  BooksListing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: booksListing.length,
      itemBuilder: (context, index) {
        // Ambil data per baris
        final book = booksListing[index];
        final title = book['title'] as String;
        final authors = book['authors'] as List;
        final imagePath = book['image'] as String;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kolom Kiri: Judul & Penulis
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // Menggabungkan nama penulis dengan koma
                        'Author(s): ${authors.join(", ")}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // Kolom Kanan: Gambar Aset
                const SizedBox(width: 10), // Jarak antara teks dan gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    imagePath,
                    height: 80,
                    width: 60,
                    fit: BoxFit.cover,
                    // Penanganan Error jika gambar tidak ketemu
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 60,
                        color: Colors.grey[300],
                        child:
                            const Icon(Icons.broken_image, color: Colors.red),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
