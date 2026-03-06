import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';
import '../models/category_model.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ PLACES ============

  /// Get all places
  Future<List<Place>> getAllPlaces() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.placesCollection)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all places: $e');
      return [];
    }
  }

  /// Get places by category
  Future<List<Place>> getPlacesByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.placesCollection)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting places by category: $e');
      return [];
    }
  }

  /// Get featured places
  Future<List<Place>> getFeaturedPlaces() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.placesCollection)
          .where('isFeatured', isEqualTo: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting featured places: $e');
      return [];
    }
  }

  /// Get a single place by ID
  Future<Place?> getPlaceById(String placeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.placesCollection)
          .doc(placeId)
          .get();
      if (doc.exists) {
        return Place.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting place by ID: $e');
      return null;
    }
  }

  /// Search places by name or address
  Future<List<Place>> searchPlaces(String query) async {
    try {
      // Firestore doesn't support full-text search natively
      // We'll fetch all and filter in memory for now
      // For production, consider using Algolia or similar
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.placesCollection)
          .orderBy('name')
          .get();
      
      List<Place> places = snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      
      // Filter by name or address
      String lowerQuery = query.toLowerCase();
      return places.where((place) {
        return place.name.toLowerCase().contains(lowerQuery) ||
            place.address.toLowerCase().contains(lowerQuery) ||
            place.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  /// Create a new place
  Future<String> createPlace(Place place) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(AppConstants.placesCollection)
          .add(place.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating place: $e');
      rethrow;
    }
  }

  /// Update an existing place
  Future<void> updatePlace(String placeId, Place place) async {
    try {
      await _firestore
          .collection(AppConstants.placesCollection)
          .doc(placeId)
          .update(place.toFirestore());
    } catch (e) {
      print('Error updating place: $e');
      rethrow;
    }
  }

  /// Delete a place
  Future<void> deletePlace(String placeId) async {
    try {
      await _firestore
          .collection(AppConstants.placesCollection)
          .doc(placeId)
          .delete();
    } catch (e) {
      print('Error deleting place: $e');
      rethrow;
    }
  }

  /// Get place count by category
  Future<int> getPlaceCountByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.placesCollection)
          .where('categoryId', isEqualTo: categoryId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting place count: $e');
      return 0;
    }
  }

  // ============ CATEGORIES ============

  /// Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  /// Get a single category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .get();
      if (doc.exists) {
        return Category.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting category by ID: $e');
      return null;
    }
  }

  /// Create a new category
  Future<String> createCategory(Category category) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(AppConstants.categoriesCollection)
          .add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating category: $e');
      rethrow;
    }
  }

  /// Update an existing category
  Future<void> updateCategory(String categoryId, Category category) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .update(category.toFirestore());
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  /// Initialize default categories if none exist
  Future<void> initializeDefaultCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .get();
      
      if (snapshot.docs.isEmpty) {
        print('Initializing default categories...');
        for (int i = 0; i < AppConstants.defaultCategories.length; i++) {
          final category = AppConstants.defaultCategories[i];
          await _firestore
              .collection(AppConstants.categoriesCollection)
              .doc(category['id'])
              .set({
            'name': category['name'],
            'icon': category['icon'],
            'color': category['color'],
            'description': category['description'],
            'order': i,
            'isActive': true,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }
        print('Default categories initialized successfully');
      }
    } catch (e) {
      print('Error initializing default categories: $e');
    }
  }

  // ============ REAL-TIME STREAM ============

  /// Stream all places in real-time
  Stream<List<Place>> streamAllPlaces() {
    return _firestore
        .collection(AppConstants.placesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList());
  }

  /// Stream places by category in real-time
  Stream<List<Place>> streamPlacesByCategory(String categoryId) {
    return _firestore
        .collection(AppConstants.placesCollection)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList());
  }

  /// Stream all categories in real-time
  Stream<List<Category>> streamAllCategories() {
    return _firestore
        .collection(AppConstants.categoriesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // ============ SEED DATA ============

  /// Seed places to the database if no places exist
  Future<void> seedPlacesIfEmpty(List<Place> seedPlaces) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.placesCollection)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No places found in database. Seeding ${seedPlaces.length} places...');
        
        // Create a batch for faster writes
        WriteBatch batch = _firestore.batch();
        
        for (final place in seedPlaces) {
          DocumentReference docRef = _firestore
              .collection(AppConstants.placesCollection)
              .doc(place.id);
          batch.set(docRef, place.toFirestore());
        }
        
        await batch.commit();
        print('Successfully seeded ${seedPlaces.length} places to database');
      } else {
        print('Places already exist in database. Skipping seed.');
      }
    } catch (e) {
      print('Error seeding places: $e');
    }
  }
}

