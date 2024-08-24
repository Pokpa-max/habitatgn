import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/screens/home/home_screen.dart';
import 'package:habitatgn/services/authService/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final splashScreenViewModelProvider =
    ChangeNotifierProvider((ref) => SplashScreenViewModel(ref));
final splashScreenService = Provider((ref) => AuthService());

// Constants for notification
const String kChannelId = 'com.example.habitatgn';
const String kChannelName = 'habitatgn';
const String kChannelDescription = "Nouvelle annonce de logement";

class SplashScreenViewModel extends ChangeNotifier {
  final Ref _ref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  SplashScreenViewModel(this._ref) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _createNotificationChannel();
    // await _requestPermission();

    _configureNotificationHandling();
  }

  void checkLoggedIn(BuildContext context) async {
    final authService = _ref.read(splashScreenService);

    if (authService.checkIfLoggedIn()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  // Notifications

  // Future<void> _requestPermission() async {
  //   await _firebaseMessaging.requestPermission(
  //     alert: true,
  //     badge: true,
  //     sound: true,
  //   );
  // }

  void _configureNotificationHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _displayNotification(message);
      }
    });
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      kChannelId,
      kChannelName,
      description: kChannelDescription,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('sound_notification'),
    );
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _displayNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification == null) return;

    int notificationId = int.parse(message.data['messageId']);
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      kChannelId,
      kChannelName,
      channelDescription: kChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      notificationId,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data['orderId'],
    );
  }
}
