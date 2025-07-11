// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyAij4X-wGcg-A2YCSbhTKhK0sB0Y-dc_us',
    appId: '1:758818844805:web:74a47797e9289b1e08b9ec',
    messagingSenderId: '758818844805',
    projectId: 'tugas-appcatering',
    authDomain: 'tugas-appcatering.firebaseapp.com',
    storageBucket: 'tugas-appcatering.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQs7nHe-bTJ1fZ2e7zBDA7fLiBqvOfGOg',
    appId: '1:758818844805:android:6a62631d3e2a674c08b9ec',
    messagingSenderId: '758818844805',
    projectId: 'tugas-appcatering',
    storageBucket: 'tugas-appcatering.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCO3hD8AWaku24_ak5_NuZ9_tJasB0-Dj8',
    appId: '1:758818844805:ios:002f7d95280c7d3308b9ec',
    messagingSenderId: '758818844805',
    projectId: 'tugas-appcatering',
    storageBucket: 'tugas-appcatering.firebasestorage.app',
    iosBundleId: 'com.example.tugasAppcatering',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCO3hD8AWaku24_ak5_NuZ9_tJasB0-Dj8',
    appId: '1:758818844805:ios:002f7d95280c7d3308b9ec',
    messagingSenderId: '758818844805',
    projectId: 'tugas-appcatering',
    storageBucket: 'tugas-appcatering.firebasestorage.app',
    iosBundleId: 'com.example.tugasAppcatering',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAij4X-wGcg-A2YCSbhTKhK0sB0Y-dc_us',
    appId: '1:758818844805:web:085681474d8a713e08b9ec',
    messagingSenderId: '758818844805',
    projectId: 'tugas-appcatering',
    authDomain: 'tugas-appcatering.firebaseapp.com',
    storageBucket: 'tugas-appcatering.firebasestorage.app',
  );

}