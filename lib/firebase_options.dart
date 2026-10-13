// File generated for RoomSearch App Firebase connection.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDnDVncp77F86lYS2-3OL8Lau6XS847Sao',
    appId: '1:10679797683:web:a1ef69421f8877af022dc6',
    messagingSenderId: '10679797683',
    projectId: 'roomsearch-67bc8',
    storageBucket: 'roomsearch-67bc8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnDVncp77F86lYS2-3OL8Lau6XS847Sao',
    appId: '1:10679797683:android:a1ef69421f8877af022dc6',
    messagingSenderId: '10679797683',
    projectId: 'roomsearch-67bc8',
    storageBucket: 'roomsearch-67bc8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnDVncp77F86lYS2-3OL8Lau6XS847Sao',
    appId: '1:10679797683:ios:a1ef69421f8877af022dc6',
    messagingSenderId: '10679797683',
    projectId: 'roomsearch-67bc8',
    storageBucket: 'roomsearch-67bc8.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDnDVncp77F86lYS2-3OL8Lau6XS847Sao',
    appId: '1:10679797683:ios:a1ef69421f8877af022dc6',
    messagingSenderId: '10679797683',
    projectId: 'roomsearch-67bc8',
    storageBucket: 'roomsearch-67bc8.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDnDVncp77F86lYS2-3OL8Lau6XS847Sao',
    appId: '1:10679797683:web:a1ef69421f8877af022dc6',
    messagingSenderId: '10679797683',
    projectId: 'roomsearch-67bc8',
    storageBucket: 'roomsearch-67bc8.firebasestorage.app',
  );
}
