import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../repositories/place_repository.dart';

// Repository provider
final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository();
});

// ============ PLACES PROVIDERS ============

// All places provider
final allPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final repository = ref.watch(placeRepositoryProvider);
  try {
    return await repository.getAllPlaces();
  } catch (e) {
    // Return demo data if Firebase fails
    return _getDemoPlaces();
  }
});

// Demo places for when Firebase is not available
List<Place> _getDemoPlaces() {
  return [
    Place(
      id: '1',
      name: 'Kigali Marriott Hotel',
      description: 'Luxury hotel in the heart of Kigali',
      categoryId: 'hotel',
      address: 'Kigali, Rwanda',
      latitude: -1.9536,
      longitude: 30.0606,
      phoneNumber: '+250 788 123 456',
      rating: 4.5,
      isFeatured: true,
      createdBy: 'demo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Place(
      id: '2',
      name: 'Bourbon Coffee',
      description: 'Popular coffee shop in Kigali',
      categoryId: 'restaurant',
      address: 'Kigali Heights, Kigali',
      latitude: -1.9540,
      longitude: 30.0590,
      phoneNumber: '+250 788 234 567',
      rating: 4.3,
      createdBy: 'demo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Place(
      id: '3',
      name: 'King Faisal Hospital',
      description: 'Leading hospital in Rwanda',
      categoryId: 'hospital',
      address: 'Kigali, Rwanda',
      latitude: -1.9440,
      longitude: 30.0440,
      phoneNumber: '+250 788 345 678',
      rating: 4.2,
      createdBy: 'demo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Place(
      id: '4',
      name: 'Bank of Kigali',
      description: 'Major bank in Rwanda',
      categoryId: 'bank',
      address: 'KN 4 Ave, Kigali',
      latitude: -1.9537,
      longitude: 30.0594,
      phoneNumber: '+250 788 456 789',
      rating: 4.0,
      createdBy: 'demo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Place(
      id: '5',
      name: 'Kigali Convention Centre',
      description: 'Modern convention centre',
      categoryId: 'hotel',
      address: 'Kigali, Rwanda',
      latitude: -1.9700,
      longitude: 30.0500,
      rating: 4.6,
      isFeatured: true,
      createdBy: 'demo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
}

// All places stream provider
final placesStreamProvider = StreamProvider<List<Place>>((ref) {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.streamAllPlaces();
});

// Places by category provider
final placesByCategoryProvider = FutureProvider.family<List<Place>, String>((ref, categoryId) async {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.getPlacesByCategory(categoryId);
});

// Places by category stream provider
final placesByCategoryStreamProvider = StreamProvider.family<List<Place>, String>((ref, categoryId) {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.streamPlacesByCategory(categoryId);
});

// Featured places provider
final featuredPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.getFeaturedPlaces();
});

// Single place provider
final placeByIdProvider = FutureProvider.family<Place?, String>((ref, placeId) async {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.getPlaceById(placeId);
});

// ============ SEARCH & FILTER PROVIDERS ============

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected category filter state
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

// Search results provider
final searchPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final repository = ref.watch(placeRepositoryProvider);
  return repository.searchPlaces(query);
});

// Combined filtered places provider (search + category filter)
final filteredPlacesProvider = FutureProvider<List<Place>>((ref) async {
  final repository = ref.watch(placeRepositoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(selectedCategoryFilterProvider);
  
  // Get all places
  List<Place> places = await repository.getAllPlaces();
  
  // Filter by category if selected
  if (categoryFilter != null && categoryFilter.isNotEmpty) {
    places = places.where((place) => place.categoryId == categoryFilter).toList();
  }
  
  // Filter by search query if present
  if (searchQuery.isNotEmpty) {
    final lowerQuery = searchQuery.toLowerCase();
    places = places.where((place) {
      return place.name.toLowerCase().contains(lowerQuery) ||
          place.address.toLowerCase().contains(lowerQuery) ||
          place.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  return places;
});

// Selected category provider (for UI)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Place count by category
final placeCountByCategoryProvider = FutureProvider.family<int, String>((ref, categoryId) async {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.getPlaceCountByCategory(categoryId);
});

// ============ CRUD OPERATIONS NOTIFIERS ============

// Place list notifier for managing place operations
class PlaceListNotifier extends StateNotifier<AsyncValue<List<Place>>> {
  final PlaceRepository _repository;
  
  PlaceListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    state = const AsyncValue.loading();
    try {
      final places = await _repository.getAllPlaces();
      state = AsyncValue.data(places);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadPlaces();
  }
}

final placeListNotifierProvider = StateNotifierProvider<PlaceListNotifier, AsyncValue<List<Place>>>((ref) {
  final repository = ref.watch(placeRepositoryProvider);
  return PlaceListNotifier(repository);
});

// Single place operations notifier
class PlaceOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final PlaceRepository _repository;
  final Ref _ref;
  
  PlaceOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<String?> createPlace(Place place) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.createPlace(place);
      // Refresh the place list
      _ref.read(placeListNotifierProvider.notifier).refresh();
      _ref.invalidate(allPlacesProvider);
      _ref.invalidate(featuredPlacesProvider);
      state = AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updatePlace(String placeId, Place place) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updatePlace(placeId, place);
      // Refresh the place list
      _ref.read(placeListNotifierProvider.notifier).refresh();
      _ref.invalidate(allPlacesProvider);
      _ref.invalidate(featuredPlacesProvider);
      _ref.invalidate(placeByIdProvider(placeId));
      state = AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deletePlace(String placeId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deletePlace(placeId);
      // Refresh the place list
      _ref.read(placeListNotifierProvider.notifier).refresh();
      _ref.invalidate(allPlacesProvider);
      _ref.invalidate(featuredPlacesProvider);
      state = AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final placeOperationsProvider = StateNotifierProvider<PlaceOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(placeRepositoryProvider);
  return PlaceOperationsNotifier(repository, ref);
});

