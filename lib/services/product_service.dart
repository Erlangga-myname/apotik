import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../core/constants/app_constants.dart';

/// Product service for CRUD operations
class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get products collection reference
  CollectionReference get _productsCollection =>
      _firestore.collection(AppConstants.productsCollection);

  /// Get all products stream
  Stream<List<ProductModel>> getProductsStream() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  /// Get products by category stream
  Stream<List<ProductModel>> getProductsByCategoryStream(String categoryId) {
    return _productsCollection
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  /// Get low stock products stream
  Stream<List<ProductModel>> getLowStockProductsStream() {
    return _productsCollection
        .where('stock', isLessThan: AppConstants.lowStockThreshold)
        .orderBy('stock')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  /// Get single product
  Future<ProductModel?> getProduct(String id) async {
    try {
      final doc = await _productsCollection.doc(id).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get product: $e';
    }
  }

  /// Add new product
  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _productsCollection.add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  /// Update product
  Future<void> updateProduct(String id, ProductModel product) async {
    try {
      await _productsCollection.doc(id).update(product.toMap());
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _productsCollection.doc(id).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  /// Update product stock
  Future<void> updateStock(String id, int newStock) async {
    try {
      await _productsCollection.doc(id).update({'stock': newStock});
    } catch (e) {
      throw 'Failed to update stock: $e';
    }
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _productsCollection.get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // Filter by name (case-insensitive)
      return products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw 'Failed to search products: $e';
    }
  }

  /// Get total product count
  Future<int> getTotalProductCount() async {
    try {
      final snapshot = await _productsCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      throw 'Failed to get product count: $e';
    }
  }

  /// Get low stock count
  Future<int> getLowStockCount() async {
    try {
      final snapshot = await _productsCollection
          .where('stock', isLessThan: AppConstants.lowStockThreshold)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw 'Failed to get low stock count: $e';
    }
  }
}
