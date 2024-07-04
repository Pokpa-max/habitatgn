import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String imageUrl;
  final String type;
  final String location;
  final String commune;
  final String quartier;
  final int price;
  final int numRooms;

  House({
    required this.imageUrl,
    required this.type,
    required this.location,
    required this.commune,
    required this.quartier,
    required this.price,
    required this.numRooms,
  });
}

// // enum HousingType {
//   apartment,
//   maison,
//   villa,
//   studio,
//   magasin,
//   terrain,
//   hotel,
//   duplex,
// }

// enum Furnishing {
//   furnished,
//   unfurnished,
//   semiFurnished,
//   // ajoutez d'autres types de mobilier si nécessaire
// }

// class House {
//   final String id;
//   final String title;
//   final String imageUrl;
//   final String description;
//   final double price;
//   final int rooms;
//   final double area;
//   final String address;
//   final List<String> imageUrls;
//   final HousingType type;
//   final int bathrooms;
//   final int kitchens;
//   final int livingRooms;
//   final int balconies;
//   final bool hasParking;
//   final bool hasGarden;
//   final bool hasPool;
//   final bool isAvailable;
//   final DateTime availableFrom;
//   final List<String> amenities;
//   final String contactName;
//   final String contactPhone;
//   final Furnishing furnishing;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final DocumentSnapshot snapshot;  // Ajoutez ce champ pour conserver le document snapshot

//   House({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
//     required this.description,
//     required this.price,
//     required this.rooms,
//     required this.area,
//     required this.address,
//     required this.imageUrls,
//     required this.type,
//     required this.bathrooms,
//     required this.kitchens,
//     required this.livingRooms,
//     required this.balconies,
//     required this.hasParking,
//     required this.hasGarden,
//     required this.hasPool,
//     required this.isAvailable,
//     required this.availableFrom,
//     required this.amenities,
//     required this.contactName,
//     required this.contactPhone,
//     required this.furnishing,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.snapshot,
//   });

//   factory House.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//     return House(
//       id: data['id'],
//       title: data['title'],
//       imageUrl: data['imageUrl'],
//       description: data['description'],
//       price: data['price'].toDouble(),
//       rooms: data['rooms'],
//       area: data['area'].toDouble(),
//       address: data['address'],
//       imageUrls: List<String>.from(data['imageUrls']),
//       type: HousingType.values.firstWhere((e) => e.toString() == 'HousingType.${data['type']}'),
//       bathrooms: data['bathrooms'],
//       kitchens: data['kitchens'],
//       livingRooms: data['livingRooms'],
//       balconies: data['balconies'],
//       hasParking: data['hasParking'],
//       hasGarden: data['hasGarden'],
//       hasPool: data['hasPool'],
//       isAvailable: data['isAvailable'],
//       availableFrom: (data['availableFrom'] as Timestamp).toDate(),
//       amenities: List<String>.from(data['amenities']),
//       contactName: data['contactName'],
//       contactPhone: data['contactPhone'],
//       furnishing: Furnishing.values.firstWhere((e) => e.toString() == 'Furnishing.${data['furnishing']}'),
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//       updatedAt: (data['updatedAt'] as Timestamp).toDate(),
//       snapshot: doc,
//     );
//   }
// }

//Recuperaion dun logement en fonction de son type
// enum HousingType {
//   apartment,
//   maison,
//   villa,
//   studio,
//   magasin,
//   terrain,
//   hotel,
//   duplex,
// }

// enum Furnishing {
//   furnished,
//   unfurnished,
//   semiFurnished,
//   // ajoutez d'autres types de mobilier si nécessaire
// }

// class House {
//   final String id;
//   final String title;
//   final String imageUrl;
//   final String description;
//   final double price;
//   final int rooms;
//   final double area;
//   final String address;
//   final List<String> imageUrls;
//   final HousingType type;
//   final int bathrooms;
//   final int kitchens;
//   final int livingRooms;
//   final int balconies;
//   final bool hasParking;
//   final bool hasGarden;
//   final bool hasPool;
//   final bool isAvailable;
//   final DateTime availableFrom;
//   final List<String> amenities;
//   final String contactName;
//   final String contactPhone;
//   final Furnishing furnishing;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final DocumentSnapshot snapshot;

//   House({
//     required this.id,
//     required this.title,
//     required this.imageUrl,
//     required this.description,
//     required this.price,
//     required this.rooms,
//     required this.area,
//     required this.address,
//     required this.imageUrls,
//     required this.type,
//     required this.bathrooms,
//     required this.kitchens,
//     required this.livingRooms,
//     required this.balconies,
//     required this.hasParking,
//     required this.hasGarden,
//     required this.hasPool,
//     required this.isAvailable,
//     required this.availableFrom,
//     required this.amenities,
//     required this.contactName,
//     required this.contactPhone,
//     required this.furnishing,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.snapshot,
//   });

//   factory House.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//     return House(
//       id: doc.id,
//       title: data['title'],
//       imageUrl: data['imageUrl'],
//       description: data['description'],
//       price: data['price'].toDouble(),
//       rooms: data['rooms'],
//       area: data['area'].toDouble(),
//       address: data['address'],
//       imageUrls: List<String>.from(data['imageUrls']),
//       type: HousingType.values
//           .firstWhere((e) => e.toString() == 'HousingType.${data['type']}'),
//       bathrooms: data['bathrooms'],
//       kitchens: data['kitchens'],
//       livingRooms: data['livingRooms'],
//       balconies: data['balconies'],
//       hasParking: data['hasParking'],
//       hasGarden: data['hasGarden'],
//       hasPool: data['hasPool'],
//       isAvailable: data['isAvailable'],
//       availableFrom: (data['availableFrom'] as Timestamp).toDate(),
//       amenities: List<String>.from(data['amenities']),
//       contactName: data['contactName'],
//       contactPhone: data['contactPhone'],
//       furnishing: Furnishing.values.firstWhere(
//           (e) => e.toString() == 'Furnishing.${data['furnishing']}'),
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//       updatedAt: (data['updatedAt'] as Timestamp).toDate(),
//       snapshot: doc,
//     );
//   }
// }
