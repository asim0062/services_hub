import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:services_hub/data/models/technician_profile_model.dart';
import '../models/technician_model.dart';

class TechnicianService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Ek specific category ke verified aur available technicians mangwane ka function
  Future<List<TechnicianModel>> getTechniciansByCategory(
    String categoryId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('technicians')
          .where('categoryId', isEqualTo: categoryId)
          .where('isVerified', isEqualTo: true)
          // .where('isAvailable', isEqualTo: true) // Filhal ke liye available filter hata rahe hain taake test data dikhe
          .get();

      return snapshot.docs
          .map((doc) => TechnicianModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Error loading technicians: $e';
    }
  }

  // Admin ke liye: Technician ko approve ya reject karna
  Future<void> updateApprovalStatus({
    required String uid,
    required String status, // 'approved' ya 'rejected'
    String? rejectReason,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'approvalStatus': status,
        'isVerified': status == 'approved', // Approved hai toh verified true
        'rejectReason': rejectReason ?? '',
      };

      // Technicians collection update karein
      await _firestore.collection('technicians').doc(uid).update(updateData);
    } catch (e) {
      throw 'Error updating status: $e';
    }
  }

  // Admin ke liye: Pending technicians ki list mangwana
  Future<List<TechnicianProfileModel>> getPendingTechnicians() async {
    try {
      final snapshot = await _firestore
          .collection('technicians')
          .where('approvalStatus', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => TechnicianProfileModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Error loading pending technicians: $e';
    }
  }

  // 2. MAGIC FUNCTION: Test data database mein daalne ke liye
  Future<void> seedTechnicians() async {
    // Pehle categories fetch karein taake unki IDs mil sakein
    final categoriesSnapshot = await _firestore.collection('categories').get();

    // Plumber aur Electrician ki ID dhoondein
    String plumberId = '';
    String electricianId = '';

    for (var doc in categoriesSnapshot.docs) {
      if (doc['name'] == 'Plumber') plumberId = doc.id;
      if (doc['name'] == 'Electrician') electricianId = doc.id;
    }

    if (plumberId == '' || electricianId == '')
      return; // Agar categories nahi mili

    final List<Map<String, dynamic>> defaultTechnicians = [
      {
        'name': 'Ahmed Khan',
        'categoryId': electricianId,
        'categoryName': 'Electrician',
        'experienceYears': 6,
        'hourlyRate': 800.0,
        'bio': 'Licensed electrician for wiring, fans, and switchboards.',
        'isVerified': true,
        'isAvailable': true,
        'ratingAvg': 4.9,
        'ratingCount': 312,
        'completedJobs': 312,
        'photoUrl': '',
      },
      {
        'name': 'Usman Ali',
        'categoryId': electricianId,
        'categoryName': 'Electrician',
        'experienceYears': 3,
        'hourlyRate': 600.0,
        'bio': 'Expert in quick fixes and home appliance installation.',
        'isVerified': true,
        'isAvailable': true,
        'ratingAvg': 4.5,
        'ratingCount': 64,
        'completedJobs': 64,
        'photoUrl': '',
      },
      {
        'name': 'Bilal Sheikh',
        'categoryId': plumberId,
        'categoryName': 'Plumber',
        'experienceYears': 5,
        'hourlyRate': 700.0,
        'bio': 'Specialist in leakages and pipe fittings.',
        'isVerified': true,
        'isAvailable': true,
        'ratingAvg': 4.8,
        'ratingCount': 120,
        'completedJobs': 120,
        'photoUrl': '',
      },
    ];

    try {
      for (var tech in defaultTechnicians) {
        await _firestore.collection('technicians').add(tech);
      }
    } catch (e) {
      throw 'Error seeding technicians: $e';
    }
  }

  // Technician apni profile setup karega
  // Technician apni profile setup karega
  Future<void> setupTechnicianProfile({
    required String uid,
    required String name,
    required String categoryName, // <-- YEH NAYA PARAMETER HAI
    required List<String> categoryIds,
    required int experienceYears,
    required double hourlyRate,
    required String bio,
    required String cnicUrl,
  }) async {
    try {
      // Model banaya aur usme saara data dala
      final profile = TechnicianProfileModel(
        uid: uid,
        name: name, // <-- Yahan add kiya
        categoryName: categoryName, // <-- Yahan add kiya
        categoryIds: categoryIds,
        experienceYears: experienceYears,
        hourlyRate: hourlyRate,
        bio: bio,
        cnicUrl: cnicUrl,
        approvalStatus: 'pending',
        isVerified: false,
        isAvailable: false,
        ratingAvg: 0.0,
        ratingCount: 0,
        completedJobs: 0,
        createdAt: DateTime.now(),
      );

      // Ab Model ke toMap() function se data save karein
      await _firestore.collection('technicians').doc(uid).set(profile.toMap());

      // User document mein role update karein
      await _firestore.collection('users').doc(uid).update({
        'role': 'technician',
        'name': name,
      });
    } catch (e) {
      throw 'Error setting up profile: $e';
    }
  }

  // Admin ke liye: kisi bhi status ke technicians laana
  Future<List<TechnicianProfileModel>> getTechniciansByStatus(
    String status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('technicians')
          .where('approvalStatus', isEqualTo: status)
          .get();

      return snapshot.docs
          .map((doc) => TechnicianProfileModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Error loading $status technicians: $e';
    }
  }
}
