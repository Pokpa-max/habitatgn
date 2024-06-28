import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Vérifie si l'utilisateur est connecté
  bool checkIfLoggedIn() {
    User? user = _auth.currentUser;
    return user != null;
  }

  // Authentification avec Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final AuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        User? user = userCredential.user;

        // Vérifier si l'utilisateur est nouvellement créé
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          // Créer un document utilisateur dans Firestore
          await _firestore.collection('users').doc(user!.uid).set({
            'displayName': user.displayName ?? '',
            'email': user.email ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'photoURL': user.photoURL ?? '',
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }

        return user;
      }
    } catch (e) {
      print('Erreur de connexion Facebook: $e');
    }
    return null;
  }

  // Authentification avec Google

  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser != null) {
  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;

  //       final AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );

  //       final UserCredential userCredential =
  //           await _auth.signInWithCredential(credential);

  //       // Récupérer l'utilisateur actuel
  //       User? user = userCredential.user;

  //       // Vérifier si l'utilisateur est nouvellement créé
  //       if (userCredential.additionalUserInfo?.isNewUser ?? false) {
  //         // Créer un document utilisateur dans Firestore
  //         await _firestore.collection('users').doc(user!.uid).set({
  //           'displayName': user.displayName ?? '',
  //           'email': user.email ?? '',
  //           'phoneNumber': user.phoneNumber ?? '',
  //           'photoURL': user.photoURL ?? '',
  //           'createdAt': Timestamp.now(),
  //           'updatedAt': Timestamp.now(),
  //         });
  //       }

  //       return user;
  //     }
  //   } catch (e) {
  //     print('Erreur de connexion Google: $e');
  //   }
  //   return null;
  // }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _firestore.collection('users').doc(user!.uid).set({
            'displayName': user.displayName ?? '',
            'email': user.email ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'photoURL': user.photoURL ?? '',
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }

        return user;
      }
    } catch (e) {
      print('Erreur de connexion Google: $e');
    }
    return null;
  }

  // Authentification par email et mot de passe
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Erreur de connexion: $e');
      return null;
    }
  }

  //recupereration de lutilisateur courant
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Récupère les informations de l'utilisateur à partir de Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userProfile =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      return userProfile.data();
    } catch (e) {
      print('Erreur lors de la récupération du profil utilisateur: $e');
      return null;
    }
  }

  // Déconnexion de l'utilisateur
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
