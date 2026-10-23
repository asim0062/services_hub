import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconName;
  final bool isActive;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.isActive,
    required this.sortOrder,
  });
  

  // 1. Firestore se data nikalne ke liye (fromMap)
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? 'Service',
      iconName: map['iconName'] ?? 'build',
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  // 2. Firestore mein data save karne ke liye (toMap)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  // 3. Data update karne ke liye (copyWith)
  CategoryModel copyWith({
    String? name,
    String? iconName,
    bool? isActive,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
    
  }
  
}
