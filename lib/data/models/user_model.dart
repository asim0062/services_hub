import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String photoUrl;
  final bool isBlocked;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl = '',
    this.isBlocked = false,
    this.createdAt,
  });

  // 1. Firestore se data nikalne ke liye (fromMap)
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'customer',
      photoUrl: map['photoUrl'] ?? '',
      isBlocked: map['isBlocked'] ?? false,
      // Firestore ka Timestamp convert karke DateTime banaya
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // 2. Firestore mein data save karne ke liye (toMap)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'isBlocked': isBlocked,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // 3. Data update karne ke liye (copyWith)
  UserModel copyWith({
    String? name,
    String? phone,
    String? role,
    String? photoUrl,
    bool? isBlocked,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: this.email, // Email change nahi hoti
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: this.createdAt,
    );
  }
}