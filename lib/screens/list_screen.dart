import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../providers/place_providers.dart';
import '../providers/category_providers.dart';
import '../theme/app_theme.dart';
import 'place_details_screen.dart';

class ListScreen extends ConsumerStatefulWidget {
  const ListScreen({super.key});

  @override
  ConsumerState<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<ListScreen> {
  String? _selectedCategoryId;
  String _sortBy = 'name'; // name, rating, recent

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(allPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryFilter(),
          
          // Places list
          Expanded(
            child: placesAsync.when(
              data: (places) {
                // Filter by category
                var filteredPlaces = _selectedCategoryId != null
                    ? places.where((p) => p.categoryId == _selectedCategoryId).toList()
                    : places;

                // Sort places
                filteredPlaces = _sortPlaces(filteredPlaces);

                if (filteredPlaces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategoryId != null
                              ? 'No places in this category'
                              : 'No places available',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allPlacesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = filteredPlaces[index];
                      return _buildPlaceCard(place);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(allPlacesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: categoriesAsync.when(
        data: (categories) {
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // All filter
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              ),
              // Category filters
              ...categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    final categoryAsync = ref.watch(categoryByIdProvider(place.categoryId));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailsScreen(placeId: place.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Place icon/image
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.place,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              
              // Place details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and featured badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (place.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.amber),
                                SizedBox(width: 2),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Category
                    categoryAsync.when(
                      data: (category) => Text(
                        category?.name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 4),
                    
                    // Address
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    // Rating and hours
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (place.rating != null && place.rating! > 0) ...[
                          Icon(Icons.star, size: 14, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                          place.isOpen24Hours ? Icons.access_time : Icons.schedule,
                          size: 14,
                          color: place.isOpen24Hours ? Colors.green : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.isOpen24Hours ? 'Open 24h' : 'Hours vary',
                          style: TextStyle(
                            fontSize: 12,
                            color: place.isOpen24Hours ? Colors.green : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Chevron
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  List<Place> _sortPlaces(List<Place> places) {
    switch (_sortBy) {
      case 'rating':
        places.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'recent':
        places.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
      default:
        places.sort((a, b) => a.name.compareTo(b.name));
    }
    return places;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name'),
              trailing: _sortBy == 'name' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
              onTap: () {
                setState(() {
                  _sortBy = 'name';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rating'),
              trailing: _sortBy == 'rating' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
              onTap: () {
                setState(() {
                  _sortBy = 'rating';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Most Recent'),
              trailing: _sortBy == 'recent' ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
              onTap: () {
                setState(() {
                  _sortBy = 'recent';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

