// Généré automatiquement à partir de google-services.json
// Projet Firebase : ecoscan-8795b

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgRPJODaZKUoL6n8EtvdurewDGDxwjtPQ',
    appId: '1:1089511172826:android:d08252852004f3627313e3',
    messagingSenderId: '1089511172826',
    projectId: 'ecoscan-8795b',
    storageBucket: 'ecoscan-8795b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNasOM7ubORnz6lzws_QAVoxCIbhL3sKI',
    appId: '1:1089511172826:ios:b057c4caa512c6757313e3',
    messagingSenderId: '1089511172826',
    projectId: 'ecoscan-8795b',
    storageBucket: 'ecoscan-8795b.firebasestorage.app',
    androidClientId: '1089511172826-khbf57bsjcepc8s7ppm1cb9erbv7uim3.apps.googleusercontent.com',
    iosClientId: '1089511172826-i7ov6am9mpkq72ip0feci0jugbd67sal.apps.googleusercontent.com',
    iosBundleId: 'com.ecoscan.ecoscan',
  );

}