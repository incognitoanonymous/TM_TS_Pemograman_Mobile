import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Kita import main_15.dart supaya file ini kenal dengan class 'BookModel'
import 'main_15.dart';

class BookDetailsPage extends StatelessWidget {
  final BookModel book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  // Fungsi untuk membuka browser (misal: link beli buku)
  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null) return;
    final Uri url = Uri.parse(urlString);

    // Menggunakan mode externalApplication agar membuka Chrome/Browser HP
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: Colors.orange[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Cover Besar
            Center(
              child: book.thumbnail != null
                  ? Container(
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(blurRadius: 10, color: Colors.black26)
                      ]),
                      child: Image.network(
                        book.thumbnail!,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.book,
                              size: 100, color: Colors.grey);
                        },
                      ),
                    )
                  : const Icon(Icons.book, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 2. Judul & Penulis
            Text(book.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("By: ${book.authors}",
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text("Publisher: ${book.publisher} (${book.publishedDate})",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),

            const Divider(height: 30, thickness: 1),

            // 3. Deskripsi
            const Text("Description:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(book.description,
                style: const TextStyle(fontSize: 16, height: 1.5)),

            const SizedBox(height: 30),

            // 4. Tombol Aksi (Preview & Beli)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (book.previewLink != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chrome_reader_mode),
                    label: const Text("Preview"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white),
                    onPressed: () => _launchUrl(book.previewLink),
                  ),
                if (book.buyLink != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text("Beli Buku"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    onPressed: () => _launchUrl(book.buyLink),
                  ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
