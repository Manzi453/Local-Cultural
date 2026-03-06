import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../repositories/place_repository.dart';
import 'place_providers.dart';

// ============ CATEGORIES PROVIDERS ============

// All categories provider
final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(placeRepositoryProvider);
  // Initialize default categories if needed
  await repository.initializeDefaultCategories();
  return repository.getAllCategories();
});

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

