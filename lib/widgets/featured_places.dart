import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../theme/app_theme.dart';

class FeaturedPlaces extends StatelessWidget {
  final List<Place> places;
  final Function(Place) onPlaceTap;

  const FeaturedPlaces({
    super.key,
    required this.places,
    required this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Places',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _FeaturedPlaceCard(
                place: place,
                onTap: () => onPlaceTap(place),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedPlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const _FeaturedPlaceCard({
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
                child: place.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          place.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image,
                              size: 40,
                              color: AppTheme.primaryColor.withOpacity(0.5),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.place,
                        size: 40,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            place.rating?.toStringAsFixed(1) ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

