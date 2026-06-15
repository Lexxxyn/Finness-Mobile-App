import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return desktop;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return mobile;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAGOOYVbN4TdeBtbCLuGo7sInAunzBsb90',
    authDomain: 'finness-cf59a.firebaseapp.com',
    databaseURL: 'https://finness-cf59a-default-rtdb.firebaseio.com',
    projectId: 'finness-cf59a',
    storageBucket: 'finness-cf59a.firebasestorage.app',
    messagingSenderId: '593758710208',
    appId: '1:593758710208:web:c77d9476dd239bac9a4025',
    measurementId: 'G-32KG9GF36W',
  );

  static const FirebaseOptions mobile = FirebaseOptions(
    apiKey: 'AIzaSyAGOOYVbN4TdeBtbCLuGo7sInAunzBsb90',
    appId: '1:593758710208:web:c77d9476dd239bac9a4025',
    messagingSenderId: '593758710208',
    projectId: 'finness-cf59a',
    databaseURL: 'https://finness-cf59a-default-rtdb.firebaseio.com',
    storageBucket: 'finness-cf59a.firebasestorage.app',
  );

  static const FirebaseOptions desktop = FirebaseOptions(
    apiKey: 'AIzaSyAGOOYVbN4TdeBtbCLuGo7sInAunzBsb90',
    appId: '1:593758710208:web:c77d9476dd239bac9a4025',
    messagingSenderId: '593758710208',
    projectId: 'finness-cf59a',
    databaseURL: 'https://finness-cf59a-default-rtdb.firebaseio.com',
    storageBucket: 'finness-cf59a.firebasestorage.app',
  );
}
