import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;

  NotificationService(this._firebaseMessaging);

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
