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
  final Ref _ref;

  SplashScreenViewModel(this._ref);

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
}
