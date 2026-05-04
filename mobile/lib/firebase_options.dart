// File created for FlutterFire compatibility. Replace by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Until then, push (FCM) is skipped when [isConfigured] is false.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static bool get isConfigured =>
      currentPlatform.projectId.isNotEmpty && !currentPlatform.projectId.startsWith('REPLACE');

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web Firebase options not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Firebase options not configured for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ANDROID_API_KEY',
    appId: 'REPLACE_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_IOS_API_KEY',
    appId: 'REPLACE_IOS_APP_ID',
    messagingSenderId: 'REPLACE_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
    iosBundleId: 'com.ebomi.ims.imsMobile',
  );
}
