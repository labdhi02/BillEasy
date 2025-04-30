import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyAfKRFG3-h7TXgXUyZrBfP5c7tOMxMd8y0',
        projectId: 'extrnalexam',
        storageBucket: 'extrnalexam.firebasestorage.app',
        messagingSenderId: '625100618616',
        appId: '1:625100618616:android:76b5f852af43119e1da68d',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyAfKRFG3-h7TXgXUyZrBfP5c7tOMxMd8y0',
          appId: '1:625100618616:android:76b5f852af43119e1da68d',
          messagingSenderId: '625100618616',
          projectId: 'extrnalexam',
          storageBucket: 'extrnalexam.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'YOUR_IOS_API_KEY',
          appId: 'YOUR_IOS_APP_ID',
          messagingSenderId: 'YOUR_SENDER_ID',
          projectId: 'YOUR_PROJECT_ID',
          storageBucket: 'YOUR_STORAGE_BUCKET',
          iosClientId: 'YOUR_IOS_CLIENT_ID',
          iosBundleId: 'YOUR_IOS_BUNDLE_ID',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
