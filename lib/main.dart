import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'repositories/place_repository.dart';
import 'data/seed_places.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable better debugging for stable connection
  if (!const bool.fromEnvironment('dart.vm.product')) {
    debugPrint('Debug mode enabled - connection stability improvements active');
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Continue without Firebase - app will use demo data
  }
  
  // Initialize default categories (will use demo data if Firebase fails)
  try {
    final repository = PlaceRepository();
    await repository.initializeDefaultCategories();
    
    // Seed places if database is empty
    await repository.seedPlacesIfEmpty(SeedPlaces.getKigaliPlaces());
  } catch (e) {
    debugPrint('Using demo data - Firebase not available');
  }
  
  runApp(const ProviderScope(child: KigaliServicesApp()));
}

class KigaliServicesApp extends StatelessWidget {
  const KigaliServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kigali City Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper widget that handles authentication state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bypass authentication - always show HomeScreen
    return const HomeScreen();
  }
}

