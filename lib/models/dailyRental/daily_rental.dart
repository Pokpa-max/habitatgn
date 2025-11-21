import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PropertyType {
  final String label;
  final IconData icon;

  const PropertyType(this.label, this.icon);
}

// Énumération pour les types de tarification
enum PriceType {
  hourly('hourly', 'Par heure'),
  daily('daily', 'Par jour'),
  weekly('weekly', 'Par semaine'),
  monthly('monthly', 'Par mois');

  final String value;
  final String label;

  const PriceType(this.value, this.label);

  static PriceType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'hourly':
        return PriceType.hourly;
      case 'weekly':
        return PriceType.weekly;
      case 'monthly':
        return PriceType.monthly;
      case 'daily':
      default:
        return PriceType.daily;
    }
  }

  // ✨ NOUVEAU: Getter pour le suffixe du prix
  String get priceSuffix {
    switch (this) {
      case PriceType.hourly:
        return '/h';
      case PriceType.weekly:
        return '/semaine';
      case PriceType.monthly:
        return '/mois';
      case PriceType.daily:
      default:
        return '/jour';
    }
  }

  // ✨ NOUVEAU: Getter pour le label complet
  String get fullLabel {
    return label;
  }

  // ✨ NOUVEAU: Getter pour l'icône
  IconData get icon {
    switch (this) {
      case PriceType.hourly:
        return Icons.schedule;
      case PriceType.weekly:
        return Icons.calendar_today;
      case PriceType.monthly:
        return Icons.calendar_month;
      case PriceType.daily:
      default:
        return Icons.calendar_today;
    }
  }

  // ✨ NOUVEAU: Méthode statique pour obtenir le suffixe
  static String getSuffixForType(PriceType type) {
    return type.priceSuffix;
  }

  // ✨ NOUVEAU: Méthode statique pour obtenir l'icône
  static IconData getIconForType(PriceType type) {
    return type.icon;
  }
}

class DynamicField {
  final String label;
  final String value;

  DynamicField({
    required this.label,
    required this.value,
  });

  factory DynamicField.fromJson(Map<String, dynamic> json) {
    return DynamicField(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
      };
}

class Address {
  final DynamicField commune;
  final DynamicField town;
  final String zone;
  final double lat;
  final double long;

  Address({
    required this.commune,
    required this.town,
    required this.zone,
    required this.lat,
    required this.long,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      commune: DynamicField.fromJson(json['commune'] ?? {}),
      town: DynamicField.fromJson(json['town'] ?? {}),
      zone: json['zone'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      long: (json['long'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'commune': commune.toJson(),
        'town': town.toJson(),
        'zone': zone,
        'lat': lat,
        'long': long,
      };
}

class DailyRental {
  final String id;
  final String imageUrl;
  final String description;
  final HouseType? houseType;
  final Address? address;
  final int bedrooms;
  final int maxGuests;
  final int minStay;
  final int maxStay;
  final int checkInHour;
  final int checkOutHour;
  final bool isAvailable;
  final String phoneNumber;
  final List<String>? amenities;
  final List<String>? houseInsides;
  final DynamicField? offerType;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ✨ NOUVELLES PROPRIÉTÉS POUR TARIFICATION FLEXIBLE
  final int pricePerNight;
  final int? pricePerHour;
  final int? pricePerWeek;
  final int? pricePerMonth;
  final PriceType mainPriceType; // Type de prix principal à afficher

  DailyRental({
    required this.id,
    required this.imageUrl,
    required this.description,
    this.houseType,
    this.address,
    required this.bedrooms,
    required this.maxGuests,
    required this.minStay,
    required this.maxStay,
    required this.checkInHour,
    required this.checkOutHour,
    required this.isAvailable,
    required this.phoneNumber,
    this.amenities,
    this.houseInsides,
    this.offerType,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.pricePerNight,
    this.pricePerHour,
    this.pricePerWeek,
    this.pricePerMonth,
    this.mainPriceType = PriceType.daily,
  });

  // ========== GETTERS UTILES ==========

  /// Obtenir le prix à afficher selon le type principal
  int get mainPrice {
    switch (mainPriceType) {
      case PriceType.hourly:
        return pricePerHour ?? pricePerNight;
      case PriceType.weekly:
        return pricePerWeek ?? (pricePerNight * 7);
      case PriceType.monthly:
        return pricePerMonth ?? (pricePerNight * 30);
      case PriceType.daily:
      default:
        return pricePerNight;
    }
  }

  /// Obtenir le suffixe du prix pour l'affichage
  String get priceSuffix {
    return mainPriceType.priceSuffix;
  }

  /// Obtenir le label complet du prix
  String get priceLabel {
    return mainPriceType.label;
  }

  /// Vérifier si plusieurs types de tarification sont disponibles
  List<PriceType> get availablePriceTypes {
    final types = <PriceType>[PriceType.daily];

    if (pricePerHour != null) types.add(PriceType.hourly);
    if (pricePerWeek != null) types.add(PriceType.weekly);
    if (pricePerMonth != null) types.add(PriceType.monthly);

    return types;
  }

  /// Obtenir le prix pour un type spécifique
  int? getPriceForType(PriceType type) {
    switch (type) {
      case PriceType.hourly:
        return pricePerHour;
      case PriceType.weekly:
        return pricePerWeek;
      case PriceType.monthly:
        return pricePerMonth;
      case PriceType.daily:
      default:
        return pricePerNight;
    }
  }

  /// Obtenir le suffixe pour un type de prix
  static String getSuffixForType(PriceType type) {
    return type.priceSuffix;
  }

  /// Obtenir l'icône pour un type de prix
  static IconData getIconForType(PriceType type) {
    return type.icon;
  }

  // ========== SERIALIZATION ==========

  factory DailyRental.fromJson(Map<String, dynamic> json) {
    return DailyRental(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      houseType: json['houseType'] != null
          ? HouseType.fromMap(json['houseType'] as Map<String, dynamic>)
          : null,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      bedrooms: json['bedrooms'] ?? 0,
      maxGuests: json['maxGuests'] ?? 0,
      minStay: json['minStay'] ?? 1,
      maxStay: json['maxStay'] ?? 30,
      checkInHour: json['checkInHour'] ?? 14,
      checkOutHour: json['checkOutHour'] ?? 11,
      isAvailable: json['isAvailable'] ?? true,
      phoneNumber: json['phoneNumber'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      houseInsides: List<String>.from(json['houseInsides'] ?? []),
      offerType: json['offerType'] != null
          ? DynamicField.fromJson(json['offerType'])
          : null,
      type: json['type'] ?? 'daily_rental',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      pricePerNight: json['pricePerNight'] ?? 0,
      pricePerHour: json['pricePerHour'],
      pricePerWeek: json['pricePerWeek'],
      pricePerMonth: json['pricePerMonth'],
      mainPriceType: PriceType.fromString(json['mainPriceType']),
    );
  }

  factory DailyRental.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyRental.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'description': description,
        'houseType': houseType?.toMap(),
        'address': address?.toJson(),
        'bedrooms': bedrooms,
        'maxGuests': maxGuests,
        'minStay': minStay,
        'maxStay': maxStay,
        'checkInHour': checkInHour,
        'checkOutHour': checkOutHour,
        'isAvailable': isAvailable,
        'phoneNumber': phoneNumber,
        'amenities': amenities,
        'houseInsides': houseInsides,
        'offerType': offerType?.toJson(),
        'type': type,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'pricePerNight': pricePerNight,
        'pricePerHour': pricePerHour,
        'pricePerWeek': pricePerWeek,
        'pricePerMonth': pricePerMonth,
        'mainPriceType': mainPriceType.value,
      };

  @override
  String toString() => 'DailyRental(id: $id, type: ${houseType?.label})';
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
