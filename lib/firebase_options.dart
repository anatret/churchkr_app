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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDzkG6S69RsLgzXVpcI_8kvLRQ9N7LeRxI',
    appId: '1:128821308227:web:c819671863648b89579df6',
    messagingSenderId: '128821308227',
    projectId: 'churchk',
    authDomain: 'churchk.firebaseapp.com',
    storageBucket: 'churchk.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZ6pDOEWjM3KwHjsNov3DUc5B1BJ9C6U4',
    appId: '1:128821308227:android:cb5e989b81d18c2b579df6',
    messagingSenderId: '128821308227',
    projectId: 'churchk',
    storageBucket: 'churchk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVNBToK4-_8a76Oi1jtZxyXs9BpNT55bo',
    appId: '1:128821308227:ios:247088089f627cb5579df6',
    messagingSenderId: '128821308227',
    projectId: 'churchk',
    storageBucket: 'churchk.firebasestorage.app',
    iosBundleId: 'com.anatret.churchkr',
  );
}
