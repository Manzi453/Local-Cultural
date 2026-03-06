import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../models/category_model.dart';
import '../providers/place_providers.dart';
import '../providers/category_providers.dart';
import '../theme/app_theme.dart';
import 'place_details_screen.dart';
import 'places_list_screen.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search directory...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _searchQuery.isNotEmpty ? _buildSearchResults() : _buildDirectoryContent(),
    );
  }

  Widget _buildSearchResults() {
    final placesAsync = ref.watch(allPlacesProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return placesAsync.when(
      data: (places) {
        final filteredPlaces = places.where((place) {
          final query = _searchQuery.toLowerCase();
          return place.name.toLowerCase().contains(query) ||
              place.address.toLowerCase().contains(query) ||
              place.description.toLowerCase().contains(query);
        }).toList();

        if (filteredPlaces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$_searchQuery"',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPlaces.length,
          itemBuilder: (context, index) {
            final place = filteredPlaces[index];
            return _buildPlaceListTile(place);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildPlaceListTile(Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.place, color: AppTheme.primaryColor),
        ),
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    place.address,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (place.phoneNumber != null && place.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    place.phoneNumber!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailsScreen(placeId: place.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDirectoryContent() {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategorySection(category);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildCategorySection(Category category) {
    final placesAsync = ref.watch(placesByCategoryProvider(category.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlacesListScreen(
                  categoryId: category.id,
                  categoryName: category.name,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.icon),
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      placesAsync.when(
                        data: (places) => Text(
                          '${places.length} places',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        loading: () => Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),

        // Places in category
        placesAsync.when(
          data: (places) {
            if (places.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('No places in this category'),
              );
            }

            // Show up to 3 places per category
            final displayPlaces = places.take(3).toList();

            return Column(
              children: displayPlaces.map((place) => _buildCompactPlaceTile(place)).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text('Error: $error'),
          ),
        ),

        const Divider(height: 32),
      ],
    );
  }

  Widget _buildCompactPlaceTile(Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.place, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          place.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          place.address,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailsScreen(placeId: place.id),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'hospital':
        return Icons.local_hospital;
      case 'bank':
        return Icons.account_balance;
      case 'shopping':
        return Icons.shopping_bag;
      case 'school':
        return Icons.school;
      case 'park':
        return Icons.park;
      case 'gym':
        return Icons.fitness_center;
      case 'gas_station':
        return Icons.local_gas_station;
      case 'atm':
        return Icons.atm;
      default:
        return Icons.place;
    }
  }
}

