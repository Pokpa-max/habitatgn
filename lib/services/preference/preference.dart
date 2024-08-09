import 'package:cloud_firestore/cloud_firestore.dart';

// class UserPreferencesService {
//   final FirebaseFirestore firestore;

//   UserPreferencesService(this.firestore);

//   Future<Map<String, bool>> getPreferences(String userId) async {
//     final doc = await firestore.collection('userPreferences').doc(userId).get();
//     final data = doc.data() ?? {};
//     final housingTypes = [
//       'Villa',
//       'Maison',
//       'Studio',
//       'Hôtel',
//       'Magasin',
//       'Terrain',
//       'Duplex',
//       'Appartement',
//       'Chantier',
//     ];

//     return {for (var type in housingTypes) type: data[type] ?? false};
//   }

//   Future<void> updatePreference(String userId, String type, bool value) async {
//     await firestore.collection('userPreferences').doc(userId).set(
//       {
//         type: value,
//       },
//       SetOptions(merge: true),
//     );
//   }

//   Future<void> saveFCMToken(String userId, String token) async {
//     await firestore.collection('userPreferences').doc(userId).set(
//       {
//         'fcmToken': token,
//       },
//       SetOptions(merge: true),
//     );
//   }
// }

class UserPreferencesService {
  final FirebaseFirestore firestore;

  UserPreferencesService(this.firestore);

  Stream<Map<String, bool>> getPreferencesStream(String userId) {
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
        'Chantier',
      ];

      return {
        for (var type in housingTypes) type: data[type] ?? false,
        'notificationsEnabled': data['notificationsEnabled'],
      };
    });
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
