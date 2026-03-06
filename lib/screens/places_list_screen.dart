import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/place_providers.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'All Places'),
        actions: [
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
          
          // Places list
          Expanded(
            child: _buildPlacesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList() {
    final placesAsync = widget.categoryId != null
        ? ref.watch(placesByCategoryProvider(widget.categoryId!))
        : ref.watch(allPlacesProvider);

    return placesAsync.when(
      data: (places) {
        // Filter by search query
        final filteredPlaces = _searchQuery.isEmpty
            ? places
            : places.where((place) {
                return place.name.toLowerCase().contains(_searchQuery) ||
                    place.address.toLowerCase().contains(_searchQuery) ||
                    place.description.toLowerCase().contains(_searchQuery);
              }).toList();

        if (filteredPlaces.isEmpty) {
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
                  _searchQuery.isEmpty
                      ? 'No places found'
                      : 'No places match "$_searchQuery"',
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
            if (widget.categoryId != null) {
              ref.invalidate(placesByCategoryProvider(widget.categoryId!));
            } else {
              ref.invalidate(allPlacesProvider);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: filteredPlaces.length,
            itemBuilder: (context, index) {
              final place = filteredPlaces[index];
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
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditPlaceScreen(place: place),
                    ),
                  );
                },
                onDelete: () => _showDeleteDialog(place.id, place.name),
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
                if (widget.categoryId != null) {
                  ref.invalidate(placesByCategoryProvider(widget.categoryId!));
                } else {
                  ref.invalidate(allPlacesProvider);
                }
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

