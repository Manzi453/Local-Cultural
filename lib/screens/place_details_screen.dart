import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/place_providers.dart';
import '../providers/category_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/map_view_widget.dart';
import 'add_edit_place_screen.dart';

class PlaceDetailsScreen extends ConsumerWidget {
  final String placeId;

  const PlaceDetailsScreen({
    super.key,
    required this.placeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeByIdProvider(placeId));

    return placeAsync.when(
      data: (place) {
        if (place == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Place Details')),
            body: const Center(child: Text('Place not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    place.name,
                    style: const TextStyle(
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  background: place.imageUrls.isNotEmpty
                      ? Image.network(
                          place.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditPlaceScreen(place: place),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(context, ref, place.id, place.name),
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating and featured badge
                      Row(
                        children: [
                          if (place.rating != null) ...[
                            Icon(Icons.star, color: Colors.amber[700], size: 20),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (place.reviewCount != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${place.reviewCount} reviews)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                          const Spacer(),
                          if (place.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Featured',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Category
                      FutureBuilder(
                        future: ref.read(placeRepositoryProvider).getCategoryById(place.categoryId),
                        builder: (context, snapshot) {
                          final category = snapshot.data;
                          return Chip(
                            avatar: Icon(
                              Icons.category,
                              size: 16,
                              color: category != null ? Color(category.color) : null,
                            ),
                            label: Text(category?.name ?? 'Unknown'),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contact Information
                      const Text(
                        'Contact & Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Address
                      _buildInfoTile(
                        context: context,
                        icon: Icons.location_on,
                        title: 'Address',
                        content: place.address,
                        onTap: () => _launchMaps(place.latitude, place.longitude, place.name),
                      ),

                      if (place.phoneNumber != null)
                        _buildInfoTile(
                          context: context,
                          icon: Icons.phone,
                          title: 'Phone',
                          content: place.phoneNumber!,
                          onTap: () => _launchPhone(place.phoneNumber!),
                        ),

                      if (place.email != null)
                        _buildInfoTile(
                          context: context,
                          icon: Icons.email,
                          title: 'Email',
                          content: place.email!,
                          onTap: () => _launchEmail(place.email!),
                        ),

                      if (place.website != null)
                        _buildInfoTile(
                          context: context,
                          icon: Icons.language,
                          title: 'Website',
                          content: place.website!,
                          onTap: () => _launchUrl(place.website!),
                        ),

                      // Opening Hours
                      if (place.openingHours.isNotEmpty || place.isOpen24Hours) ...[
                        const SizedBox(height: 16),
                        _buildInfoTile(
                          context: context,
                          icon: Icons.access_time,
                          title: 'Opening Hours',
                          content: place.isOpen24Hours ? 'Open 24 Hours' : place.openingHours.join('\n'),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Map
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MapViewWidget(place: place),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _launchMaps(place.latitude, place.longitude, place.name),
            icon: const Icon(Icons.directions),
            label: const Text('Navigate'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.place,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(content),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String placeId, String placeName) {
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
              if (success && context.mounted) {
                Navigator.pop(context);
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

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMaps(double lat, double lng, String name) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

