import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:luck_reveal_app/firebase_options.dart';
import 'package:luck_reveal_app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase inicializado correctamente');
    }
  } catch (e) {
    try {
      await Firebase.initializeApp();
    } catch (e2) {
      if (kDebugMode) {
        debugPrint("❌ Firebase no configurado aún o error: $e2");
      }
    }
  }

  runApp(const MyApp());
}
