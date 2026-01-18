// --- ENUMS ---
enum UserRole { member, librarian, manager }
enum LoanStatus { requested, approved, returned, rejected }

// --- USER MODEL ---
class User {
  final String id;
  final String username;
  final String password;
  final String name;
  final UserRole role;

  // Added to support Feature 3: User Identity (Student vs Public)
  final String? nik;          // Public
  final String? studentId;    // Student
  final String? major;        // Student
  final String? enrollYear;   // Student
  final DateTime? dateOfBirth;
  final int? age;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.nik,
    this.studentId,
    this.major,
    this.enrollYear,
    this.dateOfBirth,
    this.age,
  });
}

// --- BOOK MODEL ---
class Book {
  String id;
  String title;
  String author;
  String category;
  String description;
  bool isAvailable;
  int year; // <--- FITUR BARU

  // Added to support Feature 6: Book Cover Image
  final String? coverImagePath; 

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    this.isAvailable = true,
    this.year = 2024,
    this.coverImagePath,
  });
}

// --- LOAN MODEL ---
class Loan {
  final String id;
  final String bookId;
  final String memberId;
  final DateTime requestDate;
  DateTime? loanDate;
  DateTime? dueDate;
  DateTime? returnDate;
  LoanStatus status;
  double fineAmount;

  Loan({
    required this.id,
    required this.bookId,
    required this.memberId,
    required this.requestDate,
    this.loanDate,
    this.dueDate,
    this.returnDate,
    this.status = LoanStatus.requested,
    this.fineAmount = 0.0,
  });
}

// --- NOTIFICATION MODEL (Required for Feature 4) ---
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final UserRole? targetRole; 
  final String? specificUserId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.targetRole,
    this.specificUserId,
  });
}