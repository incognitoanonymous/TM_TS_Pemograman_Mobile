import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import file detail yang baru saja kamu buat
// Pastikan file 'book_details.dart' ada di folder yang sama (chapter15)
import 'book_details.dart'; 

// --- CLASS UTAMA CHAPTER 15 ---
class BooksApp extends StatefulWidget {
  const BooksApp({Key? key}) : super(key: key);

  @override
  _BooksAppState createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  List<BookModel>? booksListing; // Bernilai null saat awal (loading)
  String statusText = "Sedang memuat data...";
  
  // Controller untuk input pencarian
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi ambil data saat aplikasi dibuka
    fetchBooks("flutter development"); 
  }

  // --- LOGIC API (REAL DATA) ---
  Future<void> fetchBooks(String query) async {
    // ⚠️⚠️ PASTE API KEY KAMU DI SINI ⚠️⚠️
    const apiKey = "AIzaSyCcPPZrJi7iBqAjfXdcgIgPSRnYZ9ChGSA"; 
    
    // Encode query agar spasi berubah jadi %20 dsb
    final encodedQuery = Uri.encodeComponent(query);
    
    final url = Uri.parse(
        "https://www.googleapis.com/books/v1/volumes?key=$apiKey&q=$encodedQuery");

    // Set state loading sebelum request
    setState(() {
      booksListing = null;
      statusText = "Mencari buku '$query'...";
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['items'] != null) {
          final list = jsonResponse['items'] as List;
          setState(() {
            // Mapping JSON ke Object BookModel
            booksListing = list.map((e) => BookModel.fromJson(e)).toList();
          });
        } else {
          setState(() {
            statusText = "Buku tidak ditemukan.";
            booksListing = [];
          });
        }
      } else {
        setState(() {
          statusText = "Error Server: ${response.statusCode}";
          booksListing = [];
        });
      }
    } catch (e) {
      setState(() {
        statusText = "Gagal koneksi: $e";
        booksListing = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapter 15: Google Books API"),
        backgroundColor: Colors.orange[800],
      ),
      body: Column(
        children: [
          // --- KOLOM PENCARIAN (OPTIONAL) ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Cari Buku...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      fetchBooks(searchController.text);
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) fetchBooks(value);
              },
            ),
          ),
          
          // --- LIST BUKU ---
          Expanded(
            child: booksListing == null
                ? Center(child: CircularProgressIndicator()) // Spinner Loading
                : booksListing!.isEmpty
                    ? Center(child: Text(statusText)) // Teks jika kosong/error
                    : ListView.builder(
                        itemCount: booksListing!.length,
                        itemBuilder: (context, index) {
                          final book = booksListing![index];
                          return BookTile(book: book);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET TAMPILAN BUKU (TILE) ---
class BookTile extends StatelessWidget {
  final BookModel book;
  const BookTile({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        // Gambar Thumbnail di kiri
        leading: book.thumbnail != null
            ? Image.network(
                book.thumbnail!, 
                width: 50, 
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
              )
            : const Icon(Icons.book, size: 40, color: Colors.grey),
        
        // Judul Buku
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        
        // Penulis
        subtitle: Text(
          book.authors, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis
        ),
        
        // Tombol Panah Kanan
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        
        // --- NAVIGASI KE DETAIL ---
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Pindah ke halaman detail membawa data 'book'
              builder: (context) => BookDetailsPage(book: book),
            ),
          );
        },
      ),
    );
  }
}

// --- MODEL DATA (JSON PARSING) ---
class BookModel {
  final String title;
  final String authors;
  final String description; 
  final String publisher;   
  final String publishedDate; 
  final String? thumbnail;
  final String? buyLink;    
  final String? previewLink; 

  BookModel({
    required this.title,
    required this.authors,
    required this.description,
    required this.publisher,
    required this.publishedDate,
    this.thumbnail,
    this.buyLink,
    this.previewLink,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    final saleInfo = json['saleInfo']; 
    final accessInfo = json['accessInfo']; 

    // Helper untuk ambil gambar (terkadang ada di thumbnail, terkadang smallThumbnail)
    String? thumb;
    if (volumeInfo['imageLinks'] != null) {
      thumb = volumeInfo['imageLinks']['thumbnail'] ?? 
              volumeInfo['imageLinks']['smallThumbnail'];
    }

    // Helper untuk penulis (bisa lebih dari satu)
    String authorText = "Unknown Author";
    if (volumeInfo['authors'] != null) {
      authorText = (volumeInfo['authors'] as List).join(", ");
    }

    return BookModel(
      title: volumeInfo['title'] ?? "No Title",
      authors: authorText,
      description: volumeInfo['description'] ?? "Tidak ada deskripsi tersedia.",
      publisher: volumeInfo['publisher'] ?? "Penerbit Tidak Diketahui",
      publishedDate: volumeInfo['publishedDate'] ?? "-",
      thumbnail: thumb,
      // Ambil link jika ada
      buyLink: saleInfo != null ? saleInfo['buyLink'] : null,
      previewLink: accessInfo != null ? accessInfo['webReaderLink'] : null,
    );
  }
}