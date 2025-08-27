import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCsK6NcS7A0xLLxX7z1BHVJdNzlVscmC1E',
    appId: '1:779316830326:web:f9fd0c5098d7543018bf57',
    messagingSenderId: '779316830326',
    projectId: 'seguridadvehicular-11519',
    authDomain: 'seguridadvehicular-11519.firebaseapp.com',
    storageBucket: 'seguridadvehicular-11519.firebasestorage.app',
    measurementId: 'G-XKQJ79K22X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQeS2x7HvCHZBNWpNt7gK6N0RYuw4J99M',
    appId: '1:779316830326:android:e30668fcfebdf96d18bf57',
    messagingSenderId: '779316830326',
    projectId: 'seguridadvehicular-11519',
    storageBucket: 'seguridadvehicular-11519.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDR5Ic2ATAbUPv1UYs1cn5PNYqcUJU6YM',
    appId: '1:779316830326:ios:55eac0c3b4c4a87a18bf57',
    messagingSenderId: '779316830326',
    projectId: 'seguridadvehicular-11519',
    storageBucket: 'seguridadvehicular-11519.firebasestorage.app',
    iosBundleId: 'com.example.seguridadVehicular',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCDR5Ic2ATAbUPv1UYs1cn5PNYqcUJU6YM',
    appId: '1:779316830326:ios:55eac0c3b4c4a87a18bf57',
    messagingSenderId: '779316830326',
    projectId: 'seguridadvehicular-11519',
    storageBucket: 'seguridadvehicular-11519.firebasestorage.app',
    iosBundleId: 'com.example.seguridadVehicular',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCsK6NcS7A0xLLxX7z1BHVJdNzlVscmC1E',
    appId: '1:779316830326:web:ed257a6843683beb18bf57',
    messagingSenderId: '779316830326',
    projectId: 'seguridadvehicular-11519',
    authDomain: 'seguridadvehicular-11519.firebaseapp.com',
    storageBucket: 'seguridadvehicular-11519.firebasestorage.app',
    measurementId: 'G-8DQV2Q22ZK',
  );
}
