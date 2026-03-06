import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../theme/app_theme.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
                child: place.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          place.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderIcon();
                          },
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (place.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.address,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (place.rating != null) ...[
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (place.isOpen24Hours)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Open 24h',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (onEdit != null)
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            onPressed: onEdit,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red[400],
                            ),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Icon(
      Icons.place,
      size: 32,
      color: AppTheme.primaryColor.withOpacity(0.5),
    );
  }
}

// List tile variant for cleaner look
class PlaceListTile extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final Widget? trailing;

  const PlaceListTile({
    super.key,
    required this.place,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
        child: place.imageUrls.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  place.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.place,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    );
                  },
                ),
              )
            : Icon(
                Icons.place,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
      ),
      title: Text(
        place.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          if (place.rating != null)
            Row(
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber[700]),
                const SizedBox(width: 2),
                Text(
                  place.rating!.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
        ],
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      isThreeLine: place.rating != null,
    );
  }
}

