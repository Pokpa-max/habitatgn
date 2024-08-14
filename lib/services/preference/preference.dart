import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreferencesService {
  final FirebaseFirestore firestore;

  UserPreferencesService(this.firestore);

  Stream<Map<String, bool>> getPreferencesStream(String userId) {
    // Créez un document avec des valeurs par défaut si nécessaire
    _initializeUserPreferences(userId);

    return firestore
        .collection('userPreferences')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() ?? {};

      final housingTypes = [
        'Villa',
        'Maison',
        'Studio',
        'Hôtel',
        'Magasin',
        'Terrain',
        'Duplex',
        'Appartement',
      ];

      return {
        for (var type in housingTypes) type: data[type] ?? false,
        'notificationsEnabled': data['notificationsEnabled'] ?? false,
      };
    });
  }

  Future<void> _initializeUserPreferences(String userId) async {
    final docRef = firestore.collection('userPreferences').doc(userId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'Villa': false,
        'Maison': false,
        'Studio': false,
        'Hôtel': false,
        'Magasin': false,
        'Terrain': false,
        'Duplex': false,
        'Appartement': false,
        'Chantier': false,
        'notificationsEnabled': false,
      });
    }
  }

  Future<void> updatePreference(String userId, String type, bool value) async {
    await firestore.collection('userPreferences').doc(userId).set(
      {
        type: value,
      },
      SetOptions(merge: true),
    );
  }
}
