class AppConstants {
  // App Info
  static const String appName = 'Kigali City Services';
  static const String appVersion = '1.0.0';
  
  // Firestore Collections
  static const String placesCollection = 'places';
  static const String categoriesCollection = 'categories';
  
  // Default Kigali coordinates
  static const double kigaliLatitude = -1.9403;
  static const double kigaliLongitude = 29.8739;
  static const double defaultZoom = 13.0;
  
  // Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'id': 'hospital',
      'name': 'Hospitals',
      'icon': 'local_hospital',
      'color': 0xFFE53935,
      'description': 'Medical centers and hospitals',
    },
    {
      'id': 'police',
      'name': 'Police Stations',
      'icon': 'local_police',
      'color': 0xFF1E88E5,
      'description': 'Police stations and security offices',
    },
    {
      'id': 'library',
      'name': 'Public Libraries',
      'icon': 'local_library',
      'color': 0xFF8E24AA,
      'description': 'Public libraries and reading centers',
    },
    {
      'id': 'utility',
      'name': 'Utility Offices',
      'icon': 'account_balance',
      'color': 0xFF43A047,
      'description': 'Water, electricity, and utility offices',
    },
    {
      'id': 'restaurant',
      'name': 'Restaurants',
      'icon': 'restaurant',
      'color': 0xFFFF6F00,
      'description': 'Restaurants and dining places',
    },
    {
      'id': 'cafe',
      'name': 'Cafés',
      'icon': 'local_cafe',
      'color': 0xFF795548,
      'description': 'Coffee shops and cafés',
    },
    {
      'id': 'park',
      'name': 'Parks',
      'icon': 'park',
      'color': 0xFF43A047,
      'description': 'Parks and recreational areas',
    },
    {
      'id': 'tourist',
      'name': 'Tourist Attractions',
      'icon': 'tour',
      'color': 0xFFFFD700,
      'description': 'Tourist spots and attractions',
    },
  ];
  
  // Search
  static const int searchDebounceMs = 300;
  static const int minSearchCharacters = 2;
  
  // Pagination
  static const int placesPerPage = 20;
  
  // Image
  static const double maxImageSize = 5.0; // MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
}

