import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/screens/home/home_screen.dart';
import 'package:habitatgn/services/authService/auth_service.dart';

final authViewModelProvider =
    ChangeNotifierProvider((ref) => AuthViewModel(ref));
final authService = Provider((ref) => AuthService());

class AuthViewModel extends ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;
  User? _user;
  User? get user => _user;
  final Ref _read;

  AuthViewModel(this._read) {
    _getCurrentUser();
  }
  // Authentification avec Facebook
  Future<void> signInWithFacebook(BuildContext context) async {
    final User? user = await _read.read(authService).signInWithFacebook();
    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      showErrorMessage(context, 'Échec de la connexion avec Facebook.');
    }
    notifyListeners();
  }

  // Authentification avec Google
  Future<void> signInWithGoogle(BuildContext context) async {
    final User? user = await _read.read(authServiceProvider).signInWithGoogle();
    if (user != null) {
      _user = user;
      await fetchUserProfile(
          context); // Mettez à jour le profil après connexion
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      showErrorMessage(context, 'Échec de la connexion avec Google.');
    }
    notifyListeners();
  }

  void _getCurrentUser() {
    _user = _read.watch(authServiceProvider).getCurrentUser();
    notifyListeners();
  }

  // Récupère les informations de l'utilisateur à partir du service Firestore
  Future<void> fetchUserProfile(context) async {
    try {
      final userProfile = await _read.watch(authService).getUserProfile();
      if (userProfile != null) {
        _userProfile = userProfile;
        notifyListeners();
      } else {
        showErrorMessage(context, 'Échec de la connexion avec Google.');
        print(
            'Erreur: Impossible de récupérer les informations du profil utilisateur');
      }
    } catch (e) {
      print('Erreur lors de la récupération du profil utilisateur: $e');
    }
  }

  void signOut(BuildContext context) async {
    await _read.read(authServiceProvider).signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
      (route) => false, // Supprime toutes les autres routes
    );
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
