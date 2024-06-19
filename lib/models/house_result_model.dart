class House {
  final String imageUrl;
  final String type;
  final String location;
  final String commune;
  final String quartier;
  final int price;
  final int numRooms; // Champ pour le nombre de pièces

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
