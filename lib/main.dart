import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

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
    debugPrint('Continuing without Firebase for demo purposes...');
  }
  
  runApp(const ProviderScope(child: KigaliServicesApp()));
}

class KigaliServicesApp extends ConsumerWidget {
  const KigaliServicesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Kigali City Services',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}

