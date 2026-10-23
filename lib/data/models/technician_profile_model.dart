import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicianProfileModel {
  final String uid;
  final String name;
  final String categoryName;
  final List<String> categoryIds;
  final int experienceYears;
  final double hourlyRate;
  final String bio;
  final String cnicUrl;
  final String approvalStatus;
  final bool isVerified;
  final bool isAvailable;
  final double ratingAvg;
  final int ratingCount;
  final int completedJobs;
  final DateTime? createdAt;

  // ✅ NAYE FIELDS
  final String? city;
  final String? cnicFrontUrl;
  final String? cnicBackUrl;
  final String? rejectReason;

  TechnicianProfileModel({
    required this.uid,
    required this.name,
    required this.categoryName,
    required this.categoryIds,
    required this.experienceYears,
    required this.hourlyRate,
    required this.bio,
    required this.cnicUrl,
    required this.approvalStatus,
    required this.isVerified,
    required this.isAvailable,
    required this.ratingAvg,
    required this.ratingCount,
    required this.completedJobs,
    this.createdAt,
    // ✅ NAYE FIELDS (optional)
    this.city,
    this.cnicFrontUrl,
    this.cnicBackUrl,
    this.rejectReason,
  });

  factory TechnicianProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return TechnicianProfileModel(
      uid: id,
      name: map['name'] ?? 'Unknown',
      categoryName: map['categoryName'] ?? 'Service',
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      experienceYears: map['experienceYears']?.toInt() ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      bio: map['bio'] ?? '',
      cnicUrl: map['cnicUrl'] ?? '',
      approvalStatus: map['approvalStatus'] ?? 'pending',
      isVerified: map['isVerified'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      ratingAvg: (map['ratingAvg'] ?? 0).toDouble(),
      ratingCount: map['ratingCount']?.toInt() ?? 0,
      completedJobs: map['completedJobs']?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      // ✅ NAYE FIELDS
      city: map['city'] as String?,
      cnicFrontUrl: map['cnicFrontUrl'] as String?,
      cnicBackUrl: map['cnicBackUrl'] as String?,
      rejectReason: map['rejectReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryName': categoryName,
      'categoryIds': categoryIds,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'cnicUrl': cnicUrl,
      'approvalStatus': approvalStatus,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'completedJobs': completedJobs,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      // ✅ NAYE FIELDS (null-safe)
      if (city != null) 'city': city,
      if (cnicFrontUrl != null) 'cnicFrontUrl': cnicFrontUrl,
      if (cnicBackUrl != null) 'cnicBackUrl': cnicBackUrl,
      if (rejectReason != null) 'rejectReason': rejectReason,
    };
  }
}
