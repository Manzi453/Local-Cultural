import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../providers/place_providers.dart';
import '../providers/category_providers.dart';
import '../widgets/category_card.dart';
import '../widgets/featured_places.dart';
import '../theme/app_theme.dart';
import 'places_list_screen.dart';
import 'place_details_screen.dart';
import 'add_edit_place_screen.dart';
import 'category_management_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    if (query.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
    } else {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search places...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: _onSearch,
              )
            : const Text('Kigali Services'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: _isSearching ? _buildSearchResults() : _buildHomeContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditPlaceScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchQuery = ref.watch(searchQueryProvider);
    
    if (searchQuery.isEmpty) {
      return const Center(
        child: Text('Enter a search term'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final searchResults = ref.watch(searchPlacesProvider);
        
        return searchResults.when(
          data: (places) {
            if (places.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No places found for "$searchQuery"',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return _buildSearchResultTile(place);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultTile(Place place) {
    return ListTile(
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
        child: Icon(
          Icons.place,
          color: AppTheme.primaryColor.withOpacity(0.5),
        ),
      ),
      title: Text(place.name),
      subtitle: Text(place.address),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailsScreen(placeId: place.id),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allPlacesProvider);
        ref.invalidate(featuredPlacesProvider);
        ref.invalidate(allCategoriesProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Kigali',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find essential services and places in Kigali',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Categories section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryManagementScreen(),
                        ),
                      );
                    },
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Categories grid
            _buildCategoriesGrid(),
            
            const SizedBox(height: 20),
            
            // Featured places
            _buildFeaturedPlaces(),
            
            const SizedBox(height: 20),
            
            // Recent places
            _buildRecentPlaces(),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No categories available')),
          );
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Consumer(
              builder: (context, ref, child) {
                final countAsync = ref.watch(placeCountByCategoryProvider(category.id));
                final count = countAsync.valueOrNull ?? 0;
                
                return CategoryCard(
                  category: category,
                  placeCount: count,
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
                );
              },
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text('Error loading categories: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(allCategoriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedPlaces() {
    final featuredAsync = ref.watch(featuredPlacesProvider);
    
    return featuredAsync.when(
      data: (places) {
        if (places.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return FeaturedPlaces(
          places: places,
          onPlaceTap: (place) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(placeId: place.id),
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecentPlaces() {
    final placesAsync = ref.watch(allPlacesProvider);
    
    return placesAsync.when(
      data: (places) {
        if (places.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Show last 5 places
        final recentPlaces = places.take(5).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Places',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlacesListScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentPlaces.length,
              itemBuilder: (context, index) {
                final place = recentPlaces[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.place,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailsScreen(placeId: place.id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

