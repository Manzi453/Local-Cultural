import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int placeCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.placeCount,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_police':
        return Icons.local_police;
      case 'local_library':
        return Icons.local_library;
      case 'account_balance':
        return Icons.account_balance;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'park':
        return Icons.park;
      case 'tour':
        return Icons.tour;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$placeCount places',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple category card for grid display
class SimpleCategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const SimpleCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_police':
        return Icons.local_police;
      case 'local_library':
        return Icons.local_library;
      case 'account_balance':
        return Icons.account_balance;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'park':
        return Icons.park;
      case 'tour':
        return Icons.tour;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconData(category.icon),
                  color: color,
                  size: 24,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (category.description.isNotEmpty)
                      Text(
                        category.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

