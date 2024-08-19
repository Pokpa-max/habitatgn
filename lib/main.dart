import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // Importez ce package pour verrouiller l'orientation
import 'package:habitatgn/screens/splash_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Bloquer l'orientation en mode portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitatGN',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(primaryColor),
          trackColor: WidgetStateProperty.all(primaryColor.withOpacity(0.1)),
        ),
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
