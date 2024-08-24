import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:habitatgn/screens/splash_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';

import 'firebase_options.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';

//function to listen to background changes

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Bloquer l'orientation en mode portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialiser Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: MyApp()));
}

// Gestion des messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message🎯🎯🎯🎯🎯🎯🎯: ${message.messageId}");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Gestion des messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!🎯🎯🎯🎯');
      _showNotificationDialog(message);
    });

    // Gérer les messages lorsque l'application est ouverte via une notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!🎯🎯🎯🎯🎯🎯');
      _navigateToHouseDetails(message);
    });

    // Vérifier si l'application a été ouverte par une notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _navigateToHouseDetails(message);
      }
    });
  }

  void _showNotificationDialog(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message.notification?.title ?? 'Notification'),
          content: Text(message.notification?.body ?? 'No message body'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHouseDetails(RemoteMessage message) {
    // Récupérer l'identifiant de la maison à partir des données de la notification
    final String? houseId = message.data['houseId'];

    if (houseId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HouseDetailScreen(houseId: houseId),
        ),
      );
    } else {
      print('House ID not found in notification data');
    }
  }

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
