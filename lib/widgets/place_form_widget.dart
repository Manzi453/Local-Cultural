import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../models/category_model.dart';

class PlaceFormWidget extends StatefulWidget {
  final Place? place;
  final List<Category> categories;
  final Function(Place) onSave;
  final VoidCallback? onCancel;

  const PlaceFormWidget({
    super.key,
    this.place,
    required this.categories,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<PlaceFormWidget> createState() => _PlaceFormWidgetState();
}

class _PlaceFormWidgetState extends State<PlaceFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  
  String? _selectedCategoryId;
  bool _isOpen24Hours = false;
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final place = widget.place;
    
    _nameController = TextEditingController(text: place?.name ?? '');
    _descriptionController = TextEditingController(text: place?.description ?? '');
    _addressController = TextEditingController(text: place?.address ?? '');
    _latitudeController = TextEditingController(
      text: place?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: place?.longitude.toString() ?? '',
    );
    _phoneController = TextEditingController(text: place?.phoneNumber ?? '');
    _emailController = TextEditingController(text: place?.email ?? '');
    _websiteController = TextEditingController(text: place?.website ?? '');
    
    _selectedCategoryId = place?.categoryId;
    _isOpen24Hours = place?.isOpen24Hours ?? false;
    _isFeatured = place?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final place = Place(
        id: widget.place?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId ?? '',
        address: _addressController.text.trim(),
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty 
            ? null 
            : _websiteController.text.trim(),
        imageUrls: widget.place?.imageUrls ?? [],
        isOpen24Hours: _isOpen24Hours,
        rating: widget.place?.rating,
        reviewCount: widget.place?.reviewCount,
        isFeatured: _isFeatured,
        createdBy: widget.place?.createdBy ?? 'anonymous',
        createdAt: widget.place?.createdAt ?? now,
        updatedAt: now,
      );
      
      widget.onSave(place);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                prefixIcon: Icon(Icons.place),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category),
              ),
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Location coordinates
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      prefixIcon: Icon(Icons.explore),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final lat = double.tryParse(value);
                      if (lat == null || lat < -90 || lat > 90) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      prefixIcon: Icon(Icons.explore),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final lng = double.tryParse(value);
                      if (lng == null || lng < -180 || lng > 180) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Website
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            
            // Switches
            SwitchListTile(
              title: const Text('Open 24 Hours'),
              subtitle: const Text('Available 24/7'),
              value: _isOpen24Hours,
              onChanged: (value) {
                setState(() {
                  _isOpen24Hours = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Featured'),
              subtitle: const Text('Show in featured places'),
              value: _isFeatured,
              onChanged: (value) {
                setState(() {
                  _isFeatured = value;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                if (widget.onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                if (widget.onCancel != null) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.place == null ? 'Add Place' : 'Update Place'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

