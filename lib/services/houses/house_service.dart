import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/models/housing.dart';

class HouseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<House>> getHousesByCategory(String category) async {
    // Simuler un délai de chargement
    await Future.delayed(const Duration(seconds: 0));
    // Retourner une liste simulée de maisons pour chaque catégorie
    switch (category) {
      case 'Villas':
        return [
          House(
            type: 'Villa',
            location: 'Paris',
            commune: 'Commune1',
            quartier: 'Quartier1',
            price: 3000,
            imageUrl: 'assets/images/maison.jpg',
            numRooms: 3,
          ),
          // Ajouter d'autres maisons ici
        ];
      case 'Maisons':
        return [
          House(
            type: 'Maison',
            location: 'Lyon',
            commune: 'Commune2',
            quartier: 'Quartier2',
            price: 2500,
            imageUrl: 'assets/images/maison2.jpg',
            numRooms: 4,
          ),
          // Ajouter d'autres maisons ici
        ];
      // Ajouter d'autres catégories ici
      default:
        return [];
    }
  }

//Recuperation  des logements avec une taille de 20 element
//  Future<List<House>> getHouses(
//       {DocumentSnapshot? lastDocument, int limit = 20}) async {
//     try {
//       Query query = _firestore
//           .collection('houses')
//           .orderBy('createdAt', descending: true)
//           .limit(limit);

//       if (lastDocument != null) {
//         query = query.startAfterDocument(lastDocument);
//       }

//       QuerySnapshot querySnapshot = await query.get();
//       List<House> houses = querySnapshot.docs
//           .map((doc) => House.fromFirestore(doc.data() as DocumentSnapshot<Object?>))
//           .toList();
//       return houses;
//     } catch (e) {
//       print('Error fetching houses: $e');
//       return [];
//     }
//   }

  // Future<List<House>> getHouses({
  //   DocumentSnapshot? lastDocument,
  //   int limit = 20,
  //   HousingType? housingType, // Ajout du paramètre de type de logement
  // }) async {
  //   try {
  //     Query query = _firestore
  //         .collection('houses')
  //         .orderBy('createdAt', descending: true)
  //         .limit(limit);

  //     if (housingType != null) {
  //       query = query.where('type',
  //           isEqualTo: housingType.toString().split('.').last);
  //     }

  //     if (lastDocument != null) {
  //       query = query.startAfterDocument(lastDocument);
  //     }

  //     QuerySnapshot querySnapshot = await query.get();
  //     List<House> houses =
  //         querySnapshot.docs.map((doc) => House.fromFirestore(doc)).toList();
  //     return houses;
  //   } catch (e) {
  //     print('Error fetching houses: $e');
  //     return [];
  //   }
  // }
}
