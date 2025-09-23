import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/authscreen/create_account.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/screens/favoris/favoris.dart';
import 'package:habitatgn/screens/home/home_screen.dart';
import 'package:habitatgn/services/authService/auth_service.dart';
import 'package:habitatgn/utils/appColors.dart';

// Providers
final authViewModelProvider =
    ChangeNotifierProvider((ref) => AuthViewModel(ref));
final authServiceProvider = Provider((ref) => AuthService());

// État pour la gestion des loading states
enum AuthLoadingState { idle, signIn, signUp, socialAuth, resetPassword }

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref _ref;

  // État utilisateur
  User? _user;
  Map<String, dynamic>? _userProfile;

  // États de chargement
  AuthLoadingState _loadingState = AuthLoadingState.idle;

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _loadingState != AuthLoadingState.idle;
  bool get isSigningIn => _loadingState == AuthLoadingState.signIn;
  bool get isSigningUp => _loadingState == AuthLoadingState.signUp;
  bool get isSocialAuthLoading => _loadingState == AuthLoadingState.socialAuth;
  bool get isResettingPassword =>
      _loadingState == AuthLoadingState.resetPassword;

  AuthViewModel(this._ref) {
    _getCurrentUser();
  }

  // ==================== AUTHENTIFICATION ====================

  /// Connexion avec email et mot de passe
  Future<void> signInWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
  ) async {
    await _executeAuthAction(
      context: context,
      loadingState: AuthLoadingState.signIn,
      action: () async {
        final user = await _ref
            .read(authServiceProvider)
            .signInWithEmailAndPassword(email, password);

        if (user != null) {
          await _handleSuccessfulAuth(context, user);
        } else {
          _showErrorMessage(
            context,
            'Échec de la connexion. Vérifiez vos identifiants.',
            MessageType.error,
          );
        }
      },
      errorHandler: _handleSignInErrors,
    );
  }

  /// Création de compte
  Future<void> createUserWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
    String displayName,
  ) async {
    await _executeAuthAction(
      context: context,
      loadingState: AuthLoadingState.signUp,
      action: () async {
        final user = await _ref
            .read(authServiceProvider)
            .createUserWithEmailAndPassword(email, password, displayName);

        if (user != null) {
          await user.reload();
          await _handleSuccessfulAuth(context, user);
        }
      },
      errorHandler: _handleSignUpErrors,
    );
  }

  /// Connexion avec Google
  Future<void> signInWithGoogle(BuildContext context) async {
    await _executeAuthAction(
      context: context,
      loadingState: AuthLoadingState.socialAuth,
      action: () async {
        final user = await _ref.read(authServiceProvider).signInWithGoogle();

        if (user != null) {
          await _handleSuccessfulAuth(context, user);
        } else {
          _showErrorMessage(
            context,
            'Échec de la connexion avec Google',
            MessageType.error,
          );
        }
      },
    );
  }

  /// Connexion avec Facebook
  Future<void> signInWithFacebook(BuildContext context) async {
    await _executeAuthAction(
      context: context,
      loadingState: AuthLoadingState.socialAuth,
      action: () async {
        final user = await _ref.read(authServiceProvider).signInWithFacebook();

        if (user != null) {
          await _handleSuccessfulAuth(context, user);
        } else {
          _showErrorMessage(
            context,
            'Échec de la connexion avec Facebook',
            MessageType.error,
          );
        }
      },
    );
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(BuildContext context, String email) async {
    await _executeAuthAction(
      context: context,
      loadingState: AuthLoadingState.resetPassword,
      action: () async {
        await _ref.read(authServiceProvider).resetPassword(email);
        _showErrorMessage(
          context,
          'Email de réinitialisation envoyé',
          MessageType.success,
        );
      },
      errorHandler: _handleResetPasswordErrors,
    );
  }

  // ==================== GESTION DES UTILISATEURS ====================

  /// Déconnexion
  Future<void> signOut(BuildContext context) async {
    try {
      await _ref.read(authServiceProvider).signOut();
      _clearUserData();
      _navigateToLogin(context);
    } catch (e) {
      _showErrorMessage(
        context,
        'Erreur lors de la déconnexion',
        MessageType.error,
      );
      print('Erreur déconnexion: $e');
    }
  }

  /// Vérifier si l'utilisateur est connecté
  bool checkIfLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Récupérer le profil utilisateur
  Future<void> fetchUserProfile(BuildContext context) async {
    try {
      final userProfile = await _ref.read(authServiceProvider).getUserProfile();

      if (userProfile != null) {
        _userProfile = userProfile;
        notifyListeners();
      } else {
        _showErrorMessage(
          context,
          'Impossible de récupérer le profil utilisateur',
          MessageType.warning,
        );
      }
    } catch (e) {
      print('Erreur récupération profil: $e');
      _showErrorMessage(
        context,
        'Erreur lors du chargement du profil',
        MessageType.error,
      );
    }
  }

  // ==================== NAVIGATION ====================

  void navigateToCreateAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountPage()),
    );
  }

  void navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Exécuter une action d'authentification avec gestion d'état
  Future<void> _executeAuthAction({
    required BuildContext context,
    required AuthLoadingState loadingState,
    required Future<void> Function() action,
    void Function(BuildContext, FirebaseAuthException)? errorHandler,
  }) async {
    if (!context.mounted) return;

    _setLoadingState(loadingState);

    try {
      await action();
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (errorHandler != null) {
          errorHandler(context, e);
        } else {
          _handleGenericAuthError(context, e);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(
          context,
          'Une erreur inattendue est survenue',
          MessageType.error,
        );
      }
      print('Erreur inattendue: $e');
    } finally {
      _setLoadingState(AuthLoadingState.idle);
    }
  }

  /// Gérer une authentification réussie
  Future<void> _handleSuccessfulAuth(BuildContext context, User user) async {
    _user = user;
    await fetchUserProfile(context);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  /// Gestionnaires d'erreurs spécifiques
  void _handleSignInErrors(BuildContext context, FirebaseAuthException e) {
    final message = switch (e.code) {
      'user-not-found' => 'Aucun compte trouvé avec cette adresse email',
      'wrong-password' => 'Mot de passe incorrect',
      'user-disabled' => 'Ce compte a été désactivé',
      'too-many-requests' => 'Trop de tentatives. Réessayez plus tard',
      'invalid-email' => 'Adresse email invalide',
      'invalid-credential' => 'Identifiants invalides',
      _ => 'Erreur de connexion. Vérifiez vos identifiants',
    };

    _showErrorMessage(context, message, MessageType.error);
  }

  void _handleSignUpErrors(BuildContext context, FirebaseAuthException e) {
    final message = switch (e.code) {
      'weak-password' => 'Le mot de passe est trop faible',
      'email-already-in-use' => 'Cette adresse email est déjà utilisée',
      'invalid-email' => 'Adresse email invalide',
      'operation-not-allowed' => 'Inscription temporairement désactivée',
      _ => 'Erreur lors de la création du compte',
    };

    _showErrorMessage(context, message, MessageType.error);
  }

  void _handleResetPasswordErrors(
      BuildContext context, FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-email' => 'Adresse email invalide',
      'too-many-requests' => 'Trop de demandes. Réessayez plus tard',
      'user-not-found' => 'Email de réinitialisation envoyé',
      _ => 'Erreur lors de l\'envoi. Réessayez plus tard',
    };

    final messageType = e.code == 'user-not-found'
        ? MessageType.success // Pour ne pas révéler si l'email existe
        : MessageType.warning;

    _showErrorMessage(context, message, messageType);
  }

  void _handleGenericAuthError(BuildContext context, FirebaseAuthException e) {
    _showErrorMessage(
      context,
      'Une erreur est survenue. Veuillez réessayer',
      MessageType.error,
    );
    print('Erreur Firebase Auth: ${e.code} - ${e.message}');
  }

  /// Gestion de l'état
  void _setLoadingState(AuthLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _getCurrentUser() {
    _user = _ref.read(authServiceProvider).getCurrentUser();
    notifyListeners();
  }

  void _clearUserData() {
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
// navigate de favoris screen

  void navigateToFavoriScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => FavoritesPage()),
      (route) => false,
    );
  }

  /// Gestion des messages
  void _showErrorMessage(
    BuildContext context,
    String message,
    MessageType type,
  ) {
    if (!context.mounted) return;

    final color = switch (type) {
      MessageType.success => primaryColor,
      MessageType.error => Colors.red[700],
      MessageType.warning => Colors.black54,
      MessageType.info => Colors.grey,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Gestion des messages
  void showErrorMessage(BuildContext context, String message, {Color? color}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ==================== ÉNUMÉRATIONS ET TYPES ====================

enum MessageType { success, error, warning, info }

// ==================== PROVIDERS POUR LA VISIBILITÉ DES MOTS DE PASSE ====================

class PasswordVisibilityNotifier extends StateNotifier<bool> {
  PasswordVisibilityNotifier() : super(false);

  void toggleVisibility() {
    state = !state;
  }

  void setVisibility(bool isVisible) {
    state = isVisible;
  }

  void hide() => state = false;
  void show() => state = true;
}

final passwordVisibilityProvider =
    StateNotifierProvider<PasswordVisibilityNotifier, bool>((ref) {
  return PasswordVisibilityNotifier();
});

final confirmPasswordVisibilityProvider =
    StateNotifierProvider<PasswordVisibilityNotifier, bool>((ref) {
  return PasswordVisibilityNotifier();
});

// ==================== EXTENSIONS UTILES ====================

extension BuildContextExtension on BuildContext {
  bool get mounted {
    try {
      widget;
      return true;
    } catch (e) {
      return false;
    }
  }
}
