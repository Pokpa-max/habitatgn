import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/screens/home/home_screen.dart';
import 'package:habitatgn/services/authService/auth_service.dart';

final splashScreenViewModelProvider =
    ChangeNotifierProvider((ref) => SplashScreenViewModel(ref));
final splashScreenService = Provider((ref) => AuthService());

class SplashScreenViewModel extends ChangeNotifier {
  final Ref _read;

  SplashScreenViewModel(this._read);

  void checkLoggedIn(BuildContext context) {
    bool isLoggedIn = _read.read(splashScreenService).checkIfLoggedIn();
    if (isLoggedIn) {
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
