// import 'package:cloud_firestore/cloud_firestore.dart';

// class DailyRental {
//   final String id;
//   final Address? address;
//   final int area;
//   final int bedrooms;
//   final int checkInHour;
//   final int checkOutHour;
//   final DateTime createdAt;
//   final String description;
//   final List<String> houseInsides;
//   final HouseType? houseType;
//   final String imageUrl;
//   final bool isAvailable;
//   final int maxGuests;
//   final int maxStay;
//   final int minStay;
//   final OfferType offerType;
//   final String phoneNumber;
//   final double pricePerNight;
//   final DateTime updatedAt;

//   DailyRental({
//     required this.id,
//     this.address,
//     required this.area,
//     required this.bedrooms,
//     required this.checkInHour,
//     required this.checkOutHour,
//     required this.createdAt,
//     required this.description,
//     required this.houseInsides,
//     this.houseType,
//     required this.imageUrl,
//     required this.isAvailable,
//     required this.maxGuests,
//     required this.maxStay,
//     required this.minStay,
//     required this.offerType,
//     required this.phoneNumber,
//     required this.pricePerNight,
//     required this.updatedAt,
//   });

//   factory DailyRental.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;

//     return DailyRental(
//       id: doc.id,
//       address: data['address'] != null
//           ? Address.fromMap(data['address'] as Map<String, dynamic>)
//           : null,
//       area: data['area'] ?? 0,
//       bedrooms: data['bedrooms'] ?? 0,
//       checkInHour: data['checkInHour'] ?? 14,
//       checkOutHour: data['checkOutHour'] ?? 12,
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       description: data['description'] ?? '',
//       houseInsides: List<String>.from(data['houseInsides'] ?? []),
//       houseType: data['houseType'] != null
//           ? HouseType.fromMap(data['houseType'] as Map<String, dynamic>)
//           : null,
//       imageUrl: data['imageUrl'] ?? '',
//       isAvailable: data['isAvailable'] ?? true,
//       maxGuests: data['maxGuests'] ?? 2,
//       maxStay: data['maxStay'] ?? 30,
//       minStay: data['minStay'] ?? 1,
//       offerType: OfferType.fromMap(data['offerType'] as Map<String, dynamic>),
//       phoneNumber: data['phoneNumber'] ?? '',
//       pricePerNight: data['pricePerNight'] ?? 0,
//       updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'address': address?.toMap(),
//       'area': area,
//       'bedrooms': bedrooms,
//       'checkInHour': checkInHour,
//       'checkOutHour': checkOutHour,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'description': description,
//       'houseInsides': houseInsides,
//       'houseType': houseType?.toMap(),
//       'imageUrl': imageUrl,
//       'isAvailable': isAvailable,
//       'maxGuests': maxGuests,
//       'maxStay': maxStay,
//       'minStay': minStay,
//       'offerType': offerType.toMap(),
//       'phoneNumber': phoneNumber,
//       'pricePerNight': pricePerNight,
//       'updatedAt': Timestamp.fromDate(updatedAt),
//     };
//   }

//   DailyRental copyWith({
//     String? id,
//     Address? address,
//     int? area,
//     int? bedrooms,
//     int? checkInHour,
//     int? checkOutHour,
//     DateTime? createdAt,
//     String? description,
//     List<String>? houseInsides,
//     HouseType? houseType,
//     String? imageUrl,
//     bool? isAvailable,
//     int? maxGuests,
//     int? maxStay,
//     int? minStay,
//     OfferType? offerType,
//     String? phoneNumber,
//     int? pricePerNight,
//     DateTime? updatedAt,
//   }) {
//     return DailyRental(
//       id: id ?? this.id,
//       address: address ?? this.address,
//       area: area ?? this.area,
//       bedrooms: bedrooms ?? this.bedrooms,
//       checkInHour: checkInHour ?? this.checkInHour,
//       checkOutHour: checkOutHour ?? this.checkOutHour,
//       createdAt: createdAt ?? this.createdAt,
//       description: description ?? this.description,
//       houseInsides: houseInsides ?? this.houseInsides,
//       houseType: houseType ?? this.houseType,
//       imageUrl: imageUrl ?? this.imageUrl,
//       isAvailable: isAvailable ?? this.isAvailable,
//       maxGuests: maxGuests ?? this.maxGuests,
//       maxStay: maxStay ?? this.maxStay,
//       minStay: minStay ?? this.minStay,
//       offerType: offerType ?? this.offerType,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       pricePerNight:
//           pricePerNight != null ? pricePerNight.toDouble() : this.pricePerNight,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }

// class Address {
//   final Commune commune;
//   final double lat;
//   final double long;
//   final Town town;
//   final String zone;

//   Address({
//     required this.commune,
//     required this.lat,
//     required this.long,
//     required this.town,
//     required this.zone,
//   });

//   factory Address.fromMap(Map<String, dynamic> map) {
//     return Address(
//       commune: Commune.fromMap(map['commune'] as Map<String, dynamic>),
//       lat: (map['lat'] ?? 0.0).toDouble(),
//       long: (map['long'] ?? 0.0).toDouble(),
//       town: Town.fromMap(map['town'] as Map<String, dynamic>),
//       zone: map['zone'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'commune': commune.toMap(),
//       'lat': lat,
//       'long': long,
//       'town': town.toMap(),
//       'zone': zone,
//     };
//   }
// }

// class Commune {
//   final String label;
//   final String value;

//   Commune({
//     required this.label,
//     required this.value,
//   });

//   factory Commune.fromMap(Map<String, dynamic> map) {
//     return Commune(
//       label: map['label'] ?? '',
//       value: map['value'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'label': label,
//       'value': value,
//     };
//   }
// }

// class Town {
//   final String label;
//   final String value;

//   Town({
//     required this.label,
//     required this.value,
//   });

//   factory Town.fromMap(Map<String, dynamic> map) {
//     return Town(
//       label: map['label'] ?? '',
//       value: map['value'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'label': label,
//       'value': value,
//     };
//   }
// }

// class HouseType {
//   final String label;
//   final String value;

//   HouseType({
//     required this.label,
//     required this.value,
//   });

//   factory HouseType.fromMap(Map<String, dynamic> map) {
//     return HouseType(
//       label: map['label'] ?? '',
//       value: map['value'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'label': label,
//       'value': value,
//     };
//   }
// }

// class OfferType {
//   final String label;
//   final String value;

//   OfferType({
//     required this.label,
//     required this.value,
//   });

//   factory OfferType.fromMap(Map<String, dynamic> map) {
//     return OfferType(
//       label: map['label'] ?? '',
//       value: map['value'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'label': label,
//       'value': value,
//     };
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class DailyRental {
  final String id;
  final Address? address;
  final int area;
  final int bedrooms;
  final int checkInHour;
  final int checkOutHour;
  final DateTime createdAt;
  final String description;
  final List<String> houseInsides;
  final HouseType? houseType;
  final String imageUrl;
  final bool isAvailable;
  final int maxGuests;
  final int maxStay;
  final int minStay;
  final OfferType offerType;
  final String phoneNumber;
  final double pricePerNight;
  final DateTime updatedAt;

  DailyRental({
    required this.id,
    this.address,
    required this.area,
    required this.bedrooms,
    required this.checkInHour,
    required this.checkOutHour,
    required this.createdAt,
    required this.description,
    required this.houseInsides,
    this.houseType,
    required this.imageUrl,
    required this.isAvailable,
    required this.maxGuests,
    required this.maxStay,
    required this.minStay,
    required this.offerType,
    required this.phoneNumber,
    required this.pricePerNight,
    required this.updatedAt,
  });

  factory DailyRental.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DailyRental(
      id: doc.id,
      address: data['address'] != null
          ? Address.fromMap(data['address'] as Map<String, dynamic>)
          : null,
      area: data['area'] ?? 0,
      bedrooms: data['bedrooms'] ?? 0,
      checkInHour: data['checkInHour'] ?? 14,
      checkOutHour: data['checkOutHour'] ?? 12,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      houseInsides: List<String>.from(data['houseInsides'] ?? []),
      houseType: data['houseType'] != null
          ? HouseType.fromMap(data['houseType'] as Map<String, dynamic>)
          : null,
      imageUrl: data['imageUrl'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      maxGuests: data['maxGuests'] ?? 2,
      maxStay: data['maxStay'] ?? 30,
      minStay: data['minStay'] ?? 1,
      offerType: OfferType.fromMap(data['offerType'] as Map<String, dynamic>),
      phoneNumber: data['phoneNumber'] ?? '',
      // ✅ CORRECTION: Conversion explicite int -> double
      pricePerNight: (data['pricePerNight'] ?? 0).toDouble(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address?.toMap(),
      'area': area,
      'bedrooms': bedrooms,
      'checkInHour': checkInHour,
      'checkOutHour': checkOutHour,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'houseInsides': houseInsides,
      'houseType': houseType?.toMap(),
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'maxGuests': maxGuests,
      'maxStay': maxStay,
      'minStay': minStay,
      'offerType': offerType.toMap(),
      'phoneNumber': phoneNumber,
      // Sauvegarder comme int dans Firestore pour économiser l'espace
      'pricePerNight': pricePerNight.toInt(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DailyRental copyWith({
    String? id,
    Address? address,
    int? area,
    int? bedrooms,
    int? checkInHour,
    int? checkOutHour,
    DateTime? createdAt,
    String? description,
    List<String>? houseInsides,
    HouseType? houseType,
    String? imageUrl,
    bool? isAvailable,
    int? maxGuests,
    int? maxStay,
    int? minStay,
    OfferType? offerType,
    String? phoneNumber,
    double? pricePerNight,
    DateTime? updatedAt,
  }) {
    return DailyRental(
      id: id ?? this.id,
      address: address ?? this.address,
      area: area ?? this.area,
      bedrooms: bedrooms ?? this.bedrooms,
      checkInHour: checkInHour ?? this.checkInHour,
      checkOutHour: checkOutHour ?? this.checkOutHour,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      houseInsides: houseInsides ?? this.houseInsides,
      houseType: houseType ?? this.houseType,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      maxGuests: maxGuests ?? this.maxGuests,
      maxStay: maxStay ?? this.maxStay,
      minStay: minStay ?? this.minStay,
      offerType: offerType ?? this.offerType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Address {
  final Commune commune;
  final double lat;
  final double long;
  final Town town;
  final String zone;

  Address({
    required this.commune,
    required this.lat,
    required this.long,
    required this.town,
    required this.zone,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      commune: Commune.fromMap(map['commune'] as Map<String, dynamic>),
      lat: (map['lat'] ?? 0.0).toDouble(),
      long: (map['long'] ?? 0.0).toDouble(),
      town: Town.fromMap(map['town'] as Map<String, dynamic>),
      zone: map['zone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commune': commune.toMap(),
      'lat': lat,
      'long': long,
      'town': town.toMap(),
      'zone': zone,
    };
  }
}

class Commune {
  final String label;
  final String value;

  Commune({
    required this.label,
    required this.value,
  });

  factory Commune.fromMap(Map<String, dynamic> map) {
    return Commune(
      label: map['label'] ?? '',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class Town {
  final String label;
  final String value;

  Town({
    required this.label,
    required this.value,
  });

  factory Town.fromMap(Map<String, dynamic> map) {
    return Town(
      label: map['label'] ?? '',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class HouseType {
  final String label;
  final String value;

  HouseType({
    required this.label,
    required this.value,
  });

  factory HouseType.fromMap(Map<String, dynamic> map) {
    return HouseType(
      label: map['label'] ?? '',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class OfferType {
  final String label;
  final String value;

  OfferType({
    required this.label,
    required this.value,
  });

  factory OfferType.fromMap(Map<String, dynamic> map) {
    return OfferType(
      label: map['label'] ?? '',
      value: map['value'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}
