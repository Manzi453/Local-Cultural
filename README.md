# Kigali City Services & Places Directory

A comprehensive mobile application for discovering and navigating to essential services and places in Kigali, Rwanda. Built with Flutter and Firebase, this app allows users to find, create, and manage listings for various categories including hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions.

## Features

### 🔐 Authentication
- User registration and login with email/password
- Email verification required for account access
- Secure user profile management
- Password reset functionality

### 📱 Directory & Listings
- **Create, Read, Update, Delete** (CRUD) operations for listings
- Search listings by name
- Filter listings by category
- Real-time updates with Firestore
- User-specific listing management

### 🗺️ Map Integration
- Interactive Google Maps view
- Location markers for all listings
- Category-based map filtering
- Turn-by-turn navigation integration
- Location selection via map tap

### 📋 Categories
- Hospital
- Police Station
- Public Library
- Restaurant
- Café
- Park
- Tourist Attraction
- Utility Office

### ⚙️ Settings & Profile
- User profile display
- Location-based notification preferences
- App information and version details
- Sign out functionality

## Technical Implementation

### Architecture
- **State Management**: Riverpod for reactive state management
- **Backend**: Firebase Authentication and Cloud Firestore
- **Maps**: Google Maps Flutter SDK
- **Navigation**: URL Launcher for external navigation
- **Architecture Pattern**: Clean separation of UI, business logic, and data layers

### Database Structure

#### Users Collection
```dart
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "emailVerified": boolean,
  "createdAt": timestamp
}
```

#### Listings Collection
```dart
{
  "name": "string",
  "category": "string",
  "address": "string",
  "contactNumber": "string",
  "description": "string",
  "latitude": double,
  "longitude": double,
  "createdBy": "string (user uid)",
  "timestamp": timestamp
}
```

### Key Components

#### Services Layer
- `AuthService`: Firebase Authentication operations
- `FirestoreService`: Database CRUD operations
- `UrlLauncherService`: External app integration

#### State Management
- `AuthNotifier`: Authentication state management
- `ListingsNotifier`: Listing CRUD operations
- `SearchNotifier`: Search and filter state

#### UI Components
- Authentication screens with gradient design
- Directory with search and filtering
- Interactive map view with markers
- Detailed listing pages with embedded maps
- User-friendly forms for listing management

## Setup Instructions

### Prerequisites
1. Flutter SDK (>= 3.10.8)
2. Firebase project
3. Google Maps API key

### Firebase Configuration
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password) and Firestore Database
3. Download configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. Update `lib/firebase_options.dart` with your Firebase configuration

### Google Maps Setup
1. Enable Google Maps SDK for Android and iOS in your Firebase project
2. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
3. Add the API key to:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd kigali-city-services

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Usage

1. **Sign Up**: Create an account with email and password
2. **Verify Email**: Check your email for verification link
3. **Browse Directory**: View all listings or search/filter by category
4. **Add Listing**: Create new service/place listings with location details
5. **Manage Listings**: Edit or delete your own listings
6. **Map View**: View all locations on an interactive map
7. **Get Directions**: Launch navigation to any location

## Design

### Color Scheme
- **Dark Blue**: Primary color (#1565C0)
- **Light Green**: Accent color (#81C784)
- **Sky Blue**: Background and surface colors (#87CEEB)

### UI Features
- Material Design components
- Gradient backgrounds
- Card-based layouts
- Responsive design
- Loading states and error handling

## Dependencies

See `pubspec.yaml` for complete list:
- `flutter_riverpod`: State management
- `firebase_core`: Firebase core
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `google_maps_flutter`: Maps integration
- `url_launcher`: External app integration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Demo Video

A comprehensive demo video (7-12 minutes) demonstrates:
- User authentication flow
- Creating, editing, and deleting listings
- Search and filtering functionality
- Map integration and navigation
- Real-time Firebase updates

## Future Enhancements

- Push notifications for nearby places
- User reviews and ratings
- Photo uploads for listings
- Offline mode support
- Multi-language support (Kinyarwanda, French, English)
