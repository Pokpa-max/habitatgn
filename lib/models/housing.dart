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

enum Furnishing {
  furnished,
  semiFurnished,
  unfurnished,

  // meublé, semi-meublé, non-meublé
}

class Housing {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final double price;
  final int rooms;
  final double area;
  final String address;
  final List<String> imageUrls;
  final HousingType type;
  final int bathrooms;
  final int kitchens;
  final int livingRooms;
  final int balconies;
  final bool hasParking;
  final bool hasGarden;
  final bool hasPool;
  final bool isAvailable;
  final DateTime availableFrom;
  final List<String> amenities;
  final String contactName;
  final String contactPhone;
  final Furnishing furnishing;
  final DateTime createdAt;
  final DateTime upadateAt;

  Housing(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.description,
      required this.price,
      required this.rooms,
      required this.area,
      required this.address,
      required this.imageUrls,
      required this.furnishing,
      required this.type,
      required this.bathrooms,
      required this.kitchens,
      required this.livingRooms,
      required this.balconies,
      required this.hasParking,
      required this.hasGarden,
      required this.hasPool,
      required this.isAvailable,
      required this.availableFrom,
      required this.amenities,
      required this.contactName,
      required this.contactPhone,
      required this.createdAt,
      required this.upadateAt});

  factory Housing.fromJson(Map<String, dynamic> json) {
    return Housing(
      id: json['id'],
      title: json['title'],
      furnishing: _parseFurnishing(json['furnishing']),
      imageUrl: json['imageUrl'],
      description: json['description'],
      price: json['price'].toDouble(),
      rooms: json['rooms'],
      area: json['area'].toDouble(),
      address: json['address'],
      imageUrls: List<String>.from(json['imageUrls']),
      type: _parseHousingType(json['type']),
      bathrooms: json['bathrooms'],
      kitchens: json['kitchens'],
      livingRooms: json['livingRooms'],
      balconies: json['balconies'],
      hasParking: json['hasParking'],
      hasGarden: json['hasGarden'],
      hasPool: json['hasPool'],
      isAvailable: json['isAvailable'],
      availableFrom: DateTime.parse(json['availableFrom']),
      createdAt: DateTime.parse(json['createdAt']),
      upadateAt: DateTime.parse(json['upadateAt']),
      amenities: List<String>.from(json['amenities']),
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'price': price,
      'rooms': rooms,
      'area': area,
      'address': address,
      'imageUrls': imageUrls,
      'type': type.toString().split('.').last,
      'bathrooms': bathrooms,
      'kitchens': kitchens,
      'livingRooms': livingRooms,
      'balconies': balconies,
      'hasParking': hasParking,
      'hasGarden': hasGarden,
      'hasPool': hasPool,
      'isAvailable': isAvailable,
      'availableFrom': availableFrom.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'upadateAt': upadateAt.toIso8601String(),
      'amenities': amenities,
      'contactName': contactName,
      'contactPhone': contactPhone,
    };
  }

  static HousingType _parseHousingType(String type) {
    return HousingType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => HousingType.apartment,
    );
  }

  static Furnishing _parseFurnishing(String furnishing) {
    return Furnishing.values.firstWhere(
      (e) => e.toString().split('.').last == furnishing,
      orElse: () => Furnishing.unfurnished,
    );
  }
}




// Propriétés :

// id: Identifiant unique du logement.
// title: Titre ou nom du logement.
// description: Description détaillée du logement.
// price: Prix du logement.
// rooms: Nombre de chambres dans le logement.
// area: Surface ou superficie du logement en mètres carrés.
// address: Adresse physique du logement.
// imageUrls: Liste d'URLs des images représentant le logement.
// type: Type de logement (appartement, maison, villa, etc.).
// bathrooms: Nombre de salles de bains.
// kitchens: Nombre de cuisines.
// livingRooms: Nombre de salons ou séjours.
// balconies: Nombre de balcons.
// hasParking: Indique si le logement dispose de places de parking.
// hasGarden: Indique si le logement dispose d'un jardin.
// hasPool: Indique si le logement dispose d'une piscine.
// isAvailable: Indique si le logement est disponible ou non.
// availableFrom: Date à partir de laquelle le logement est disponible.
// furnishing: Type d'ameublement du logement (meublé, semi-meublé, non-meublé).
// heatingType: Type de chauffage du logement (électrique, gaz, bois, autre).
// amenities: Liste des équipements disponibles (chauffage central, climatisation, etc.).
// contactName: Nom du contact pour le logement.
// contactPhone: Numéro de téléphone du contact pour le logement.


