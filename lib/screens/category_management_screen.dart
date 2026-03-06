import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../providers/category_providers.dart';
import '../theme/app_theme.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryListTile(
                category: category,
                onEdit: () => _showEditCategoryDialog(context, ref, category),
                onDelete: () => _showDeleteDialog(context, ref, category),
              );
            },
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
                onPressed: () => ref.invalidate(allCategoriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        onSave: (category) async {
          await ref.read(categoryOperationsProvider.notifier).createCategory(category);
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        category: category,
        onSave: (updatedCategory) async {
          await ref
              .read(categoryOperationsProvider.notifier)
              .updateCategory(category.id, updatedCategory);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(categoryOperationsProvider.notifier)
                  .deleteCategory(category.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryListTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
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
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconData(category.icon),
            color: color,
          ),
        ),
        title: Text(category.name),
        subtitle: Text(
          category.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const _CategoryFormDialog({
    this.category,
    required this.onSave,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _selectedIcon = 'place';
  int _selectedColor = 0xFF607D8B;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': 'Hospital'},
    {'name': 'local_police', 'icon': Icons.local_police, 'label': 'Police'},
    {'name': 'local_library', 'icon': Icons.local_library, 'label': 'Library'},
    {'name': 'account_balance', 'icon': Icons.account_balance, 'label': 'Utility'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Restaurant'},
    {'name': 'local_cafe', 'icon': Icons.local_cafe, 'label': 'Café'},
    {'name': 'park', 'icon': Icons.park, 'label': 'Park'},
    {'name': 'tour', 'icon': Icons.tour, 'label': 'Tourist'},
    {'name': 'place', 'icon': Icons.place, 'label': 'Other'},
  ];

  final List<int> _colors = [
    0xFFE53935, // Red
    0xFF1E88E5, // Blue
    0xFF8E24AA, // Purple
    0xFF43A047, // Green
    0xFFFF6F00, // Orange
    0xFF795548, // Brown
    0xFFFFD700, // Gold
    0xFF607D8B, // Grey
    0xFF00897B, // Teal
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
    if (widget.category != null) {
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Icon'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((iconData) {
                  final isSelected = _selectedIcon == iconData['name'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['name'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : null,
                      ),
                      child: Icon(iconData['icon']),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Color'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(color),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final now = DateTime.now();
              final category = Category(
                id: widget.category?.id ?? '',
                name: _nameController.text.trim(),
                icon: _selectedIcon,
                color: _selectedColor,
                description: _descriptionController.text.trim(),
                order: widget.category?.order ?? 0,
                isActive: true,
                createdAt: widget.category?.createdAt ?? now,
                updatedAt: now,
              );
              widget.onSave(category);
              Navigator.pop(context);
            }
          },
          child: Text(widget.category == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

