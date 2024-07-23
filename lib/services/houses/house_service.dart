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

  Future<List<House>> getHouses({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? housingType,
  }) async {
    print('ovoir house ype 🫅🫅🫅🫅');
    print(housingType);
    try {
      Query query = _firestore
          .collection('houses')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (housingType != null) {
        query = query.where('houseType.value', isEqualTo: housingType);
      }

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
