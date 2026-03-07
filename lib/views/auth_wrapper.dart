import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local/services/auth_service.dart';
import 'package:local/views/main_navigation.dart';
import 'package:local/views/login_screen.dart';
import 'package:local/views/verify_email_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    ref.listen(authStateChangesProvider, (previous, next) {
      ref.read(authServiceProvider).resetSessionTimer();
    });

    return authState.when(
      data: (user) {
        if (user != null) {
          if (user.emailVerified) {
            return const MainNavigation();
          } else {
            return const VerifyEmailScreen();
          }
        } else {
          // User is not logged in, show login screen
          return LoginScreen();
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
