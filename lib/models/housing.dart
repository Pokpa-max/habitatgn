

import 'package:cloud_firestore/cloud_firestore.dart';

class House {
  final String phoneNumber;
  final bool isAvailable;
  final int bedrooms;
  final double rentalDeposit;
  final double housingDeposit;
  final Address address;
  final String offerType;
  final String furnishing;
  final double area;
  final double price;
  final List<String> commodites;
  final String imageUrl;
  final String description;
  final String houseType;
  final List<String> houseInsides;
  final List<String> likes;
  final String userId;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  House({
    required this.phoneNumber,
    required this.isAvailable,
    required this.bedrooms,
    required this.rentalDeposit,
    required this.housingDeposit,
    required this.address,
    required this.offerType,
    required this.furnishing,
    required this.area,
    required this.price,
    required this.commodites,
    required this.imageUrl,
    required this.description,
    required this.houseType,
    required this.houseInsides,
    required this.likes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory House.fromMap(Map<String, dynamic> data) {
    return House(
      phoneNumber: data['phoneNumber'],
      isAvailable: data['isAvailable'],
      bedrooms: data['bedrooms'],
      rentalDeposit: (data['rentalDeposit'] as num).toDouble(),
      housingDeposit: (data['housingDeposit'] as num).toDouble(),
      address: Address.fromMap(data['address']),
      offerType: data['offerType'],
      furnishing: data['furnishing'],
      area: (data['area'] as num).toDouble(),
      price: (data['price'] as num).toDouble(),
      commodites: List<String>.from(data['commodites']),
      imageUrl: data['imageUrl'],
      description: data['description'],
      houseType: data['houseType'],
      houseInsides: List<String>.from(data['houseInsides']),
      likes: List<String>.from(data['likes']),
      userId: data['userId'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'isAvailable': isAvailable,
      'bedrooms': bedrooms,
      'rentalDeposit': rentalDeposit,
      'housingDeposit': housingDeposit,
      'address': address.toMap(),
      'offerType': offerType,
      'furnishing': furnishing,
      'area': area,
      'price': price,
      'commodites': commodites,
      'imageUrl': imageUrl,
      'description': description,
      'houseType': houseType,
      'houseInsides': houseInsides,
      'likes': likes,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Address {
  final String commune;
  final String town;
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
      commune: data['commune'],
      town: data['town'],
      zone: data['zone'],
      long: (data['long'] as num).toDouble(),
      lat: (data['lat'] as num).toDouble(),
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
