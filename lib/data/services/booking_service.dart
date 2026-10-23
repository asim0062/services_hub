import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Naya booking create karne ka function
  Future<void> createBooking({
    required String customerId,
    required String technicianId,
    required String categoryId,
    required String technicianName,
    required String categoryName,   
    required String date,
    required String timeSlot,
    required String address,
    required String problem,
    required double estimatedPrice,
  }) async {
    try {
      // 1. Booking Number generate karein (Jaise SH-1048)
      final bookingNo =
          'SH-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

      // 2. Nayi booking ka data tayar karein
      final bookingData = BookingModel(
        id: '', // Firestore khud ID dega
        bookingNo: bookingNo,
        customerId: customerId,
        technicianId: technicianId,
        categoryId: categoryId,
         technicianName: technicianName,
        categoryName: categoryName,
        date: date,
        timeSlot: timeSlot,
        address: address,
        problem: problem,
        status: 'pending', // Shuru mein pending hogi
        estimatedPrice: estimatedPrice,
        isPaid: false,
      );

      // 3. Firestore mein save karein
      await _firestore.collection('bookings').add(bookingData.toMap());
    } catch (e) {
      throw 'Error creating booking: $e';
    }
  }

  // Customer ki saari bookings mangwane ka function
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          // .orderBy('createdAt', descending: true) // Index ki zaroorat pad sakti hai, filhal hata rahe hain
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Error loading bookings: $e';
    }
  }
}
