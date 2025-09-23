// ignore_for_file: avoid_print

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

  Future<User?> getCurrentUser() async => _auth.currentUser;

  /// Logements récents optimisés
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

  /// Pagination pour tous les logements
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

  /// 🚀 RECHERCHE ET FILTRES OPTIMISÉS avec structure existante
  Future<List<House>> searchAndFilterHouses({
    String query = '',
    double? minPrice,
    double? maxPrice,
    String needType = 'Tous',
    String propertyType = 'Tous',
    String ville = '',
    int bedrooms = 0,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      // Pour une recherche textuelle, on fait une approche mixte
      if (query.trim().isNotEmpty) {
        return _performTextSearchWithFilters(
          query: query.trim(),
          minPrice: minPrice,
          maxPrice: maxPrice,
          needType: needType,
          propertyType: propertyType,
          ville: ville,
          bedrooms: bedrooms,
          lastDocument: lastDocument,
          limit: limit,
        );
      }

      // Sinon, recherche par filtres uniquement (plus performante)
      return _performFilterOnlySearch(
        minPrice: minPrice,
        maxPrice: maxPrice,
        needType: needType,
        propertyType: propertyType,
        ville: ville,
        bedrooms: bedrooms,
        lastDocument: lastDocument,
        limit: limit,
      );
    } catch (e) {
      print('Error searchAndFilterHouses: $e');
      return [];
    }
  }

  /// Recherche par filtres uniquement (optimal pour Firestore)
  Future<List<House>> _performFilterOnlySearch({
    double? minPrice,
    double? maxPrice,
    String needType = 'Tous',
    String propertyType = 'Tous',
    String ville = '',
    int bedrooms = 0,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query q =
        _firestore.collection('houses').where('isAvailable', isEqualTo: true);

    // 1. Filtre par type d'offre (normalisation)
    if (needType != 'Tous') {
      final offerValue = needType == 'Acheter' ? 'Vendre' : needType;
      q = q.where('offerType.value', isEqualTo: offerValue);
    }

    // 2. Filtre par type de propriété
    if (propertyType != 'Tous') {
      final normalizedType = _normalizePropertyType(propertyType);
      q = q.where('houseType.value', isEqualTo: normalizedType);
    }

    // 3. Filtre par prix (ordre optimisé pour les index)
    if (minPrice != null && maxPrice != null && maxPrice.isFinite) {
      // Range query - nécessite un index composite
      q = q
          .where('price', isGreaterThanOrEqualTo: minPrice.toInt())
          .where('price', isLessThanOrEqualTo: maxPrice.toInt());
    } else if (minPrice != null) {
      q = q.where('price', isGreaterThanOrEqualTo: minPrice.toInt());
    } else if (maxPrice != null && maxPrice.isFinite) {
      q = q.where('price', isLessThanOrEqualTo: maxPrice.toInt());
    }

    // 4. Filtre par chambres
    if (bedrooms > 0) {
      q = q.where('bedrooms', isEqualTo: bedrooms);
    }

    // 5. Tri et pagination
    q = q.orderBy('createdAt', descending: true).limit(limit);

    if (lastDocument != null) {
      q = q.startAfterDocument(lastDocument);
    }

    final snap = await q.get();
    var results = snap.docs.map(House.fromFirestore).toList();

    // 6. Filtre géographique côté client (car structure complexe dans Firestore)
    if (ville.trim().isNotEmpty) {
      results = _filterByLocation(results, ville);
    }

    return results;
  }

  /// Recherche textuelle avec filtres (approche hybride)
  Future<List<House>> _performTextSearchWithFilters({
    required String query,
    double? minPrice,
    double? maxPrice,
    String needType = 'Tous',
    String propertyType = 'Tous',
    String ville = '',
    int bedrooms = 0,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    // Pour la recherche textuelle, on récupère plus de données et on filtre côté client
    Query q =
        _firestore.collection('houses').where('isAvailable', isEqualTo: true);

    // Appliquer les filtres compatibles avec Firestore en premier
    if (needType != 'Tous') {
      final offerValue = needType == 'Acheter' ? 'Vendre' : needType;
      q = q.where('offerType.value', isEqualTo: offerValue);
    }

    if (propertyType != 'Tous') {
      final normalizedType = _normalizePropertyType(propertyType);
      q = q.where('houseType.value', isEqualTo: normalizedType);
    }

    // Récupérer plus de données pour compenser le filtrage client
    q = q.orderBy('createdAt', descending: true).limit(limit * 3);

    if (lastDocument != null) {
      q = q.startAfterDocument(lastDocument);
    }

    final snap = await q.get();
    var results = snap.docs.map(House.fromFirestore).toList();

    // Filtrage côté client
    results = _applyClientSideFilters(
      results,
      query: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      ville: ville,
      bedrooms: bedrooms,
    );

    return results.take(limit).toList();
  }

  /// Filtrage côté client pour recherche textuelle et critères complexes
  List<House> _applyClientSideFilters(
    List<House> houses, {
    String query = '',
    double? minPrice,
    double? maxPrice,
    String ville = '',
    int bedrooms = 0,
  }) {
    return houses.where((house) {
      // Recherche textuelle
      if (query.isNotEmpty && !_matchesTextQuery(house, query)) {
        return false;
      }

      // Prix
      if (minPrice != null && house.price < minPrice) return false;
      if (maxPrice != null && maxPrice.isFinite && house.price > maxPrice)
        return false;

      // Localisation
      if (ville.trim().isNotEmpty && !_matchesLocation(house, ville)) {
        return false;
      }

      // Chambres
      if (bedrooms > 0 && house.bedrooms != bedrooms) return false;

      return true;
    }).toList();
  }

  /// Vérifie si la maison correspond à la requête textuelle
  bool _matchesTextQuery(House house, String query) {
    final normalizedQuery = _normalizeText(query);
    final searchableFields = [
      house.houseType?.label ?? '',
      house.description,
      house.address?.town['label']?.toString() ?? '',
      house.address?.commune['label']?.toString() ?? '',
      house.address?.zone ?? '',
    ];

    return searchableFields
        .any((field) => _normalizeText(field).contains(normalizedQuery));
  }

  /// Vérifie si la maison correspond à la localisation
  bool _matchesLocation(House house, String location) {
    final normalizedLocation = _normalizeText(location);
    final locationFields = [
      house.address?.town['label']?.toString() ?? '',
      house.address?.commune['label']?.toString() ?? '',
      house.address?.zone ?? '',
    ];

    return locationFields
        .any((field) => _normalizeText(field).contains(normalizedLocation));
  }

  /// Filtre géographique côté client
  List<House> _filterByLocation(List<House> houses, String ville) {
    if (ville.trim().isEmpty) return houses;

    final normalizedVille = _normalizeText(ville);
    return houses
        .where((house) => _matchesLocation(house, normalizedVille))
        .toList();
  }

  /// Normalise le type de propriété selon la structure Firestore
  String _normalizePropertyType(String propertyType) {
    // Basé sur votre structure Firestore existante
    final typeMapping = {
      'Villa': 'villa',
      'Maison': 'maison',
      'Appartement': 'appartement',
      'Studio': 'studio',
      'Terrain': 'terrain',
      'Magasin': 'magasin',
      'Bureau': 'bureau',
      'Entrepôt': 'entrepot',
    };

    return typeMapping[propertyType] ?? propertyType.toLowerCase();
  }

  /// Normalise le texte pour la recherche (suppression accents, minuscules)
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MÉTHODES DE COMPATIBILITÉ
  // ────────────────────────────────────────────────────────────────────────────

  Future<List<House>> fetchFilteredHouses({
    required double minPrice,
    required double maxPrice,
    required String needType,
    required String propertyType,
    required String ville,
    required int bedrooms,
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
  // MÉTHODES FAVORITES
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> addFavorite(String houseId) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(houseId)
          .set({
        'houseId': houseId,
        'addedAt': FieldValue.serverTimestamp(),
      });
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
          .orderBy('addedAt', descending: true)
          .get();

      final ids = favSnap.docs.map((d) => d.id).toList();
      final houses = <House>[];

      // Optimisation: batch les requêtes par 10
      for (int i = 0; i < ids.length; i += 10) {
        final batch = ids.skip(i).take(10).toList();
        final futures = batch.map((id) => getHouseById(id));
        final results = await Future.wait(futures);

        for (final house in results) {
          if (house != null) houses.add(house);
        }
      }

      return houses;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MÉTHODES UTILITAIRES
  // ────────────────────────────────────────────────────────────────────────────

  /// Analyse des performances de recherche (debug)
  Future<Map<String, dynamic>> getSearchStats() async {
    try {
      final totalHouses = await _firestore
          .collection('houses')
          .where('isAvailable', isEqualTo: true)
          .count()
          .get();

      final offerTypes = await _firestore
          .collection('houses')
          .where('isAvailable', isEqualTo: true)
          .get()
          .then((snap) => snap.docs
              .map((doc) => doc.data()['offerType']['value'] as String?)
              .where((type) => type != null)
              .toSet()
              .toList());

      final houseTypes = await _firestore
          .collection('houses')
          .where('isAvailable', isEqualTo: true)
          .get()
          .then((snap) => snap.docs
              .map((doc) => doc.data()['houseType']['value'] as String?)
              .where((type) => type != null)
              .toSet()
              .toList());

      return {
        'totalHouses': totalHouses.count,
        'availableOfferTypes': offerTypes,
        'availableHouseTypes': houseTypes,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting search stats: $e');
      return {};
    }
  }
}
