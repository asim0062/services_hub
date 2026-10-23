import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicianModel {
  final String uid;
  final String name;
  final String categoryId;
  final String categoryName;
  final int experienceYears;
  final double hourlyRate;
  final String bio;
  final bool isVerified;
  final bool isAvailable;
  final double ratingAvg;
  final int ratingCount;
  final int completedJobs;
  final String photoUrl;

  TechnicianModel({
    required this.uid,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.experienceYears,
    required this.hourlyRate,
    required this.bio,
    required this.isVerified,
    required this.isAvailable,
    required this.ratingAvg,
    required this.ratingCount,
    required this.completedJobs,
    this.photoUrl = '',
  });

  factory TechnicianModel.fromMap(Map<String, dynamic> map, String id) {
    return TechnicianModel(
      uid: id,
      name: map['name'] ?? 'Unknown',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      experienceYears: map['experienceYears']?.toInt() ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      bio: map['bio'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      ratingAvg: (map['ratingAvg'] ?? 0).toDouble(),
      ratingCount: map['ratingCount']?.toInt() ?? 0,
      completedJobs: map['completedJobs']?.toInt() ?? 0,
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'completedJobs': completedJobs,
      'photoUrl': photoUrl,
    };
  }
}