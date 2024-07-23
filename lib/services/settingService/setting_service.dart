import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(
      String name, String email, String subject, String message) async {
    try {
      await _firestore.collection('contacts').add({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message : $e');
    }
  }

  // Future<void> changePassword(
  //     String currentPassword, String newPassword) async {
  //   try {
  //     User? user = _auth.currentUser;
  //     if (user != null) {
  //       // Créer un credential de réauthentification avec l'email et le mot de passe actuels
  //       AuthCredential credential = EmailAuthProvider.credential(
  //           email: user.email!, password: currentPassword);

  //       // Réauthentifier l'utilisateur
  //       await user.reauthenticateWithCredential(credential);

  //       // Si la réauthentification réussit, changer le mot de passe
  //       await user.updatePassword(newPassword);
  //     } else {
  //       throw Exception('Utilisateur non connecté');
  //     }
  //   } catch (e) {
  //     throw Exception('Erreur lors du changement de mot de passe : $e');
  //   }
  // }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Créer un credential de réauthentification avec l'email et le mot de passe actuels
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);

        // Réauthentifier l'utilisateur
        await user.reauthenticateWithCredential(credential);

        // Si la réauthentification réussit, changer le mot de passe
        await user.updatePassword(newPassword);
      } else {
        throw Exception('Utilisateur non connecté');
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Le mot de passe actuel est incorrect.');
        case 'weak-password':
          throw Exception('Le nouveau mot de passe est trop faible.');
        case 'requires-recent-login':
          throw Exception('Veuillez vous reconnecter et réessayer.');
        default:
          throw Exception(
              'Erreur lors du changement de mot de passe : ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de mot de passe : $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw Exception('Utilisateur non connecté');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du compte : $e');
    }
  }
}
