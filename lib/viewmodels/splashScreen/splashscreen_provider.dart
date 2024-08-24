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

class SplashScreenViewModel extends ChangeNotifier {
  final Ref _read;

  SplashScreenViewModel(this._read);

  // Notifications
  final FirebaseFirestore db = FirebaseFirestore.instance;
  static const String channelId = 'com.example.habitatgn';
  static const String channelName = 'habitatgn';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? fcmToken;

  void checkLoggedIn(BuildContext context) {
    final splashModel = _read.read(splashScreenService);

    // bool isLoggedIn = _read.read(splashScreenService).checkIfLoggedIn();
    if (splashModel.checkIfLoggedIn()) {
      requestPermission();
      listenToTokenChanges(splashModel.getCurrentUser()!.uid);
      saveTokenToDatabase(splashModel.getCurrentUser()!.uid);
      configure();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  // notification with fcm token
  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      DocumentReference docRef = db.collection('userPreferences').doc(userId);
      DocumentSnapshot docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        await docRef.set({
          'fcmToken': token,
        });
      } else {
        await docRef.update({
          'fcmToken': token,
        });
      }
    }
  }

  // Ecouteur pour détecter les changements de token
  void listenToTokenChanges(String userId) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      saveTokenToDatabase(userId);
    });
  }

  void requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void configure() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        displayNotification(message);
      }
    });
  }

  Future createTheAppChannel() async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      channelId,
      channelName,
      description: "Nouvelle annonce de logement",
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('sound_notification'),
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> displayNotification(RemoteMessage message) async {
    RemoteNotification notification = message.notification!;
    int notificationId = int.parse(message.data['messageId']);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      channelId, channelName,
      channelDescription: "Nouvelle annonce de logement",
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      // icon: '@mipmap/ic_launcher'
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: message.data['orderId'],
    );
  }
}
