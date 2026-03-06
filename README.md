# 📱 Local Cultural - Kigali City Services

A Flutter mobile application for discovering and managing local services in Kigali, Rwanda.

---

## ✅ Implemented Features

### 1. Location Listings (CRUD)
- ✅ **Create** new listings with all required fields
- ✅ **Read** and display all listings in a shared directory
- ✅ **Update** listings created by the authenticated user
- ✅ **Delete** listings created by the authenticated user
- ✅ Real-time state-managed updates using Riverpod

#### Place Fields:
- Place/Service Name
- Category (Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction)
- Address
- Contact Number
- Description
- Geographic Coordinates (Latitude & Longitude)
- Created By (User UID)
- Timestamp (createdAt, updatedAt)

### 2. Authentication System
- ✅ User registration with email/password
- ✅ User login with email/password
- ✅ Authentication state management
- ✅ Protected routes based on auth status

### 3. Directory Search and Filtering
- ✅ Search listings by name
- ✅ Filter results by category
- ✅ Dynamic filtering (search + category combined)
- ✅ Real-time search results

### 4. Detail Page and Map Integration
- ✅ Detailed view for each listing
- ✅ Embedded Google Map with location marker
- ✅ Navigate button for turn-by-turn directions
- ✅ Contact options (phone, email, website)

---

## 📁 Directory Structure

```
Local-Cultural/
├── lib/
│   ├── main.dart                    # App entry point with auth wrapper
│   ├── firebase_options.dart        # Firebase configuration
│   ├── constants/
│   │   └── app_constants.dart       # App constants
│   ├── models/
│   │   ├── place_model.dart         # Place data model with user management
│   │   └── category_model.dart      # Category data model
│   ├── providers/
│   │   ├── auth_providers.dart      # Firebase Auth state providers
│   │   ├── place_providers.dart     # Place state + CRUD + search/filter
│   │   └── category_providers.dart # Category state providers
│   ├── repositories/
│   │   └── place_repository.dart    # Data access layer
│   ├── screens/
│   │   ├── auth_screen.dart         # Login/Register screen
│   │   ├── home_screen.dart         # Main home screen
│   │   ├── places_list_screen.dart  # Places list with search/filter
│   │   ├── place_details_screen.dart # Place detail with map
│   │   ├── add_edit_place_screen.dart # Add/Edit place form
│   │   └── category_management_screen.dart # Category management
│   ├── services/
│   │   └── firestore_service.dart   # Firestore CRUD operations
│   ├── theme/
│   │   └── app_theme.dart           # Light & Dark themes
│   └── widgets/
│       ├── category_card.dart
│       ├── featured_places.dart
│       ├── map_view_widget.dart
│       ├── place_card.dart
│       └── place_form_widget.dart
├── pubspec.yaml                     # Dependencies
└── firebase.json                    # Firebase config
```

---

## ⚙️ Settings & Configuration

### Firebase Configuration
| Platform | Project ID | App ID |
|----------|------------|--------|
| Android | local-cultural-75aed | 1:326246615164:android:9092df42e475713ff3e1f9 |
| iOS | local-cultural-75aed | 1:326246615164:ios:745b34aec4483abff3e1f9 |
| Web | local-cultural-75aed | 1:326246615164:web:eb77e513f4aa4631f3e1f9 |

### Firestore Collections
- **`places`** - Stores all place/location data with user ownership
- **`categories`** - Stores category definitions

### Default Categories
| ID | Name | Icon | Color |
|----|------|------|-------|
| hospital | Hospitals | local_hospital | #E53935 |
| police | Police Stations | local_police | #1E88E5 |
| library | Public Libraries | local_library | #8E24AA |
| utility | Utility Offices | account_balance | #43A047 |
| restaurant | Restaurants | restaurant | #FF6F00 |
| cafe | Cafés | local_cafe | #795548 |
| park | Parks | park | #43A047 |
| tourist | Tourist Attractions | tour | #FFD700 |

### Map Settings (Kigali, Rwanda)
```dart
static const double kigaliLatitude = -1.9403;
static const double kigaliLongitude = 29.8739;
static const double defaultZoom = 13.0;
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.4.9
  google_maps_flutter: ^2.5.0
  url_launcher: ^6.2.2
  share_plus: ^12.0.1
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
```

---

## 🚀 Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Build for production:**
   ```bash
   flutter build apk      # Android
   flutter build ios      # iOS
   flutter build web      # Web
   ```

---

## 🔐 User Permissions

| Action | Authenticated User | Non-Authenticated User |
|--------|-------------------|----------------------|
| View places | ✅ | ✅ |
| Search places | ✅ | ✅ |
| Filter by category | ✅ | ✅ |
| View place details | ✅ | ✅ |
| Get directions | ✅ | ✅ |
| Add new place | ✅ | ❌ |
| Edit own place | ✅ | ❌ |
| Delete own place | ✅ | ❌ |
| Manage categories | ✅ | ❌ |

---

## 🎯 Key Features

1. **State Management:** Riverpod for reactive state management
2. **Authentication:** Firebase Auth with email/password
3. **Database:** Cloud Firestore with real-time updates
4. **Maps:** Google Maps Flutter integration
5. **Search:** Combined search + category filtering
6. **UI:** Material Design 3 with custom theming

