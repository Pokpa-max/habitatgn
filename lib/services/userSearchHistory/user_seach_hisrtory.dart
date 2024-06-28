import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/models/userSearchHistory/user_seach_history.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid; // ID de l'utilisateur connecté

  FirestoreService({required this.uid});

  // Ajouter une recherche à l'historique
  Future<void> addSearchToHistory(Map<String, dynamic> data) async {
    try {
      await _db.collection('searchHistory').add({
        'uid': uid,
        ...data,
      });
    } catch (e) {
      print('Error adding search to history: $e');
    }
  }

  // Récupérer l'historique des recherches de l'utilisateur
  Stream<List<UserSearchHistory>> getSearchHistory() {
    try {
      return _db
          .collection('searchHistory')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => UserSearchHistory(
                    query: doc['query'],
                    timestamp: (doc['timestamp'] as Timestamp).toDate(),
                  ))
              .toList());
    } catch (e) {
      print('Error getting search history: $e');
      throw Exception(
          'Erreur lors de la récupération de l\'historique de recherche');
    }
  }

  // Supprimer une recherche de l'historique (en option)
  Future<void> deleteSearchFromHistory(String documentId) async {
    try {
      await _db.collection('searchHistory').doc(documentId).delete();
    } catch (e) {
      print('Error deleting search from history: $e');
    }
  }
}
