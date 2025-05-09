import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBoJJ7_kvzqviZCYdkBugspZFwzGadRej0",
    authDomain: "picktolight-ae00d.firebaseapp.com",
    projectId: "picktolight-ae00d",
    storageBucket: "picktolight-ae00d.firebasestorage.app",
    messagingSenderId: "202424309167",
    appId: "1:202424309167:web:8927900038a3047e820b5a",
    databaseURL: "https://picktolight-ae00d-default-rtdb.firebaseio.com"
 // ← 🔥 agregado manualmente
  );
}
