import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../core/constants/app_constants.dart';

/// Category service for CRUD operations
class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get categories collection reference
  CollectionReference get _categoriesCollection =>
      _firestore.collection(AppConstants.categoriesCollection);

  /// Get all categories stream
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }

  /// Get all categories (one-time fetch)
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _categoriesCollection.orderBy('name').get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get categories: $e';
    }
  }

  /// Get single category
  Future<CategoryModel?> getCategory(String id) async {
    try {
      final doc = await _categoriesCollection.doc(id).get();
      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get category: $e';
    }
  }

  /// Add new category
  Future<String> addCategory(CategoryModel category) async {
    try {
      final docRef = await _categoriesCollection.add(category.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add category: $e';
    }
  }

  /// Update category
  Future<void> updateCategory(String id, CategoryModel category) async {
    try {
      await _categoriesCollection.doc(id).update(category.toMap());
    } catch (e) {
      throw 'Failed to update category: $e';
    }
  }

  /// Delete category
  Future<void> deleteCategory(String id) async {
    try {
      await _categoriesCollection.doc(id).delete();
    } catch (e) {
      throw 'Failed to delete category: $e';
    }
  }

  /// Check if category name already exists
  Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      final snapshot = await _categoriesCollection
          .where('name', isEqualTo: name)
          .get();

      if (excludeId != null) {
        // Exclude current category when editing
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw 'Failed to check category name: $e';
    }
  }
}
