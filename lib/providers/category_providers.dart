import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../repositories/place_repository.dart';
import 'place_providers.dart';

// ============ CATEGORIES PROVIDERS ============

// All categories provider
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(placeRepositoryProvider);
  try {
    // Initialize default categories if needed
    await repository.initializeDefaultCategories();
    return await repository.getAllCategories();
  } catch (e) {
    // Return demo categories if Firebase fails
    return _getDemoCategories();
  }
});

// Demo categories for when Firebase is not available
List<Category> _getDemoCategories() {
  final now = DateTime.now();
  return [
    Category(
      id: 'restaurant',
      name: 'Restaurants',
      icon: 'restaurant',
      color: 0xFFFF5722,
      description: 'Restaurants and cafes',
      order: 0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'hotel',
      name: 'Hotels',
      icon: 'hotel',
      color: 0xFF2196F3,
      description: 'Hotels and lodging',
      order: 1,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'hospital',
      name: 'Hospitals',
      icon: 'hospital',
      color: 0xFFF44336,
      description: 'Hospitals and clinics',
      order: 2,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'bank',
      name: 'Banks',
      icon: 'bank',
      color: 0xFF4CAF50,
      description: 'Banks and ATMs',
      order: 3,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: 'shopping',
      color: 0xFF9C27B0,
      description: 'Shopping centers and stores',
      order: 4,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'school',
      name: 'Schools',
      icon: 'school',
      color: 0xFFFF9800,
      description: 'Schools and universities',
      order: 5,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'park',
      name: 'Parks',
      icon: 'park',
      color: 0xFF8BC34A,
      description: 'Parks and recreation',
      order: 6,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Category(
      id: 'gym',
      name: 'Fitness',
      icon: 'gym',
      color: 0xFF00BCD4,
      description: 'Gyms and fitness centers',
      order: 7,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

// All categories stream provider
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.streamAllCategories();
});

// Single category provider
final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, categoryId) async {
  final repository = ref.watch(placeRepositoryProvider);
  return repository.getCategoryById(categoryId);
});

// ============ CATEGORY OPERATIONS NOTIFIERS ============

class CategoryListNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final PlaceRepository _repository;
  final Ref _ref;
  
  CategoryListNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      // Initialize default categories first
      await _repository.initializeDefaultCategories();
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadCategories();
  }
}

final categoryListNotifierProvider = StateNotifierProvider<CategoryListNotifier, AsyncValue<List<Category>>>((ref) {
  final repository = ref.watch(placeRepositoryProvider);
  return CategoryListNotifier(repository, ref);
});

// Category operations notifier
class CategoryOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final PlaceRepository _repository;
  final Ref _ref;
  
  CategoryOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<String?> createCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.createCategory(category);
      _ref.read(categoryListNotifierProvider.notifier).refresh();
      _ref.invalidate(allCategoriesProvider);
      state = AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> updateCategory(String categoryId, Category category) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCategory(categoryId, category);
      _ref.read(categoryListNotifierProvider.notifier).refresh();
      _ref.invalidate(allCategoriesProvider);
      _ref.invalidate(categoryByIdProvider(categoryId));
      state = AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteCategory(categoryId);
      _ref.read(categoryListNotifierProvider.notifier).refresh();
      _ref.invalidate(allCategoriesProvider);
      state = AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final categoryOperationsProvider = StateNotifierProvider<CategoryOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(placeRepositoryProvider);
  return CategoryOperationsNotifier(repository, ref);
});

