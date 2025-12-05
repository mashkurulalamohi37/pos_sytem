// File generated using Firebase configuration
// This file contains Firebase options for all platforms

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCgtN42UVdk9Z2dnyt7TddBenqmlCN3YuU',
    appId: '1:212072997600:web:625c02178b519ddbda2685',
    messagingSenderId: '212072997600',
    projectId: 'possystem-e1655',
    authDomain: 'possystem-e1655.firebaseapp.com',
    storageBucket: 'possystem-e1655.firebasestorage.app',
    measurementId: 'G-LRKT3NC30M',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjjzp6qBMlBvbnv7hBKQR16P4SicqWAMM',
    appId: '1:212072997600:android:272f5ca99306a8efda2685',
    messagingSenderId: '212072997600',
    projectId: 'possystem-e1655',
    storageBucket: 'possystem-e1655.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjjzp6qBMlBvbnv7hBKQR16P4SicqWAMM',
    appId: '1:212072997600:ios:272f5ca99306a8efda2685',
    messagingSenderId: '212072997600',
    projectId: 'possystem-e1655',
    storageBucket: 'possystem-e1655.firebasestorage.app',
    iosBundleId: 'com.example.aronium',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjjzp6qBMlBvbnv7hBKQR16P4SicqWAMM',
    appId: '1:212072997600:ios:272f5ca99306a8efda2685',
    messagingSenderId: '212072997600',
    projectId: 'possystem-e1655',
    storageBucket: 'possystem-e1655.firebasestorage.app',
    iosBundleId: 'com.example.aronium',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCjjzp6qBMlBvbnv7hBKQR16P4SicqWAMM',
    appId: '1:212072997600:android:272f5ca99306a8efda2685',
    messagingSenderId: '212072997600',
    projectId: 'possystem-e1655',
    storageBucket: 'possystem-e1655.firebasestorage.app',
  );
}

