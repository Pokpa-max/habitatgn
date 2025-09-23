// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitatgn/models/house_result_model.dart';

class HouseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<House?> getHouseById(String houseId) async {
    try {
      final doc = await _firestore.collection('houses').doc(houseId).get();
      if (!doc.exists) return null;
      return House.fromFirestore(doc);
    } catch (e) {
      print('Error fetching house by id: $e');
      return null;
    }
  }

  // Utilisateur courant
  Future<User?> getCurrentUser() async => _auth.currentUser;

  /// Logements récents (toujours côté Firestore)
  Future<List<House>> getRecentHouses({int limit = 10}) async {
    try {
      final snap = await _firestore
          .collection('houses')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map(House.fromFirestore).toList();
    } catch (e) {
      print('Error fetching recent houses: $e');
      return [];
    }
  }

  /// Pagination "tous les logements" (sans recherche avancée)
  Future<List<House>> getHouses({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query q = _firestore
          .collection('houses')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        q = q.startAfterDocument(lastDocument);
      }

      final snap = await q.get();
      return snap.docs.map(House.fromFirestore).toList();
    } catch (e) {
      print('Error fetching houses: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 🚀 Nouvelle méthode unifiée : RECHERCHE + FILTRES côté Firestore + pagination
  // ────────────────────────────────────────────────────────────────────────────
  Future<List<House>> searchAndFilterHouses({
    // Recherche plein-texte (multi-champs) basée sur searchTokens
    String query = '',
    // Filtres
    double? minPrice,
    double? maxPrice,
    String needType = 'Tous', // 'Tous' | 'Louer' | 'Acheter'
    String propertyType = 'Tous', // 'Tous' | 'Villa' | 'Maison' | ...
    String ville = '', // ex: "Ratoma", "Conakry", "Lambanyi"
    int bedrooms = 0,
    // Pagination
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query q =
          _firestore.collection('houses').where('isAvailable', isEqualTo: true);

      // Type de besoin (normalisé Firestore: 'Louer' | 'Vendre')
      if (needType != 'Tous') {
        final offer = (needType == 'Acheter') ? 'Vendre' : 'Louer';
        q = q.where('offerType.value', isEqualTo: offer);
      }

      // Type de propriété (valeur en minuscules dans Firestore)
      if (propertyType != 'Tous') {
        q = q.where('houseType.value',
            isEqualTo: propertyType.trim().toLowerCase());
      }

      // Lieux: unifie ville/commune/quartier via 'places' (array-contains)
      final villeNorm = _normalize(ville);
      if (villeNorm.isNotEmpty) {
        q = q.where('places', arrayContains: villeNorm);
      }

      // Chambres exactes
      if (bedrooms > 0) {
        q = q.where('bedrooms', isEqualTo: bedrooms);
      }

      // Budget
      if (minPrice != null) {
        q = q.where('price', isGreaterThanOrEqualTo: minPrice.toInt());
      }
      if (maxPrice != null && maxPrice.isFinite) {
        q = q.where('price', isLessThanOrEqualTo: maxPrice.toInt());
      }

      // Recherche plein-texte simple via tokens
      final tokens = _toQueryTokens(query);
      if (tokens.isNotEmpty) {
        // Firestore: array-contains-any <= 10 éléments
        q = q.where('searchTokens', arrayContainsAny: tokens.take(10).toList());
      }

      // Tri + pagination
      q = q.orderBy('createdAt', descending: true).limit(limit);
      if (lastDocument != null) {
        q = q.startAfterDocument(lastDocument);
      }

      final snap = await q.get();
      return snap.docs.map(House.fromFirestore).toList();
    } catch (e) {
      print('Error searchAndFilterHouses: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ✅ Compat: ancien nom pour ne pas casser l’appelant (appelle la nouvelle API)
  // ────────────────────────────────────────────────────────────────────────────
  Future<List<House>> fetchFilteredHouses({
    required double minPrice,
    required double maxPrice,
    required String needType,
    required String propertyType,
    required String ville,
    required int bedrooms,
    // (Optionnel) supporte pagination si tu veux
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String query = '',
  }) {
    return searchAndFilterHouses(
      query: query,
      minPrice: minPrice > 0 ? minPrice : null,
      maxPrice: (maxPrice.isFinite && maxPrice > 0) ? maxPrice : null,
      needType: needType,
      propertyType: propertyType,
      ville: ville,
      bedrooms: bedrooms,
      lastDocument: lastDocument,
      limit: limit,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Favorites
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> addFavorite(String houseId) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(houseId)
          .set({'houseId': houseId});
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String houseId) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(houseId)
          .delete();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<bool> isFavorite(String houseId) async {
    try {
      final userId = _auth.currentUser!.uid;
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(houseId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<List<House>> getFavorites() async {
    try {
      final userId = _auth.currentUser!.uid;
      final favSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      final ids = favSnap.docs.map((d) => d.id).toList();
      final out = <House>[];
      for (final id in ids) {
        final h = await getHouseById(id);
        if (h != null) out.add(h);
      }
      return out;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers normalisation / tokens
  // ────────────────────────────────────────────────────────────────────────────

  /// Normalise une chaîne: lowercase + suppression approximative des accents
  /// Normalise une chaîne: lowercase + suppression approximative des accents
  String _normalize(String input) {
    if (input.isEmpty) return '';
    final lower = input.toLowerCase();

    // Remplacement simple de quelques diacritiques courants
    const src = 'àâäáãåçèéêëìíîïñòóôöõùúûüýÿœæ';
    const dst = 'aaaaaaceeeeiiiinooooouuuuyyoeae';

    final map = <String, String>{};
    for (int i = 0; i < src.length; i++) {
      map[src[i]] = dst[i];
    }

    final buf = StringBuffer();
    for (int i = 0; i < lower.length; i++) {
      final ch = lower[i];
      buf.write(map[ch] ?? ch);
    }
    return buf.toString().trim();
  }

  /// Transforme la requête utilisateur en tokens (>=3 chars) pour array-contains-any
  List<String> _toQueryTokens(String q) {
    final norm = _normalize(q);
    if (norm.isEmpty) return [];
    return norm.split(RegExp(r'\s+')).where((t) => t.length >= 3).toList();
  }
}
