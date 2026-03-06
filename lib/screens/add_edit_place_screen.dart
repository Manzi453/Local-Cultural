import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../providers/place_providers.dart';
import '../providers/category_providers.dart';
import '../widgets/place_form_widget.dart';

class AddEditPlaceScreen extends ConsumerWidget {
  final Place? place;

  const AddEditPlaceScreen({
    super.key,
    this.place,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(place == null ? 'Add New Place' : 'Edit Place'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return PlaceFormWidget(
            place: place,
            categories: categories,
            onSave: (newPlace) async {
              if (place == null) {
                // Create new place
                final id = await ref
                    .read(placeOperationsProvider.notifier)
                    .createPlace(newPlace);
                if (id != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Place created successfully')),
                  );
                  Navigator.pop(context);
                }
              } else {
                // Update existing place
                final success = await ref
                    .read(placeOperationsProvider.notifier)
                    .updatePlace(place!.id, newPlace);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Place updated successfully')),
                  );
                  Navigator.pop(context);
                }
              }
            },
            onCancel: () => Navigator.pop(context),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
}

