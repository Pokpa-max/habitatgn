import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/service.dart';
import 'package:habitatgn/services/repairs/repair_servicies.dart';

// Constants for notification
const String kChannelId = 'com.example.habitatgn';
const String kChannelName = 'habitatgn';
const String kChannelDescription = "Nouvelle annonce de logement";

class NotificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> createNotificationChannel() async {
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

  // save token to database

  Future<void> requestUserPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> initializeAndListenForTokenChanges(String userId) async {
    try {
      // Obtenez le jeton initial et enregistrez-le dans la base de données
      await _saveOrUpdateToken(userId);

      // Écoutez les changements de jeton et mettez à jour la base de données
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await _saveOrUpdateToken(userId);
      });
    } catch (e) {
      // Gérer les erreurs
      print("Error managing FCM token: $e");
    }
  }

  Future<void> _saveOrUpdateToken(String userId) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      DocumentReference docRef = _db.collection('userPreferences').doc(userId);
      await docRef.set({'fcmToken': token}, SetOptions(merge: true));
    }
  }

  // Notifications

  void configureNotificationHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _displayNotification(message);
      }
    });
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
      // icon:
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

final notificationProvider =
    ChangeNotifierProvider((ref) => NotificationViewModel());
