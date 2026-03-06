import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCk9DShONKm8S4dXZMj16gI6Mhnz9_cnJw',
    appId: '1:326246615164:web:eb77e513f4aa4631f3e1f9',
    messagingSenderId: '326246615164',
    projectId: 'local-cultural-75aed',
    authDomain: 'local-cultural-75aed.firebaseapp.com',
    storageBucket: 'local-cultural-75aed.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeCjucBemx_3eykibtTgPSP-UVj0YliBA',
    appId: '1:326246615164:android:9092df42e475713ff3e1f9',
    messagingSenderId: '326246615164',
    projectId: 'local-cultural-75aed',
    storageBucket: 'local-cultural-75aed.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuU_UN2_dtsFVl_SRwp1fBCz2E2bn7v3I',
    appId: '1:326246615164:ios:745b34aec4483abff3e1f9',
    messagingSenderId: '326246615164',
    projectId: 'local-cultural-75aed',
    storageBucket: 'local-cultural-75aed.firebasestorage.app',
    iosBundleId: 'com.example.local',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAuU_UN2_dtsFVl_SRwp1fBCz2E2bn7v3I',
    appId: '1:326246615164:ios:745b34aec4483abff3e1f9',
    messagingSenderId: '326246615164',
    projectId: 'local-cultural-75aed',
    storageBucket: 'local-cultural-75aed.firebasestorage.app',
    iosBundleId: 'com.example.local',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCk9DShONKm8S4dXZMj16gI6Mhnz9_cnJw',
    appId: '1:326246615164:web:ca1f8a1fbbc56ba5f3e1f9',
    messagingSenderId: '326246615164',
    projectId: 'local-cultural-75aed',
    authDomain: 'local-cultural-75aed.firebaseapp.com',
    storageBucket: 'local-cultural-75aed.firebasestorage.app',
  );

}
