import '../models/place_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

class PlaceRepository {
  final FirestoreService _firestoreService;

  PlaceRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  // ============ PLACES ============

  Future<List<Place>> getAllPlaces() => _firestoreService.getAllPlaces();

  Future<List<Place>> getPlacesByCategory(String categoryId) =>
      _firestoreService.getPlacesByCategory(categoryId);

  Future<List<Place>> getFeaturedPlaces() =>
      _firestoreService.getFeaturedPlaces();

  Future<Place?> getPlaceById(String placeId) =>
      _firestoreService.getPlaceById(placeId);

  Future<List<Place>> searchPlaces(String query) =>
      _firestoreService.searchPlaces(query);

  Future<String> createPlace(Place place) => _firestoreService.createPlace(place);

  Future<void> updatePlace(String placeId, Place place) =>
      _firestoreService.updatePlace(placeId, place);

  Future<void> deletePlace(String placeId) =>
      _firestoreService.deletePlace(placeId);

  Future<int> getPlaceCountByCategory(String categoryId) =>
      _firestoreService.getPlaceCountByCategory(categoryId);

  Stream<List<Place>> streamAllPlaces() => _firestoreService.streamAllPlaces();

  Stream<List<Place>> streamPlacesByCategory(String categoryId) =>
      _firestoreService.streamPlacesByCategory(categoryId);

  // ============ CATEGORIES ============

  Future<List<Category>> getAllCategories() =>
      _firestoreService.getAllCategories();

  Future<Category?> getCategoryById(String categoryId) =>
      _firestoreService.getCategoryById(categoryId);

  Future<String> createCategory(Category category) =>
      _firestoreService.createCategory(category);

  Future<void> updateCategory(String categoryId, Category category) =>
      _firestoreService.updateCategory(categoryId, category);

  Future<void> deleteCategory(String categoryId) =>
      _firestoreService.deleteCategory(categoryId);

  Future<void> initializeDefaultCategories() =>
      _firestoreService.initializeDefaultCategories();

  Stream<List<Category>> streamAllCategories() =>
      _firestoreService.streamAllCategories();
}

