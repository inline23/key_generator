import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:key_generation/firebase_options.dart';
import 'package:key_generation/key_generation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KeyGeneratorPage(),
    );
  }
}