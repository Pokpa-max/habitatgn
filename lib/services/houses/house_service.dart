import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitatgn/models/house_result_model.dart';

class HouseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<House?> getHouseById(String houseId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('houses').doc(houseId).get();

      if (doc.exists) {
        House house = House.fromFirestore(doc);
        return house;
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching house by id: $e');
      return null;
    }
  }

  // recuperation de lutilisateur courant
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  /// Récupère les logements récents.
  Future<List<House>> getRecentHouses({int limit = 10}) async {
    try {
      Query query = _firestore
          .collection('houses')
          .orderBy('createdAt', descending: true)
          .where('isAvailable', isEqualTo: true)
          .limit(limit);

      QuerySnapshot querySnapshot = await query.get();
      List<House> houses =
          querySnapshot.docs.map((doc) => House.fromFirestore(doc)).toList();

      return houses;
    } catch (e) {
      print('Error fetching recent houses: $e');
      return [];
    }
  }

  Future<List<House>> getHouses({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('houses')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      query = query.where('isAvailable', isEqualTo: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();

      List<House> houses =
          querySnapshot.docs.map((doc) => House.fromFirestore(doc)).toList();

      return houses;
    } catch (e) {
      print('Error fetching houses: $e');
      return [];
    }
  }

  Future<List<House>> fetchFilteredHouses({
    // required double minPrice,
    // required double maxPrice,
    // required String needType,
    required String propertyType,
    // required String ville,
    // required int bedrooms,
  }) async {
    Query query = _firestore.collection('houses');

    // Applique les filtres un par un
    // if (minPrice > 0) {
    //   query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    // }
    // if (maxPrice < double.infinity) {
    //   query = query.where('price', isLessThanOrEqualTo: maxPrice);
    // }
    // if (needType != 'Tous') {
    //   query = query.where('offerType.value',
    //       isEqualTo: needType == "Acheter" ? "AVendre" : "ALouer");
    // }
    if (propertyType != 'Tous') {
      query = query.where('houseType.label', isEqualTo: propertyType);
    }
    // if (ville.isNotEmpty) {
    //   query = query.where('address.town.label', isEqualTo: ville);
    // }
    // if (bedrooms > 0) {
    //   query = query.where('bedrooms', isEqualTo: bedrooms);
    // }

    // Exécute la requête
    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => House.fromFirestore(doc)).toList();
  }

  Future<void> addFavorite(String houseId) async {
    try {
      String userId = _auth.currentUser!.uid;
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
      String userId = _auth.currentUser!.uid;
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
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore
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
      String userId = _auth.currentUser!.uid;
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      List<String> houseIds = querySnapshot.docs.map((doc) => doc.id).toList();

      List<House> favoriteHouses = [];
      for (String houseId in houseIds) {
        House? house = await getHouseById(houseId);
        if (house != null) {
          favoriteHouses.add(house);
        }
      }
      return favoriteHouses;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }
}
