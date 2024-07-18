import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/authscreen/create_account.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/screens/home/dashbord/dashbord.dart';
import 'package:habitatgn/screens/home/home_screen.dart';
import 'package:habitatgn/services/authService/auth_service.dart';

final authViewModelProvider =
    ChangeNotifierProvider((ref) => AuthViewModel(ref));
final authServiceProvider = Provider((ref) => AuthService());

class AuthViewModel extends ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;
  User? _user;
  User? get user => _user;
  final Ref _read;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCreatingAccount = false;
  bool get isCreatingAccount => _isCreatingAccount;

  AuthViewModel(this._read) {
    _getCurrentUser();
  }
  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    _setLoading(true);
    try {
      final User? user = await _read
          .read(authServiceProvider)
          .signInWithEmailAndPassword(email, password);
      if (user != null) {
        _user = user;
        await fetchUserProfile(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        showErrorMessage(context,
            'Échec de la connexion. Veuillez vérifier vos identifiants.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showErrorMessage(context, 'Utilisateur non trouvé.');
      } else if (e.code == 'wrong-password') {
        showErrorMessage(context, 'Mot de passe incorrect.');
      } else {
        showErrorMessage(context,
            'Une erreur est survenue. Veuillez réessayer. Code d\'erreur: ${e.code}');
      }
    } catch (e) {
      showErrorMessage(
          context, 'Une erreur inattendue est survenue. Veuillez réessayer.');
      print('Erreur inattendue: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    _setLoading(true);
    final User? user =
        await _read.read(authServiceProvider).signInWithFacebook();
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      showErrorMessage(context, 'Échec de la connexion avec Facebook.');
    }
    _setLoading(false);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);
    final User? user = await _read.read(authServiceProvider).signInWithGoogle();
    if (user != null) {
      _user = user;
      await fetchUserProfile(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      showErrorMessage(context, 'Échec de la connexion avec Google.');
    }
    _setLoading(false);
  }

  Future<void> createUserWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
    String displayName,
    String phoneNumber,
  ) async {
    try {
      _setCreatingAccount(true);
      final User? user =
          await _read.read(authServiceProvider).createUserWithEmailAndPassword(
                email,
                password,
                displayName,
                phoneNumber,
              );
      if (user != null) {
        await user.reload();
        _user = _read.watch(authServiceProvider).getCurrentUser();
        await fetchUserProfile(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showErrorMessage(context, 'Le mot de passe est trop faible.');
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage(context, 'L\'adresse email est déjà utilisée.');
      } else {
        showErrorMessage(
            context, 'Une erreur est survenue. Veuillez réessayer.');
      }
    } finally {
      _setCreatingAccount(false);
    }
  }

  void _getCurrentUser() {
    _user = _read.watch(authServiceProvider).getCurrentUser();
    notifyListeners();
  }

  Future<void> fetchUserProfile(context) async {
    try {
      final userProfile =
          await _read.watch(authServiceProvider).getUserProfile();
      if (userProfile != null) {
        _userProfile = userProfile;
        notifyListeners();
      } else {
        showErrorMessage(
            context, 'Échec de la récupération du profil utilisateur.');
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
      (route) => false,
    );
  }

  void showErrorMessage(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void navigateToCreateAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountPage()),
    );
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setCreatingAccount(bool isCreating) {
    _isCreatingAccount = isCreating;
    notifyListeners();
  }
}

// Mise à jour des champs de Visibility
class PasswordVisibilityNotifier extends StateNotifier<bool> {
  PasswordVisibilityNotifier() : super(false);

  void toggleVisibility() {
    state = !state;
  }
}

final passwordVisibilityProvider =
    StateNotifierProvider<PasswordVisibilityNotifier, bool>((ref) {
  return PasswordVisibilityNotifier();
});

final confirmPasswordVisibilityProvider =
    StateNotifierProvider<PasswordVisibilityNotifier, bool>((ref) {
  return PasswordVisibilityNotifier();
});
