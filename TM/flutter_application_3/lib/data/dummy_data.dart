import '../models/models.dart';
import '../utils/constants.dart';

class AppData {
  // --- SINGLETON DATA STORAGE (IN MEMORY) ---
  
  static User? currentUser; // Session

  // 1. Users List (Data Diperbarui Sesuai Model Baru)
  static List<User> users = [
    // --- ADMIN / MANAGER ---
    User(
      id: 'u1', 
      username: 'admin', 
      password: '123', 
      name: 'Super Manager', 
      role: UserRole.manager,
      age: 35,
    ),
    
    // --- LIBRARIAN ---
    User(
      id: 'u2', 
      username: 'lib', 
      password: '123', 
      name: 'Pak Pustakawan', 
      role: UserRole.librarian,
      age: 40,
    ),
    
    // --- MEMBER 1: TIPE UMUM (PUBLIC) ---
    User(
      id: 'u3', 
      username: 'member', 
      password: '123', 
      name: 'Budi Pembaca', 
      role: UserRole.member,
      // Data Identitas
      nik: '3175000000000001', 
      dateOfBirth: DateTime(1995, 5, 20),
      age: 29,
    ),

    // --- MEMBER 2: TIPE MAHASISWA (STUDENT) ---
    User(
      id: 'u4', 
      username: 'siti', 
      password: '123', 
      name: 'Siti Rajin', 
      role: UserRole.member,
      // Data Akademik
      studentId: '20248899', 
      major: 'Ilmu Komputer',
      enrollYear: '2023',
      dateOfBirth: DateTime(2003, 8, 17),
      age: 21,
    ),
  ];

  // 2. Books List (Data Lengkap dengan Status)
  static List<Book> books = [
    // --- Teknologi ---
    Book(
      id: 'b1', 
      title: 'Belajar Flutter', 
      author: 'Google Team', 
      category: 'Teknologi', 
      description: 'Panduan lengkap membuat aplikasi mobile dengan Flutter.',
      year: 2023,
      isAvailable: true, // Sudah dikembalikan oleh Budi
    ),
    Book(
      id: 'b2', 
      title: 'Clean Code', 
      author: 'Robert C Martin', 
      category: 'Teknologi', 
      description: 'Panduan menulis kode yang rapi, mudah dibaca, dan maintainable.',
      year: 2008,
      isAvailable: false, // Sedang dipinjam Budi
    ),
    // --- Novel ---
    Book(
      id: 'b3', 
      title: 'Laskar Pelangi', 
      author: 'Andrea Hirata', 
      category: 'Novel', 
      description: 'Kisah inspiratif perjuangan anak-anak Belitung mengejar mimpi.',
      year: 2005,
      isAvailable: false, // Sedang direquest Siti
    ),
    Book(
      id: 'b4', 
      title: 'Harry Potter', 
      author: 'J.K. Rowling', 
      category: 'Novel', 
      description: 'Petualangan penyihir muda di Hogwarts.',
      year: 1997,
      isAvailable: true,
    ),
    // --- Psikologi/Sejarah ---
    Book(
      id: 'b5', 
      title: 'Bumi Manusia', 
      author: 'Pramoedya Ananta Toer', 
      category: 'Sejarah', 
      description: 'Roman sejarah pergerakan nasional.',
      year: 1980,
      isAvailable: true,
    ),
    Book(
      id: 'b6', 
      title: 'Atomic Habits', 
      author: 'James Clear', 
      category: 'Psikologi', 
      description: 'Cara mudah membangun kebiasaan baik.',
      year: 2018,
      isAvailable: true,
    ),
    Book(
      id: 'b7', 
      title: 'Filosofi Teras', 
      author: 'Henry Manampiring', 
      category: 'Psikologi', 
      description: 'Penerapan filsafat Stoa.',
      year: 2019,
      isAvailable: true,
    ),
  ];

  // 3. Loans List (Skenario Peminjaman)
  static List<Loan> loans = [
    // Skenario 1: Sudah dikembalikan (Returned) - Budi & Flutter
    Loan(
      id: 'l1',
      bookId: 'b1',
      memberId: 'u3', // Budi
      requestDate: DateTime.now().subtract(const Duration(days: 10)),
      loanDate: DateTime.now().subtract(const Duration(days: 9)),
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      returnDate: DateTime.now().subtract(const Duration(days: 3)),
      status: LoanStatus.returned,
    ),
    // Skenario 2: Sedang Dipinjam (Approved) - Budi & Clean Code
    Loan(
      id: 'l2',
      bookId: 'b2',
      memberId: 'u3', // Budi
      requestDate: DateTime.now().subtract(const Duration(days: 2)),
      loanDate: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 6)),
      status: LoanStatus.approved,
    ),
    // Skenario 3: Menunggu Persetujuan (Requested) - Siti & Laskar Pelangi
    Loan(
      id: 'l3',
      bookId: 'b3',
      memberId: 'u4', // Siti
      requestDate: DateTime.now(),
      status: LoanStatus.requested,
    ),
  ];

  // --- LOGIC METHODS ---

  // AUTH
  static User? login(String username, String password) {
    try {
      final user = users.firstWhere(
        (u) => u.username == username && u.password == password
      );
      currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  static void logout() {
    currentUser = null;
  }

  static void register(User newUser) {
    users.add(newUser);
  }

  // BOOK MANAGEMENT
  static void addBook(Book book) {
    books.add(book);
  }

  static void updateBook(Book updatedBook) {
    int index = books.indexWhere((b) => b.id == updatedBook.id);
    if (index != -1) {
      books[index] = updatedBook;
    }
  }

  static void deleteBook(String id) {
    books.removeWhere((b) => b.id == id);
  }

  // LOAN MANAGEMENT
  
  // Helper: Ambil pinjaman user yang sedang login saja
  static List<Loan> getMyLoans() {
    if (currentUser == null) return [];
    // Urutkan dari yang terbaru (requestDate descending)
    List<Loan> myLoans = loans.where((loan) => loan.memberId == currentUser!.id).toList();
    myLoans.sort((a, b) => b.requestDate.compareTo(a.requestDate));
    return myLoans;
  }

  static void requestLoan(Book book) {
    if (currentUser == null) return;
    
    // Create new loan request
    loans.add(Loan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: book.id,
      memberId: currentUser!.id,
      requestDate: DateTime.now(),
      status: LoanStatus.requested,
    ));

    // Mark book as unavailable temporarily
    book.isAvailable = false;
  }

  static void approveLoan(Loan loan) {
    loan.status = LoanStatus.approved;
    loan.loanDate = DateTime.now();
    // Simulasi jatuh tempo 7 hari ke depan
    loan.dueDate = DateTime.now().add(const Duration(days: AppConstants.defaultLoanDurationDays)); 
  }

  static void rejectLoan(Loan loan) {
    loan.status = LoanStatus.rejected;
    // Kembalikan status buku jadi available
    try {
      Book book = books.firstWhere((b) => b.id == loan.bookId);
      book.isAvailable = true;
    } catch (e) {
      print("Error: Book not found");
    }
  }

  static void returnBook(Loan loan) {
    loan.returnDate = DateTime.now();
    loan.status = LoanStatus.returned;

    // Hitung Denda
    if (loan.dueDate != null && loan.returnDate!.isAfter(loan.dueDate!)) {
      int lateDays = loan.returnDate!.difference(loan.dueDate!).inDays;
      if (lateDays > 0) {
        loan.fineAmount = lateDays * AppConstants.defaultFinePerDay;
      }
    }

    // Buku tersedia kembali
    try {
      Book book = books.firstWhere((b) => b.id == loan.bookId);
      book.isAvailable = true;
    } catch (e) {
      print("Error: Book not found");
    }
  }
}