import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Categories mangwane ka function
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw 'Error loading categories: $e';
    }
  }

  // Delete
  Future<void> deleteDuplicates() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      final Map<String, List<String>> groupedDocs = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? 'Unknown';

        if (!groupedDocs.containsKey(name)) {
          groupedDocs[name] = [];
        }
        groupedDocs[name]!.add(doc.id);
      }

      for (var ids in groupedDocs.values) {
        if (ids.length > 1) {
          for (int i = 1; i < ids.length; i++) {
            await _firestore.collection('categories').doc(ids[i]).delete();
          }
        }
      }
    } catch (e) {
      throw 'Error deleting duplicates: $e';
    }
  }

  // 2. MAGIC FUNCTION: Ek click mein saara data database mein daal dega
  Future<void> seedCategories() async {
    final List<Map<String, dynamic>> defaultCategories = [
      {
        'name': 'Plumber',
        'iconName': 'plumbing',
        'isActive': true,
        'sortOrder': 1,
      },
      {
        'name': 'Electrician',
        'iconName': 'electrical_services',
        'isActive': true,
        'sortOrder': 2,
      },
      {
        'name': 'AC Repair',
        'iconName': 'ac_unit',
        'isActive': true,
        'sortOrder': 3,
      },
      {
        'name': 'Cleaning',
        'iconName': 'cleaning_services',
        'isActive': true,
        'sortOrder': 4,
      },
      {
        'name': 'Painter',
        'iconName': 'format_paint',
        'isActive': true,
        'sortOrder': 5,
      },
      {
        'name': 'Carpenter',
        'iconName': 'handyman',
        'isActive': true,
        'sortOrder': 6,
      },
      {
        'name': 'Appliance',
        'iconName': 'kitchen',
        'isActive': true,
        'sortOrder': 7,
      },
      {
        'name': 'Pest Control',
        'iconName': 'pest_control',
        'isActive': true,
        'sortOrder': 8,
      },
    ];

    try {
      for (var category in defaultCategories) {
        await _firestore.collection('categories').add(category);
      }
    } catch (e) {
      throw 'Error seeding data: $e';
    }
  }
}
