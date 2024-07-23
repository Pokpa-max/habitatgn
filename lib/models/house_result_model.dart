import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class HouseEssai {
  final String imageUrl;
  final String type;
  final String location;
  final String commune;
  final String quartier;
  final int price;
  final int numRooms;

  HouseEssai({
    required this.imageUrl,
    required this.type,
    required this.location,
    required this.commune,
    required this.quartier,
    required this.price,
    required this.numRooms,
  });
}

// Récupération d'un logement en fonction de son type

enum HousingType {
  apartment,
  maison,
  villa,
  studio,
  magasin,
  terrain,
  hotel,
  duplex,
}

enum FurnishingEnum {
  furnished,
  unfurnished,
  semiFurnished,
  // ajoutez d'autres types de mobilier si nécessaire
}

class House {
  final String id;
  final String phoneNumber;
  final bool isAvailable;
  final int bedrooms;
  final double rentalDeposit;
  final double housingDeposit;
  final Address? address;
  final Map<String, dynamic> offerType;
  final Map<String, dynamic> furnishing;
  final double area;
  final double price;
  final List<Map<String, dynamic>>? commodites;

  final String imageUrl;
  final String description;
  final HouseType? houseType;
  final List<String> houseInsides;
  final List<String> likes;
  final String userId;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final DocumentSnapshot snapshot;

  House({
    required this.id,
    required this.phoneNumber,
    required this.isAvailable,
    required this.bedrooms,
    required this.rentalDeposit,
    required this.housingDeposit,
    this.address,
    required this.offerType,
    required this.furnishing,
    required this.area,
    required this.price,
    required this.commodites,
    required this.imageUrl,
    required this.description,
    this.houseType,
    required this.houseInsides,
    required this.likes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.snapshot,
  });

  factory House.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return House(
      id: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      bedrooms: data['bedrooms'] ?? 0,
      rentalDeposit: (data['rentalDeposit'] as num).toDouble(),
      housingDeposit: (data['housingDeposit'] as num).toDouble(),
      address:
          data['address'] != null && data['address'] is Map<String, dynamic>
              ? Address.fromMap(data['address'])
              : null,
      offerType:
          data['offerType'] != null && data['offerType'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(data['offerType'])
              : {},
      furnishing: data['furnishing'] != null &&
              data['furnishing'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['furnishing'])
          : {},
      area: (data['area'] as num).toDouble(),
      price: (data['price'] as num).toDouble(),
      commodites: List<Map<String, dynamic>>.from(data['commodites']),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      houseType:
          data['houseType'] != null && data['houseType'] is Map<String, dynamic>
              ? HouseType.fromMap(data['houseType'])
              : null,
      houseInsides: data['houseInsides'] != null && data['houseInsides'] is List
          ? List<String>.from(data['houseInsides'])
          : [],
      likes: data['likes'] != null && data['likes'] is List
          ? List<String>.from(data['likes'])
          : [],
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      snapshot: doc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'isAvailable': isAvailable,
      'bedrooms': bedrooms,
      'rentalDeposit': rentalDeposit,
      'housingDeposit': housingDeposit,
      'address': address?.toMap(),
      'offerType': offerType,
      'furnishing': furnishing,
      'area': area,
      'price': price,
      'commodites': commodites,
      'imageUrl': imageUrl,
      'description': description,
      'houseType': houseType?.toMap(),
      'houseInsides': houseInsides,
      'likes': likes,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Address {
  final Map<String, dynamic> commune;
  final Map<String, dynamic> town;
  final String zone;
  final double long;
  final double lat;

  Address({
    required this.commune,
    required this.town,
    required this.zone,
    required this.long,
    required this.lat,
  });

  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      commune: Map<String, dynamic>.from(data['commune']),
      town: Map<String, dynamic>.from(data['town']),
      zone: data['zone'] ?? '',
      long: (data['long'] as num?)?.toDouble() ?? 0.0,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commune': commune,
      'town': town,
      'zone': zone,
      'long': long,
      'lat': lat,
    };
  }
}

class HouseType {
  final String label;
  final String value;

  HouseType({required this.label, required this.value});

  factory HouseType.fromMap(Map<String, dynamic> data) {
    return HouseType(
      label: data['label'] ?? '',
      value: data['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}




//  List<Map<String, dynamic>>.from(json['accompagnements']),
//    List<Map<String, dynamic>>?