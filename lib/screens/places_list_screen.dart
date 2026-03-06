import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/place_providers.dart';
import '../providers/category_providers.dart';
import '../providers/auth_providers.dart';
import '../models/category_model.dart';
import '../widgets/place_card.dart';
import 'place_details_screen.dart';
import 'add_edit_place_screen.dart';

class PlacesListScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const PlacesListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends ConsumerState<PlacesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _selectedCategoryFilter = widget.categoryId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    
    // Update search and filter state
    ref.read(searchQueryProvider.notifier).state = _searchQuery;
    ref.read(selectedCategoryFilterProvider.notifier).state = _selectedCategoryFilter;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'All Places'),
        actions: [
          if (currentUserId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditPlaceScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Category filter chips
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // "All" chip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategoryFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryFilter = null;
                          });
                        },
                      ),
                    ),
                    // Category chips
                    ...categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryFilter == category.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryFilter = selected ? category.id : null;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 8),
          
          // Places list
          Expanded(
            child: _buildPlacesList(currentUserId),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList(String? currentUserId) {
    // Use filtered places provider which combines search + category filter
    final placesAsync = ref.watch(filteredPlacesProvider);

    return placesAsync.when(
      data: (places) {
        if (places.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty || _selectedCategoryFilter != null
                      ? 'No places match your filters'
                      : 'No places found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(filteredPlacesProvider);
            ref.invalidate(allPlacesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              final canEdit = place.canEdit(currentUserId);
              final canDelete = place.canDelete(currentUserId);
              
              return PlaceCard(
                place: place,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailsScreen(placeId: place.id),
                    ),
                  );
                },
                onEdit: canEdit
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditPlaceScreen(place: place),
                          ),
                        );
                      }
                    : null,
                onDelete: canDelete
                    ? () => _showDeleteDialog(place.id, place.name)
                    : null,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('Error: $error'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(filteredPlacesProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String placeId, String placeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place'),
        content: Text('Are you sure you want to delete "$placeName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(placeOperationsProvider.notifier)
                  .deletePlace(placeId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Place deleted successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

