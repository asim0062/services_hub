import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String bookingNo;
  final String customerId;
  final String technicianId;
  final String technicianName; 
  final String categoryId;
  final String categoryName;   // Category ka naam (e.g., Plumber)
  final String date;
  final String timeSlot;
  final String address;
  final String problem;
  final String status;
  final double estimatedPrice;
  final bool isPaid;

  BookingModel({
    required this.id,
    required this.bookingNo,
    required this.customerId,
    required this.technicianId,
    required this.technicianName,
    required this.categoryId,
    required this.categoryName,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.problem,
    required this.status,
    required this.estimatedPrice,
    required this.isPaid,
  });

  // Firestore se data nikalne ke liye
  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      bookingNo: map['bookingNo'] ?? '',
      customerId: map['customerId'] ?? '',
      technicianId: map['technicianId'] ?? '',
      technicianName: map['technicianName'] ?? 'Unknown', // Naya
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? 'Service',    // Naya
      date: map['date'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      address: map['address'] ?? '',
      problem: map['problem'] ?? '',
      status: map['status'] ?? 'pending',
      estimatedPrice: (map['estimatedPrice'] ?? 0).toDouble(),
      isPaid: map['isPaid'] ?? false,
    );
  }

  // Firestore mein data save karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'bookingNo': bookingNo,
      'customerId': customerId,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'date': date,
      'timeSlot': timeSlot,
      'address': address,
      'problem': problem,
      'status': status,
      'estimatedPrice': estimatedPrice,
      'isPaid': isPaid,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Data update karne ke liye
  BookingModel copyWith({
    String? status,
    bool? isPaid,
  }) {
    return BookingModel(
      id: this.id,
      bookingNo: this.bookingNo,
      customerId: this.customerId,
      technicianId: this.technicianId,
      technicianName: this.technicianName,
      categoryId: this.categoryId,
      categoryName: this.categoryName,
      date: this.date,
      timeSlot: this.timeSlot,
      address: this.address,
      problem: this.problem,
      status: status ?? this.status,
      estimatedPrice: this.estimatedPrice,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}