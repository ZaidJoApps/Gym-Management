import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyAMaIo--OHhP41IDVYpPwHF27zjHRCoWk4',
        appId: '1:1084865897218:web:9e71a749dc9373b8b2981b',
        messagingSenderId: '1084865897218',
        projectId: 'gym-managment-2b975',
        authDomain: 'gym-managment-2b975.firebaseapp.com',
        storageBucket: 'gym-managment-2b975.firebasestorage.app',
        measurementId: 'G-LQEMQXJ2ZV',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyAqw9GMuYZUdly7ocQ5QQVWoYGFwMg-iRw',
          appId: '1:1084865897218:android:0eb703cb2ff50addb2981b',
          messagingSenderId: '1084865897218',
          projectId: 'gym-managment-2b975',
          storageBucket: 'gym-managment-2b975.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
} 