import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../providers/place_providers.dart';
import '../providers/category_providers.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import 'place_details_screen.dart';

class MapsScreen extends ConsumerStatefulWidget {
  const MapsScreen({super.key});

  @override
  ConsumerState<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends ConsumerState<MapsScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(allPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              _showMapInfo(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),
          
          // Map placeholder with places list
          Expanded(
            child: placesAsync.when(
              data: (places) {
                // Filter by category
                var filteredPlaces = _selectedCategoryId != null
                    ? places.where((p) => p.categoryId == _selectedCategoryId).toList()
                    : places;

                return _buildMapPlaceholder(filteredPlaces);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading map: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMapInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map View'),
        content: const Text(
          'To enable the interactive Google Map, you need to:\n\n'
          '1. Get a Google Maps API key from Google Cloud Console\n'
          '2. Enable Google Maps SDK for iOS\n'
          '3. Add your API key in ios/Runner/Info.plist\n\n'
          'Replace YOUR_GOOGLE_MAPS_API_KEY_HERE with your actual API key.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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

  Widget _buildMapPlaceholder(List<Place> places) {
    return Stack(
      children: [
        // Placeholder map background
        Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Map View',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Configure Google Maps API key to enable interactive map.\n\n'
                    '${places.length} places available',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showMapInfo(context),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('More Info'),
                ),
              ],
            ),
          ),
        ),
        
        // Places count indicator
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  '${places.length} places',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Places list at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Places',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${places.length} found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: places.isEmpty
                      ? Center(
                          child: Text(
                            'No places in this category',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: places.length > 10 ? 10 : places.length,
                          itemBuilder: (context, index) {
                            final place = places[index];
                            return _buildPlaceCard(place);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(place.address)),
              ],
            ),
            if (place.phoneNumber != null && place.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(place.phoneNumber!),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailsScreen(placeId: place.id),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailsScreen(placeId: place.id),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, bottom: 16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.place,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  place.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  place.address,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (place.rating != null && place.rating! > 0) ...[
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber[600]),
                      const SizedBox(width: 2),
                      Text(
                        place.rating!.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

